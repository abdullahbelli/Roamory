import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/core/utils/travel_validators.dart';
import 'package:roamory/features/explore/data/repositories/supabase_explore_repository.dart';
import 'package:roamory/features/trips/domain/entities/trip_entity.dart';
import 'package:roamory/features/trips/domain/repositories/trips_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// [TripsRepository] sözleşmesinin Supabase `trips`, `trip_days`, `trip_stops`
/// ve `trip_checklist_items` implementasyonu.
class SupabaseTripsRepository implements TripsRepository {
  /// Supabase istemcisiyle repository oluşturur.
  const SupabaseTripsRepository(this._client);

  final sb.SupabaseClient? _client;

  sb.SupabaseClient get _requireClient {
    final client = _client;
    if (client == null) {
      throw const SupabaseNotConfiguredException();
    }
    return client;
  }

  @override
  Future<List<TripEntity>> fetchTrips(String userId) async {
    try {
      final rows = await _requireClient
          .from('trips')
          .select(
            '*, trip_days(*, trip_stops(*, places(*, categories(slug)))), trip_checklist_items(*)',
          )
          .eq('user_id', userId)
          .order('start_date', ascending: true);

      return (rows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(mapTripRow)
          .toList();
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<TripEntity> fetchTripById({
    required String tripId,
    required String userId,
  }) async {
    try {
      final row = await _requireClient
          .from('trips')
          .select(
            '*, trip_days(*, trip_stops(*, places(*, categories(slug)))), trip_checklist_items(*)',
          )
          .eq('id', tripId)
          .eq('user_id', userId)
          .maybeSingle();

      if (row == null) {
        throw const NotFoundAppException(code: 'trip_not_found');
      }
      return mapTripRow(row);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<TripEntity> upsertTrip(UpsertTripRequest request) async {
    try {
      // Başlık ve tarih sırası (`end_date >= start_date`) doğrulaması.
      TravelValidators.validateTripRequest(request);

      final client = _requireClient;
      final sessionUserId = client.auth.currentUser?.id;
      if (sessionUserId == null || sessionUserId.isEmpty) {
        throw const UnauthorizedAppException(code: 'auth_session_missing');
      }
      if (sessionUserId != request.userId) {
        throw const UnauthorizedAppException(code: 'auth_uid_mismatch');
      }

      final isNew = request.tripId == null;
      final trimmedCountry = request.country?.trim();
      final trimmedCity = request.city?.trim();
      final updatePayload = <String, dynamic>{
        'title': request.title.trim(),
        // Canlı trips tablosunda ülke kolonu `country_code` olarak tanımlıdır.
        'country_code': trimmedCountry != null && trimmedCountry.isNotEmpty
            ? SupabaseExploreRepository.normalizeCountryCode(trimmedCountry)
            : null,
        'city': (trimmedCity != null && trimmedCity.isNotEmpty)
            ? TravelValidators.normalizeCityName(trimmedCity)
            : null,
        'description': request.description?.trim(),
        if (request.startDate != null)
          'start_date': request.startDate!.toIso8601String().split('T').first,
        if (request.endDate != null)
          'end_date': request.endDate!.toIso8601String().split('T').first,
        'status': request.status.dbValue,
      };
      final insertPayload = <String, dynamic>{
        'user_id': request.userId,
        ...updatePayload,
      };

      // RLS politikalarında INSERT ve UPDATE yetkilerini ayrı çalıştırmak için
      // yeni kayıtta insert, düzenlemede yalnızca mevcut satıra update uyguluyoruz.
      final Map<String, dynamic> saved = isNew
          ? await client
                .from('trips')
                .insert(insertPayload)
                .select('id')
                .single()
          : await client
                .from('trips')
                .update(updatePayload)
                .eq('id', request.tripId!)
                .eq('user_id', request.userId)
                .select('id')
                .single();
      final tripId = saved['id'].toString();

      if (isNew) {
        // Yeni oluşturulan seyahatlerde tarih aralığına göre `trip_days` satırlarını üretiriz.
        // Canlı `trip_days` şemasında `day_date`, `title`, `notes` kolonları bulunur.
        final dayDates = TravelValidators.generateTripDayDates(
          request.startDate,
          request.endDate,
        );
        final baseDate = request.startDate ?? DateTime.now();
        final dayPayloads = <Map<String, dynamic>>[];
        for (var i = 0; i < dayDates.length; i++) {
          final effectiveDate = dayDates[i] ?? baseDate.add(Duration(days: i));
          dayPayloads.add({
            'trip_id': tripId,
            'day_date': effectiveDate.toIso8601String().split('T').first,
            'title': '${i + 1}. Gün',
          });
        }
        await client.from('trip_days').insert(dayPayloads);
      } else {
        // Düzenleme modunda mevcut günler, duraklar ve kontrol listesi KESİNLİKLE
        // silinmez. Tarih aralığı mevcut gün sayısından daha uzun hale getirilmişse
        // yalnızca eksik kalan ek günler sırayla sona eklenir.
        final existingTrip = await fetchTripById(
          tripId: tripId,
          userId: request.userId,
        );
        final missingDayPayloads = buildMissingDaysForExtendedTrip(
          tripId: tripId,
          existingDays: existingTrip.days,
          newStartDate: request.startDate,
          newEndDate: request.endDate,
        );
        if (missingDayPayloads.isNotEmpty) {
          await client.from('trip_days').insert(missingDayPayloads);
        }
      }

      return await fetchTripById(tripId: tripId, userId: request.userId);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> deleteTrip({
    required String tripId,
    required String userId,
  }) async {
    try {
      await _requireClient
          .from('trips')
          .delete()
          .eq('id', tripId)
          .eq('user_id', userId);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  /// Tarih bilgisini Supabase `DATE` kolonu için `YYYY-MM-DD` biçimine çevirir.
  static String _formatDateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Tarih alanını saat bilgisinden arındırarak gün bazlı karşılaştırmaya hazırlar.
  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  Future<TripDayEntity> addTripDay({
    required String tripId,
    required int dayNumber,
    DateTime? dayDate,
    String? title,
  }) async {
    try {
      final client = _requireClient;
      final sessionUserId = client.auth.currentUser?.id;
      if (sessionUserId == null || sessionUserId.isEmpty) {
        throw const UnauthorizedAppException(code: 'auth_session_missing');
      }

      // Canlı `trip_days` RLS politikası `day_date` değerinin `trips` tarih
      // aralığıyla (`start_date`..`end_date`) uyumlu olmasını şart koşar.
      // Önce üst seyahatin sahipliğini ve mevcut tarih sınırlarını okuyoruz.
      final tripRow = await client
          .from('trips')
          .select('id, user_id, start_date, end_date')
          .eq('id', tripId)
          .eq('user_id', sessionUserId)
          .maybeSingle();

      if (tripRow == null) {
        throw const NotFoundAppException(code: 'trip_not_found');
      }

      final effectiveDate = _dateOnly(dayDate ?? DateTime.now());
      final effectiveDateStr = _formatDateOnly(effectiveDate);
      final currentStartRaw = tripRow['start_date'] as String?;
      final currentEndRaw = tripRow['end_date'] as String?;
      final currentStart = currentStartRaw != null
          ? DateTime.tryParse(currentStartRaw)
          : null;
      final currentEnd = currentEndRaw != null
          ? DateTime.tryParse(currentEndRaw)
          : null;

      final tripDateUpdates = <String, dynamic>{};
      final rollbackPayload = <String, dynamic>{};

      if (currentStart == null ||
          effectiveDate.isBefore(_dateOnly(currentStart))) {
        tripDateUpdates['start_date'] = effectiveDateStr;
        rollbackPayload['start_date'] = currentStartRaw;
      }
      if (currentEnd == null || effectiveDate.isAfter(_dateOnly(currentEnd))) {
        tripDateUpdates['end_date'] = effectiveDateStr;
        rollbackPayload['end_date'] = currentEndRaw;
      }

      if (tripDateUpdates.isNotEmpty) {
        // Yeni gün mevcut `end_date` (veya `start_date`) dışına taşıyorsa önce
        // seyahatin tarih sınırını güvenli biçimde genişletiriz; mevcut günler,
        // duraklar ve kontrol listesi bu güncellemede kesinlikle korunur.
        await client
            .from('trips')
            .update(tripDateUpdates)
            .eq('id', tripId)
            .eq('user_id', sessionUserId);
      }

      try {
        final row = await client
            .from('trip_days')
            .insert({
              'trip_id': tripId,
              'day_date': effectiveDateStr,
              'title': (title != null && title.trim().isNotEmpty)
                  ? title.trim()
                  : '$dayNumber. Gün',
            })
            .select('*, trip_stops(*, places(*, categories(slug)))')
            .single();

        return mapTripDayRow(row, fallbackDayNumber: dayNumber);
      } catch (insertError) {
        // Gün ekleme başarısız olursa `trips` tarih aralığını eski değerine
        // geri alarak yarım güncellenmiş tarih durumu bırakmıyoruz.
        if (rollbackPayload.isNotEmpty) {
          try {
            await client
                .from('trips')
                .update(rollbackPayload)
                .eq('id', tripId)
                .eq('user_id', sessionUserId);
          } catch (_) {
            // Geri alma başarısız olsa bile asıl PostgREST hatasını raporlarız.
          }
        }
        rethrow;
      }
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<TripDayEntity> updateTripDay({
    required String tripDayId,
    String? title,
    String? notes,
  }) async {
    try {
      final client = _requireClient;
      final sessionUserId = client.auth.currentUser?.id;
      if (sessionUserId == null || sessionUserId.isEmpty) {
        throw const UnauthorizedAppException(code: 'auth_session_missing');
      }

      final row = await client
          .from('trip_days')
          .update({'title': title?.trim(), 'notes': notes?.trim()})
          .eq('id', tripDayId)
          .select('*, trip_stops(*, places(*, categories(slug)))')
          .single();

      return mapTripDayRow(row);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<TripStopEntity> addTripStop({
    required String tripDayId,
    required String placeId,
    required int orderIndex,
    String? notes,
    String? arrivalTime,
  }) async {
    try {
      // Canlı `trip_stops` tablosu sıralama için `sort_order`, saat için `planned_time` kullanır.
      final row = await _requireClient
          .from('trip_stops')
          .insert({
            'trip_day_id': tripDayId,
            'place_id': placeId,
            'sort_order': orderIndex,
            if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
            if (arrivalTime != null && arrivalTime.trim().isNotEmpty)
              'planned_time': arrivalTime.trim(),
          })
          .select('*, places(*, categories(slug))')
          .single();

      return mapTripStopRow(row);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<List<TripStopEntity>> reorderTripStops({
    required String tripDayId,
    required List<String> orderedStopIds,
  }) async {
    try {
      final client = _requireClient;
      final updated = <TripStopEntity>[];
      for (var index = 0; index < orderedStopIds.length; index++) {
        final row = await client
            .from('trip_stops')
            .update({'sort_order': index})
            .eq('id', orderedStopIds[index])
            .eq('trip_day_id', tripDayId)
            .select('*, places(*, categories(slug))')
            .single();
        updated.add(mapTripStopRow(row));
      }
      return updated;
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> deleteTripStop(String stopId) async {
    try {
      await _requireClient.from('trip_stops').delete().eq('id', stopId);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<TripChecklistItemEntity> addChecklistItem({
    required String tripId,
    required String title,
    String category = TripChecklistCategory.general,
    int sortOrder = 0,
  }) async {
    try {
      final client = _requireClient;
      final sessionUserId = client.auth.currentUser?.id;
      if (sessionUserId == null || sessionUserId.isEmpty) {
        throw const UnauthorizedAppException(code: 'auth_session_missing');
      }
      if (title.trim().isEmpty) {
        throw const ValidationAppException(code: 'checklist_title_required');
      }
      // Yerelleştirilmiş etiketlerin ("Genel Hazırlık" vb.) veritabanına
      // sızmaması için yalnızca kanonik İngilizce kısa kodlara izin veriyoruz.
      final normalizedCategory = category.trim().toLowerCase();
      if (!TripChecklistCategory.isValid(normalizedCategory)) {
        throw const ValidationAppException(code: 'checklist_invalid_category');
      }

      final row = await client
          .from('trip_checklist_items')
          .insert({
            'trip_id': tripId,
            'title': title.trim(),
            'category': normalizedCategory,
            'is_completed': false,
            'sort_order': sortOrder,
          })
          .select()
          .single();

      return mapChecklistRow(row);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<TripChecklistItemEntity> updateChecklistItem({
    required String itemId,
    bool? isCompleted,
    String? title,
    String? category,
  }) async {
    try {
      final row = await _requireClient
          .from('trip_checklist_items')
          .update({
            'is_completed': ?isCompleted,
            if (title != null) 'title': title.trim(),
            'category': ?category,
          })
          .eq('id', itemId)
          .select()
          .single();

      return mapChecklistRow(row);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> deleteChecklistItem(String itemId) async {
    try {
      await _requireClient
          .from('trip_checklist_items')
          .delete()
          .eq('id', itemId);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  /// Düzenlenen seyahatin tarih aralığı mevcut gün sayısından uzunsa yalnızca eksik
  /// kalan yeni günler için `trip_days` ekleme yükünü üretir; mevcut günlere
  /// ve tarih aralığı kısaldığında mevcut kayıtlara dokunmaz.
  static List<Map<String, dynamic>> buildMissingDaysForExtendedTrip({
    required String tripId,
    required List<TripDayEntity> existingDays,
    DateTime? newStartDate,
    DateTime? newEndDate,
  }) {
    if (newStartDate == null ||
        newEndDate == null ||
        newEndDate.isBefore(newStartDate)) {
      return const [];
    }
    final targetDates = TravelValidators.generateTripDayDates(
      newStartDate,
      newEndDate,
    ).whereType<DateTime>().toList();

    if (targetDates.length <= existingDays.length) {
      return const [];
    }

    final existingDateKeys = <String>{
      for (final day in existingDays)
        if (day.dayDate != null)
          day.dayDate!.toIso8601String().split('T').first,
    };

    var cursorDate =
        existingDays.lastOrNull?.dayDate ??
        newStartDate.subtract(const Duration(days: 1));
    final missingCount = targetDates.length - existingDays.length;
    final payloads = <Map<String, dynamic>>[];

    for (var i = 0; i < missingCount; i++) {
      // Çakışmayan bir sonraki tarihi hesapla.
      do {
        cursorDate = cursorDate.add(const Duration(days: 1));
      } while (existingDateKeys.contains(
        cursorDate.toIso8601String().split('T').first,
      ));

      final dateKey = cursorDate.toIso8601String().split('T').first;
      existingDateKeys.add(dateKey);
      final dayNumber = existingDays.length + i + 1;
      payloads.add({
        'trip_id': tripId,
        'day_date': dateKey,
        'title': '$dayNumber. Gün',
      });
    }
    return payloads;
  }

  /// Supabase `trips` satırını [TripEntity] varlığına dönüştürür.
  static TripEntity mapTripRow(Map<String, dynamic> row) {
    final daysRaw = row['trip_days'];
    final days = <TripDayEntity>[];
    if (daysRaw is List<dynamic>) {
      final rawList = daysRaw.whereType<Map<String, dynamic>>().toList();
      // Canlı trip_days tablosunda sıralamayı day_date (veya varsa day_number) üzerinden yaparız.
      rawList.sort((a, b) {
        final numA = (a['day_number'] as num?)?.toInt();
        final numB = (b['day_number'] as num?)?.toInt();
        if (numA != null && numB != null) {
          return numA.compareTo(numB);
        }
        final dateA = (a['day_date'] ?? '').toString();
        final dateB = (b['day_date'] ?? '').toString();
        return dateA.compareTo(dateB);
      });
      for (var index = 0; index < rawList.length; index++) {
        days.add(mapTripDayRow(rawList[index], fallbackDayNumber: index + 1));
      }
    }

    final checklistRaw = row['trip_checklist_items'];
    final checklist = <TripChecklistItemEntity>[];
    if (checklistRaw is List<dynamic>) {
      for (final c in checklistRaw.whereType<Map<String, dynamic>>()) {
        checklist.add(mapChecklistRow(c));
      }
      // Uygulama yeniden açıldığında kontrol listesi sırası bozulmasın diye
      // `sort_order` alanına göre kararlı sıralama uyguluyoruz.
      checklist.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return TripEntity(
      id: (row['id'] ?? '').toString(),
      userId: (row['user_id'] ?? '').toString(),
      title: (row['title'] ?? '').toString(),
      country: (row['country'] ?? row['country_code']) as String?,
      city: row['city'] as String?,
      description: row['description'] as String?,
      startDate: row['start_date'] != null
          ? DateTime.tryParse(row['start_date'].toString())
          : null,
      endDate: row['end_date'] != null
          ? DateTime.tryParse(row['end_date'].toString())
          : null,
      status: TripStatus.fromDb(row['status'] as String?),
      coverImageUrl: row['cover_image_url'] as String?,
      days: days,
      checklist: checklist,
    );
  }

  /// Supabase `trip_days` satırını [TripDayEntity] varlığına dönüştürür.
  static TripDayEntity mapTripDayRow(
    Map<String, dynamic> row, {
    int fallbackDayNumber = 1,
  }) {
    final stopsRaw = row['trip_stops'];
    final stops = <TripStopEntity>[];
    if (stopsRaw is List<dynamic>) {
      for (final s in stopsRaw.whereType<Map<String, dynamic>>()) {
        stops.add(mapTripStopRow(s));
      }
      stops.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    }

    return TripDayEntity(
      id: (row['id'] ?? '').toString(),
      tripId: (row['trip_id'] ?? '').toString(),
      dayNumber: (row['day_number'] as num?)?.toInt() ?? fallbackDayNumber,
      dayDate: row['day_date'] != null
          ? DateTime.tryParse(row['day_date'].toString())
          : null,
      title: row['title'] as String?,
      notes: row['notes'] as String?,
      stops: stops,
    );
  }

  /// Supabase `trip_stops` satırını [TripStopEntity] varlığına dönüştürür.
  static TripStopEntity mapTripStopRow(Map<String, dynamic> row) {
    final placeRaw = row['places'];
    final place = placeRaw is Map<String, dynamic>
        ? SupabaseExploreRepository.mapPlaceRow(placeRaw)
        : null;

    return TripStopEntity(
      id: (row['id'] ?? '').toString(),
      tripDayId: (row['trip_day_id'] ?? '').toString(),
      placeId: (row['place_id'] ?? '').toString(),
      orderIndex:
          ((row['sort_order'] ?? row['order_index']) as num?)?.toInt() ?? 0,
      notes: row['notes'] as String?,
      arrivalTime: (row['planned_time'] ?? row['arrival_time']) as String?,
      place: place,
    );
  }

  /// Supabase `trip_checklist_items` satırını [TripChecklistItemEntity] varlığına dönüştürür.
  static TripChecklistItemEntity mapChecklistRow(Map<String, dynamic> row) {
    return TripChecklistItemEntity(
      id: (row['id'] ?? '').toString(),
      tripId: (row['trip_id'] ?? '').toString(),
      title: (row['title'] ?? '').toString(),
      category: TripChecklistCategory.normalize(row['category'] as String?),
      isCompleted: (row['is_completed'] as bool?) ?? false,
      sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Uygulama genelinde kullanılan [TripsRepository] bağımlılık sağlayıcısı.
final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseTripsRepository(client);
});
