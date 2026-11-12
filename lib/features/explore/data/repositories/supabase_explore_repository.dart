import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/core/utils/travel_validators.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';
import 'package:roamory/features/explore/domain/repositories/explore_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// [ExploreRepository] sözleşmesinin Supabase `categories` ve `places` implementasyonu.
///
/// Katalog mekanlarını ve kullanıcının kendi oluşturduğu özel mekanları okur,
/// filtreler, kapak görsellerini gizlilik kurallarına uygun olarak çözümler ve
/// yeni özel mekan (`is_published = false`) kaydını gerçekleştirir.
class SupabaseExploreRepository implements ExploreRepository {
  /// Supabase istemcisiyle repository oluşturur.
  const SupabaseExploreRepository(this._client);

  final sb.SupabaseClient? _client;

  sb.SupabaseClient get _requireClient {
    final client = _client;
    if (client == null) {
      throw const SupabaseNotConfiguredException();
    }
    return client;
  }

  @override
  Future<List<CategoryEntity>> fetchCategories() async {
    try {
      // Canlı categories tablosundan id, slug, name_tr, name_en ve icon_name kolonlarını okuyoruz.
      final rows = await _requireClient
          .from('categories')
          .select('id, slug, name_tr, name_en, icon_name')
          .order('name_tr', ascending: true);

      return (rows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(mapCategoryRow)
          .toList();
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<List<PlaceEntity>> fetchPlaces({
    PlaceSearchFilter filter = const PlaceSearchFilter(),
    String? currentUserId,
  }) async {
    try {
      final client = _requireClient;
      final effectiveUserId =
          (currentUserId != null && currentUserId.trim().isNotEmpty)
          ? currentUserId.trim()
          : (client.auth.currentUser?.id ?? '');

      // RLS kuralına göre `places` tablosundan yayınlanmış mekanlar veya
      // oturumdaki kullanıcının kendi özel mekanları döner.
      final rows = await client
          .from('places')
          .select('*, categories(slug)')
          .order(
            filter.sortAlphabetically ? 'name' : 'created_at',
            ascending: filter.sortAlphabetically,
          );

      final places = (rows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(mapPlaceRow)
          .toList();

      final filtered = applyFilter(
        places,
        filter,
        currentUserId: effectiveUserId.isEmpty ? null : effectiveUserId,
      );

      return await _enrichPlacesWithAuthorizedCovers(
        filtered,
        currentUserId: effectiveUserId,
      );
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<PlaceEntity> fetchPlaceById(String placeId) async {
    try {
      final client = _requireClient;
      final effectiveUserId = client.auth.currentUser?.id ?? '';
      final row = await client
          .from('places')
          .select('*, categories(slug)')
          .eq('id', placeId)
          .maybeSingle();

      if (row == null) {
        throw const NotFoundAppException(code: 'place_not_found');
      }
      final mapped = mapPlaceRow(row);
      final enriched = await _enrichPlacesWithAuthorizedCovers([
        mapped,
      ], currentUserId: effectiveUserId);
      return enriched.first;
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<PlaceEntity> createPrivatePlace(
    CreatePrivatePlaceRequest request,
  ) async {
    try {
      // Veritabanına göndermeden önce ülke, şehir ve koordinat doğrulaması yapıyoruz.
      TravelValidators.validatePrivatePlace(request);

      final trimmedCountry = request.country.trim();
      final payload = <String, dynamic>{
        'name': request.name.trim(),
        // Canlı places tablosu country_code ve country_name kolonlarını kullanır;
        // farklı yazımların mükerrer ülke üretmemesi için kanonik değer kaydedilir.
        'country_code': normalizeCountryCode(trimmedCountry),
        'country_name': normalizeCountryName(trimmedCountry),
        'city': normalizeCityName(request.city),
        'latitude': request.latitude,
        'longitude': request.longitude,
        if (request.description != null &&
            request.description!.trim().isNotEmpty)
          'description_tr': request.description!.trim(),
        if (request.categoryId != null) 'category_id': request.categoryId,
        // Özel mekanlar varsayılan olarak katalogda yayınlanmaz; yalnızca sahibine aittir.
        'is_published': false,
        'created_by': request.userId,
      };

      final inserted = await _requireClient
          .from('places')
          .insert(payload)
          .select('*, categories(slug)')
          .single();

      return mapPlaceRow(inserted);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  /// Mekan kartlarının kapak görsellerini gizlilik sınırlarını koruyarak çözümler:
  ///
  /// 1. `places.cover_image_url` doluysa doğrudan kullanılır.
  /// 2. Yalnızca oturumdaki kullanıcıya ait özel mekanlar (`is_published = false`
  ///    ve `created_by == currentUserId`) için, yine aynı kullanıcının kendi
  ///    `visits` -> `visit_photos` kaydından (`storagePath` `currentUserId/` ile
  ///    başlamak koşuluyla) geçici signed URL üretilir. Özel ziyaret fotoğrafları
  ///    genel katalog mekanlarında veya başka kullanıcılarda ASLA kullanılmaz.
  /// 3. Hâlâ kapak görseli olmayan mekanlar için yalnızca herkese açık yayınlanmış
  ///    topluluk gönderilerinin (`posts.status = 'published'`) `post_photos`
  ///    görsellerinden geçici signed URL üretilir.
  Future<List<PlaceEntity>> _enrichPlacesWithAuthorizedCovers(
    List<PlaceEntity> places, {
    required String currentUserId,
  }) async {
    final client = _client;
    if (client == null || places.isEmpty) {
      return places;
    }

    final coverByPlaceId = <String, String>{};

    // 1. Kullanıcının kendi özel mekanları için kendi visit_photos signed URL çözümü.
    if (currentUserId.isNotEmpty) {
      final ownPrivatePlaceIds = places
          .where(
            (p) =>
                (p.coverImageUrl == null || p.coverImageUrl!.trim().isEmpty) &&
                !p.isPublished &&
                p.createdBy == currentUserId,
          )
          .map((p) => p.id)
          .toList();

      if (ownPrivatePlaceIds.isNotEmpty) {
        try {
          final visitRows = await client
              .from('visits')
              .select(
                'place_id, user_id, visit_photos(storage_path, sort_order)',
              )
              .eq('user_id', currentUserId)
              .inFilter('place_id', ownPrivatePlaceIds)
              .order('visited_at', ascending: false);

          for (final raw
              in (visitRows as List<dynamic>)
                  .whereType<Map<String, dynamic>>()) {
            final placeId = (raw['place_id'] ?? '').toString();
            final visitOwnerId = (raw['user_id'] ?? '').toString();
            if (placeId.isEmpty ||
                coverByPlaceId.containsKey(placeId) ||
                visitOwnerId != currentUserId) {
              continue;
            }
            final photosRaw = raw['visit_photos'];
            if (photosRaw is! List<dynamic> || photosRaw.isEmpty) {
              continue;
            }
            final sortedPhotos =
                photosRaw.whereType<Map<String, dynamic>>().toList()..sort(
                  (a, b) => ((a['sort_order'] as num?)?.toInt() ?? 0).compareTo(
                    (b['sort_order'] as num?)?.toInt() ?? 0,
                  ),
                );
            for (final photo in sortedPhotos) {
              final path = (photo['storage_path'] ?? '').toString().trim();
              // Güvenlik kontrolü: yalnızca oturumdaki kullanıcının kendi klasörü.
              if (path.isEmpty || !path.startsWith('$currentUserId/')) {
                continue;
              }
              try {
                final signed = await client.storage
                    .from('visit-photos')
                    .createSignedUrl(path, 3600);
                if (signed.isNotEmpty) {
                  coverByPlaceId[placeId] = signed;
                  break;
                }
              } catch (_) {}
            }
          }
        } catch (_) {}
      }
    }

    // 2. Kalan kapaksız mekanlar için yalnızca yayınlanmış (status='published')
    // topluluk gönderilerinin (post_photos) görsellerini kontrol ediyoruz.
    final remainingPlaceIds = places
        .where(
          (p) =>
              (p.coverImageUrl == null || p.coverImageUrl!.trim().isEmpty) &&
              !coverByPlaceId.containsKey(p.id),
        )
        .map((p) => p.id)
        .toList();

    if (remainingPlaceIds.isNotEmpty) {
      try {
        final postRows = await client
            .from('posts')
            .select('place_id, status, post_photos(storage_path, sort_order)')
            .eq('status', 'published')
            .inFilter('place_id', remainingPlaceIds)
            .order('created_at', ascending: false);

        for (final raw
            in (postRows as List<dynamic>).whereType<Map<String, dynamic>>()) {
          final placeId = (raw['place_id'] ?? '').toString();
          final status = (raw['status'] ?? '').toString();
          if (placeId.isEmpty ||
              status != 'published' ||
              coverByPlaceId.containsKey(placeId)) {
            continue;
          }
          final photosRaw = raw['post_photos'];
          if (photosRaw is! List<dynamic> || photosRaw.isEmpty) {
            continue;
          }
          final sortedPhotos =
              photosRaw.whereType<Map<String, dynamic>>().toList()..sort(
                (a, b) => ((a['sort_order'] as num?)?.toInt() ?? 0).compareTo(
                  (b['sort_order'] as num?)?.toInt() ?? 0,
                ),
              );
          for (final photo in sortedPhotos) {
            final path = (photo['storage_path'] ?? '').toString().trim();
            if (path.isEmpty) {
              continue;
            }
            try {
              final signed = await client.storage
                  .from('post-photos')
                  .createSignedUrl(path, 3600);
              if (signed.isNotEmpty) {
                coverByPlaceId[placeId] = signed;
                break;
              }
            } catch (_) {}
          }
        }
      } catch (_) {}
    }

    if (coverByPlaceId.isEmpty) {
      return places;
    }

    return places.map((place) {
      final resolvedUrl = coverByPlaceId[place.id];
      if (resolvedUrl == null || resolvedUrl.isEmpty) {
        return place;
      }
      return place.copyWith(coverImageUrl: resolvedUrl);
    }).toList();
  }

  /// Kullanıcının girdiği ülke adını veya kodunu 2 harfli ISO ülke koduna dönüştürür.
  static String normalizeCountryCode(String rawCountry) =>
      TravelValidators.normalizeCountryCode(rawCountry);

  /// Kullanıcının girdiği ülke adını veya kodunu kanonik ülke adına dönüştürür.
  static String normalizeCountryName(String rawCountry) =>
      TravelValidators.normalizeCountryName(rawCountry);

  /// Kullanıcının girdiği şehir adını standart biçime dönüştürür.
  static String normalizeCityName(String rawCity) =>
      TravelValidators.normalizeCityName(rawCity);

  /// Supabase `categories` satırını [CategoryEntity] nesnesine dönüştürür.
  static CategoryEntity mapCategoryRow(Map<String, dynamic> row) {
    return CategoryEntity(
      id: (row['id'] ?? '').toString(),
      slug: (row['slug'] ?? '').toString(),
      nameTr: (row['name_tr'] ?? row['slug'] ?? '').toString(),
      nameEn: (row['name_en'] ?? row['slug'] ?? '').toString(),
      iconName: row['icon_name'] as String?,
    );
  }

  /// Supabase `places` satırını [PlaceEntity] nesnesine dönüştürür.
  ///
  /// Canlı veritabanındaki `country_name`/`country_code` ve `description_tr`/`description_en`
  /// kolonlarını okur; aynı zamanda birim testlerindeki `country` ve `description`
  /// anahtarlarıyla geriye dönük uyumluluğu korur.
  static PlaceEntity mapPlaceRow(Map<String, dynamic> row) {
    String? categorySlug = row['category_slug'] as String?;
    final joinedCategory = row['categories'];
    if (categorySlug == null && joinedCategory is Map<String, dynamic>) {
      categorySlug = joinedCategory['slug'] as String?;
    }

    final rawCountry =
        (row['country_name'] ?? row['country'] ?? row['country_code'] ?? '')
            .toString()
            .trim();
    final resolvedCountry = rawCountry.isEmpty
        ? ''
        : (TravelValidators.tryResolveIsoCountryCode(rawCountry) != null
              ? TravelValidators.normalizeCountryName(rawCountry)
              : rawCountry);

    final rawCity = (row['city'] ?? '').toString().trim();
    final resolvedCity = rawCity.isEmpty
        ? ''
        : TravelValidators.normalizeCityName(rawCity);

    final resolvedDescription =
        (row['description_tr'] ?? row['description_en'] ?? row['description'])
            as String?;

    return PlaceEntity(
      id: (row['id'] ?? '').toString(),
      name: (row['name'] ?? '').toString(),
      country: resolvedCountry,
      city: resolvedCity,
      latitude: (row['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (row['longitude'] as num?)?.toDouble() ?? 0.0,
      description: resolvedDescription,
      categoryId: row['category_id']?.toString(),
      categorySlug: categorySlug,
      coverImageUrl: row['cover_image_url'] as String?,
      isPublished: (row['is_published'] as bool?) ?? true,
      createdBy: row['created_by']?.toString(),
      averageRating: (row['average_rating'] as num?)?.toDouble(),
      createdAt: row['created_at'] != null
          ? DateTime.tryParse(row['created_at'].toString())
          : null,
    );
  }

  /// İstemci/test tarafında mekan listesini [PlaceSearchFilter] kurallarına göre süzer.
  static List<PlaceEntity> applyFilter(
    List<PlaceEntity> source,
    PlaceSearchFilter filter, {
    String? currentUserId,
  }) {
    final query = filter.query.trim().toLowerCase();
    final country = filter.country?.trim().toLowerCase() ?? '';
    final city = filter.city?.trim().toLowerCase() ?? '';
    final categorySlug = filter.categorySlug?.trim().toLowerCase() ?? '';

    final filtered = source.where((place) {
      // Başka bir kullanıcının yayınlanmamış özel mekanı asla gösterilmez.
      if (!place.isPublished &&
          currentUserId != null &&
          place.createdBy != null &&
          place.createdBy != currentUserId) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchName = place.name.toLowerCase().contains(query);
        final matchCity = place.city.toLowerCase().contains(query);
        final matchCountry = place.country.toLowerCase().contains(query);
        final matchDesc =
            place.description?.toLowerCase().contains(query) ?? false;
        if (!matchName && !matchCity && !matchCountry && !matchDesc) {
          return false;
        }
      }
      if (country.isNotEmpty &&
          !place.country.toLowerCase().contains(country)) {
        return false;
      }
      if (city.isNotEmpty && !place.city.toLowerCase().contains(city)) {
        return false;
      }
      if (categorySlug.isNotEmpty &&
          (place.categorySlug?.toLowerCase() ?? '') != categorySlug) {
        return false;
      }
      if (filter.minRating != null &&
          (place.averageRating ?? 0) < filter.minRating!) {
        return false;
      }
      return true;
    }).toList();

    if (filter.sortAlphabetically) {
      filtered.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }
    return filtered;
  }
}

/// Uygulama genelinde kullanılan [ExploreRepository] bağımlılık sağlayıcısı.
final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseExploreRepository(client);
});
