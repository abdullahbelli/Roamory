import 'package:roamory/features/trips/domain/entities/trip_entity.dart';

/// Seyahat planlama (`trips`, `trip_days`, `trip_stops`, `trip_checklist_items`) sözleşmesi.
abstract interface class TripsRepository {
  /// Kullanıcının tüm seyahat planlarını günleri, durakları ve kontrol listesiyle getirir.
  Future<List<TripEntity>> fetchTrips(String userId);

  /// Tek bir seyahat planının detaylarını getirir.
  Future<TripEntity> fetchTripById({
    required String tripId,
    required String userId,
  });

  /// Yeni seyahat planı oluşturur veya mevcut planı günceller.
  ///
  /// Yeni oluşturulan seyahatte başlangıç ve bitiş tarihlerine uygun `trip_days`
  /// satırları otomatik üretilir.
  Future<TripEntity> upsertTrip(UpsertTripRequest request);

  /// Seyahat planını ve alt kayıtlarını siler.
  Future<void> deleteTrip({required String tripId, required String userId});

  /// Mevcut seyahat planına yeni bir gün (`trip_days`) ekler.
  Future<TripDayEntity> addTripDay({
    required String tripId,
    required int dayNumber,
    DateTime? dayDate,
    String? title,
  });

  /// Belirli bir seyahat gününün başlık veya notunu günceller.
  Future<TripDayEntity> updateTripDay({
    required String tripDayId,
    String? title,
    String? notes,
  });

  /// Belirli bir güne yeni durak (`trip_stops`) ekler.
  Future<TripStopEntity> addTripStop({
    required String tripDayId,
    required String placeId,
    required int orderIndex,
    String? notes,
    String? arrivalTime,
  });

  /// Gün içindeki durakların sıralamasını (`order_index`) günceller.
  Future<List<TripStopEntity>> reorderTripStops({
    required String tripDayId,
    required List<String> orderedStopIds,
  });

  /// Bir durağı siler.
  Future<void> deleteTripStop(String stopId);

  /// Seyahat kontrol listesine yeni madde ekler.
  Future<TripChecklistItemEntity> addChecklistItem({
    required String tripId,
    required String title,
    String category = TripChecklistCategory.general,
    int sortOrder = 0,
  });

  /// Kontrol listesi maddesinin tamamlanma durumunu veya başlığını günceller.
  Future<TripChecklistItemEntity> updateChecklistItem({
    required String itemId,
    bool? isCompleted,
    String? title,
    String? category,
  });

  /// Kontrol listesi maddesini siler.
  Future<void> deleteChecklistItem(String itemId);
}
