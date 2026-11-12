import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/core/utils/travel_validators.dart';
import 'package:roamory/features/explore/data/repositories/supabase_explore_repository.dart';
import 'package:roamory/features/visits/domain/entities/visit_entity.dart';
import 'package:roamory/features/visits/domain/repositories/visits_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// [VisitsRepository] sözleşmesinin Supabase `visits`, `visit_photos`,
/// `visit_categories` ve `visit-photos` Storage implementasyonu.
///
/// Veri sözleşmesi (`database.md`):
/// 1. Ziyaret satırı oluşturulur (`visibility = 'private'`).
/// 2. Fotoğraflar `visit-photos` bucket'ına `userUUID/visitUUID/dosya` yoluyla yüklenir.
/// 3. `visit_photos` metadata satırları eklenir; hata oluşursa yüklenen dosyalar
///    Storage'dan silinerek yetim (orphan) dosya kalması önlenir.
class SupabaseVisitsRepository implements VisitsRepository {
  /// Supabase istemcisiyle repository oluşturur.
  const SupabaseVisitsRepository(this._client);

  /// `visit-photos` private bucket maksimum dosya boyutu (`10 MB`).
  static const int maxVisitPhotoBytes = 10 * 1024 * 1024;

  static const Set<String> _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  final sb.SupabaseClient? _client;

  sb.SupabaseClient get _requireClient {
    final client = _client;
    if (client == null) {
      throw const SupabaseNotConfiguredException();
    }
    return client;
  }

  @override
  Future<List<VisitEntity>> fetchVisits(String userId) async {
    try {
      final rows = await _requireClient
          .from('visits')
          .select(
            '*, places(*, categories(slug)), visit_photos(*), visit_categories(categories(slug))',
          )
          .eq('user_id', userId)
          .order('visited_at', ascending: false);

      final result = <VisitEntity>[];
      for (final raw in rows as List<dynamic>) {
        if (raw is Map<String, dynamic>) {
          result.add(await _mapVisitRowWithSignedUrls(raw));
        }
      }
      return result;
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<VisitEntity> fetchVisitById({
    required String visitId,
    required String userId,
  }) async {
    try {
      final row = await _requireClient
          .from('visits')
          .select(
            '*, places(*, categories(slug)), visit_photos(*), visit_categories(categories(slug))',
          )
          .eq('id', visitId)
          .eq('user_id', userId)
          .maybeSingle();

      if (row == null) {
        throw const NotFoundAppException(code: 'visit_not_found');
      }
      return await _mapVisitRowWithSignedUrls(row);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<VisitEntity> upsertVisit(UpsertVisitRequest request) async {
    final uploadedPaths = <String>[];
    String? createdNewPlaceId;
    String? createdNewVisitId;
    String effectiveUserId = request.userId.trim();

    try {
      // Domain doğrulaması: mekan, koordinat, 1..5 puan ve <=10MB fotoğraf kontrolü.
      TravelValidators.validateVisitRequest(request);

      final client = _requireClient;
      final sessionUserId = client.auth.currentUser?.id;

      // RLS politikaları `auth.uid()` değerini esas aldığı için aktif oturum
      // kimliği ile istekteki `user_id` değerinin birebir eşleştiğini doğruluyoruz.
      if (sessionUserId != null && sessionUserId.isNotEmpty) {
        if (effectiveUserId.isNotEmpty && effectiveUserId != sessionUserId) {
          throw const UnauthorizedAppException(code: 'auth_uid_mismatch');
        }
        effectiveUserId = sessionUserId;
      }
      if (effectiveUserId.isEmpty) {
        throw const UnauthorizedAppException(code: 'auth_session_missing');
      }

      String? resolvedPlaceId = request.placeId;

      // Kullanıcı katalog dışı yeni özel mekan girdiyse önce `places` kaydı açılır.
      if ((resolvedPlaceId == null || resolvedPlaceId.trim().isEmpty) &&
          request.customPlace != null) {
        final custom = request.customPlace!;
        final trimmedCountry = custom.country.trim();
        final insertedPlace = await client
            .from('places')
            .insert({
              'name': custom.name.trim(),
              // Ülke kodu, kanonik ülke adı ve şehir adı Pasaport sayaçlarında
              // farklı yazımların mükerrer sayılmaması için standartlaştırılır.
              'country_code': TravelValidators.normalizeCountryCode(
                trimmedCountry,
              ),
              'country_name': TravelValidators.normalizeCountryName(
                trimmedCountry,
              ),
              'city': TravelValidators.normalizeCityName(custom.city),
              'latitude': custom.latitude,
              'longitude': custom.longitude,
              if (custom.description != null &&
                  custom.description!.trim().isNotEmpty)
                'description_tr': custom.description!.trim(),
              'is_published': false,
              'created_by': effectiveUserId,
            })
            .select('id')
            .single();
        resolvedPlaceId = insertedPlace['id'].toString();
        createdNewPlaceId = resolvedPlaceId;
      }

      final visitPayload = <String, dynamic>{
        'user_id': effectiveUserId,
        'place_id': resolvedPlaceId,
        'visited_at': request.visitedAt.toIso8601String().split('T').first,
        'rating': request.rating,
        'title': request.title?.trim(),
        'notes': request.notes?.trim(),
        // Ziyaret kayıtları varsayılan olarak her zaman özeldir (AGENTS.md).
        'visibility': 'private',
      };

      // RLS INSERT ve UPDATE politikalarını ayrı ayrı ve net çalıştırmak için
      // yeni kayıtta insert, mevcut kayıtta update kullanıyoruz.
      final Map<String, dynamic> savedVisit;
      if (request.visitId != null && request.visitId!.trim().isNotEmpty) {
        savedVisit = await client
            .from('visits')
            .update(visitPayload)
            .eq('id', request.visitId!)
            .eq('user_id', effectiveUserId)
            .select('id')
            .single();
      } else {
        savedVisit = await client
            .from('visits')
            .insert(visitPayload)
            .select('id')
            .single();
        createdNewVisitId = savedVisit['id'].toString();
      }
      final visitId = savedVisit['id'].toString();

      // Kullanıcının seçtiği kategori etiketlerini `visit_categories` ara tablosuyla eşitliyoruz.
      if (request.visitId != null || request.categorySlugs.isNotEmpty) {
        await client.from('visit_categories').delete().eq('visit_id', visitId);
        if (request.categorySlugs.isNotEmpty) {
          final catRows = await client
              .from('categories')
              .select('id, slug')
              .inFilter('slug', request.categorySlugs);
          final categoryMappings = (catRows as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(
                (c) => <String, dynamic>{
                  'visit_id': visitId,
                  'category_id': c['id'],
                },
              )
              .toList();
          if (categoryMappings.isNotEmpty) {
            await client.from('visit_categories').insert(categoryMappings);
          }
        }
      }

      // Yeni fotoğraflar varsa `visit-photos` private bucket'ına yüklüyoruz.
      for (var i = 0; i < request.newPhotos.length; i++) {
        final photo = request.newPhotos[i];
        final ext = photo.fileExtension.trim().toLowerCase();
        if (!_allowedExtensions.contains(ext)) {
          throw const ValidationAppException(code: 'invalid_photo_format');
        }
        if (photo.bytes.lengthInBytes > maxVisitPhotoBytes) {
          throw const ValidationAppException(code: 'visit_photo_too_large');
        }
        final mimeType = switch (ext) {
          'png' => 'image/png',
          'webp' => 'image/webp',
          _ => 'image/jpeg',
        };
        final storagePath =
            '$effectiveUserId/$visitId/photo_${DateTime.now().millisecondsSinceEpoch}_$i.$ext';

        await client.storage
            .from('visit-photos')
            .uploadBinary(
              storagePath,
              photo.bytes,
              fileOptions: sb.FileOptions(contentType: mimeType, upsert: true),
            );
        uploadedPaths.add(storagePath);

        await client.from('visit_photos').insert({
          'visit_id': visitId,
          'storage_path': storagePath,
          if (photo.caption != null) 'caption': photo.caption!.trim(),
          'sort_order': i,
        });
      }

      return await fetchVisitById(visitId: visitId, userId: effectiveUserId);
    } catch (error, stackTrace) {
      // Hata durumunda yetim (orphan) Storage dosyası veya yarım veritabanı satırı
      // kalmaması için telafi (rollback/cleanup) adımlarını sırasıyla çalıştırıyoruz.
      if (_client != null) {
        if (uploadedPaths.isNotEmpty) {
          try {
            await _client.storage.from('visit-photos').remove(uploadedPaths);
          } catch (_) {}
        }
        if (createdNewVisitId != null && effectiveUserId.isNotEmpty) {
          try {
            await _client
                .from('visits')
                .delete()
                .eq('id', createdNewVisitId)
                .eq('user_id', effectiveUserId);
          } catch (_) {}
        }
        if (createdNewPlaceId != null && effectiveUserId.isNotEmpty) {
          try {
            await _client
                .from('places')
                .delete()
                .eq('id', createdNewPlaceId)
                .eq('created_by', effectiveUserId);
          } catch (_) {}
        }
      }
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> deleteVisit({
    required String visitId,
    required String userId,
  }) async {
    try {
      final client = _requireClient;
      // Veritabanı cascade silmesi Storage nesnelerini otomatik silmediği için
      // önce yalnızca `visit_photos` tablosundaki yolları okuyup `visit-photos`
      // bucket'ından kaldırıyoruz. Ziyaretten dönüştürülmüş topluluk gönderileri
      // ayrı `posts` / `post_photos` tablolarında ve `post-photos` bucket'ında
      // saklandığı için bu silme işleminden kesinlikle etkilenmez.
      final photoRows = await client
          .from('visit_photos')
          .select('storage_path')
          .eq('visit_id', visitId);

      final paths = (photoRows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => e['storage_path']?.toString())
          .whereType<String>()
          .where((p) => p.isNotEmpty)
          .toList();

      if (paths.isNotEmpty) {
        await client.storage.from('visit-photos').remove(paths);
      }

      await client
          .from('visits')
          .delete()
          .eq('id', visitId)
          .eq('user_id', userId);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  Future<VisitEntity> _mapVisitRowWithSignedUrls(
    Map<String, dynamic> row,
  ) async {
    final placeRaw = row['places'];
    final place = placeRaw is Map<String, dynamic>
        ? SupabaseExploreRepository.mapPlaceRow(placeRaw)
        : null;

    final photosRaw = row['visit_photos'];
    final photos = <VisitPhotoEntity>[];
    if (photosRaw is List<dynamic>) {
      for (final p in photosRaw.whereType<Map<String, dynamic>>()) {
        final storagePath = (p['storage_path'] ?? '').toString();
        String? signedUrl = p['signed_url'] as String?;
        if (signedUrl == null && storagePath.isNotEmpty && _client != null) {
          try {
            // Private bucket için 1 saatlik geçici imzalı URL üretiyoruz.
            signedUrl = await _client.storage
                .from('visit-photos')
                .createSignedUrl(storagePath, 3600);
          } catch (_) {}
        }
        photos.add(
          VisitPhotoEntity(
            id: (p['id'] ?? '').toString(),
            visitId: (p['visit_id'] ?? row['id'] ?? '').toString(),
            storagePath: storagePath,
            signedUrl: signedUrl,
            caption: p['caption'] as String?,
            sortOrder: (p['sort_order'] as num?)?.toInt() ?? 0,
          ),
        );
      }
    }

    final categoriesRaw = row['visit_categories'];
    final categorySlugs = <String>[];
    if (categoriesRaw is List<dynamic>) {
      for (final item in categoriesRaw.whereType<Map<String, dynamic>>()) {
        final nested = item['categories'];
        if (nested is Map<String, dynamic> && nested['slug'] != null) {
          categorySlugs.add(nested['slug'].toString());
        } else if (item['category_slug'] != null) {
          categorySlugs.add(item['category_slug'].toString());
        }
      }
    }

    return VisitEntity(
      id: (row['id'] ?? '').toString(),
      userId: (row['user_id'] ?? '').toString(),
      placeId: (row['place_id'] ?? '').toString(),
      visitedAt:
          DateTime.tryParse((row['visited_at'] ?? '').toString()) ??
          DateTime.now(),
      title: row['title'] as String?,
      notes: row['notes'] as String?,
      rating: (row['rating'] as num?)?.toInt(),
      visibility: (row['visibility'] as String?) ?? 'private',
      place: place,
      photos: photos,
      categorySlugs: categorySlugs,
      createdAt: row['created_at'] != null
          ? DateTime.tryParse(row['created_at'].toString())
          : null,
    );
  }
}

/// Uygulama genelinde kullanılan [VisitsRepository] bağımlılık sağlayıcısı.
final visitsRepositoryProvider = Provider<VisitsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseVisitsRepository(client);
});
