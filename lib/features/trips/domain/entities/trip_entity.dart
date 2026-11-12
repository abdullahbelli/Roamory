import 'package:flutter/foundation.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';

/// Seyahat planının durumunu (`trips.status`) temsil eder.
enum TripStatus {
  /// Gelecek için planlanan seyahat.
  planned('planned'),

  /// Şu anda devam eden aktif seyahat.
  ongoing('ongoing'),

  /// Tamamlanmış seyahat.
  completed('completed');

  const TripStatus(this.dbValue);

  /// Veritabanında saklanan metin karşılığı.
  final String dbValue;

  /// Veritabanı metninden [TripStatus] değerine dönüştürür.
  static TripStatus fromDb(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'ongoing' => TripStatus.ongoing,
      'completed' => TripStatus.completed,
      _ => TripStatus.planned,
    };
  }
}

/// `public.trip_stops` tablosuna karşılık gelen günlük seyahat durağı varlığı.
@immutable
class TripStopEntity {
  /// Seyahat durağı varlığı oluşturur.
  const TripStopEntity({
    required this.id,
    required this.tripDayId,
    required this.placeId,
    required this.orderIndex,
    this.notes,
    this.arrivalTime,
    this.place,
  });

  /// Durak kimliği (`trip_stops.id`).
  final String id;

  /// Bağlı olduğu gün kimliği (`trip_days.id`).
  final String tripDayId;

  /// İlişkili mekan kimliği (`places.id`).
  final String placeId;

  /// Gün içindeki sıralama indeksi (`0, 1, 2...`).
  final int orderIndex;

  /// Durağa özel not.
  final String? notes;

  /// Planlanan saat/zaman bilgisi.
  final String? arrivalTime;

  /// İlişkili mekan bilgisi.
  final PlaceEntity? place;

  /// Seçili alanları güncelleyerek yeni bir durak kopyası döndürür.
  TripStopEntity copyWith({
    int? orderIndex,
    String? notes,
    String? arrivalTime,
    PlaceEntity? place,
  }) {
    return TripStopEntity(
      id: id,
      tripDayId: tripDayId,
      placeId: placeId,
      orderIndex: orderIndex ?? this.orderIndex,
      notes: notes ?? this.notes,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      place: place ?? this.place,
    );
  }
}

/// `public.trip_days` tablosuna karşılık gelen seyahat günü varlığı.
@immutable
class TripDayEntity {
  /// Seyahat günü varlığı oluşturur.
  const TripDayEntity({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    this.dayDate,
    this.title,
    this.notes,
    this.stops = const [],
  });

  /// Gün kimliği (`trip_days.id`).
  final String id;

  /// Bağlı olduğu seyahat kimliği (`trips.id`).
  final String tripId;

  /// Kaçıncı gün olduğu (`1, 2, 3...`).
  final int dayNumber;

  /// Varsa günün takvim tarihi.
  final DateTime? dayDate;

  /// Günün teması veya başlığı.
  final String? title;

  /// Günlük plan notu.
  final String? notes;

  /// O güne ait sıralı duraklar (`trip_stops`).
  final List<TripStopEntity> stops;

  /// Seçili alanları güncelleyerek yeni bir gün kopyası döndürür.
  TripDayEntity copyWith({
    String? title,
    String? notes,
    List<TripStopEntity>? stops,
  }) {
    return TripDayEntity(
      id: id,
      tripId: tripId,
      dayNumber: dayNumber,
      dayDate: dayDate,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      stops: stops ?? this.stops,
    );
  }
}

/// `public.trip_checklist_items.category` kolonu için kanonik kategori kodları.
///
/// Canlı Supabase `trip_checklist_items_category_check` kısıtının kabul ettiği
/// gerçek değerlerle (`documents`, `packing`, `bookings`, `other`) birebir
/// hizalıdır. Yerelleştirilmiş TR/EN arayüz etiketleri ARB dosyalarından gelir ve
/// asla veritabanına gönderilmez.
abstract final class TripChecklistCategory {
  /// Belgeler ve biletler kategorisi kodu (`documents`).
  static const String documents = 'documents';

  /// Bavul ve ekipman kategorisi kodu (`packing`).
  static const String packing = 'packing';

  /// Rezervasyonlar kategorisi kodu (`bookings`).
  static const String bookings = 'bookings';

  /// Genel hazırlık / diğer kategorisi kodu (`other` — varsayılan).
  static const String other = 'other';

  /// Canlı veritabanı CHECK kısıtının kabul ettiği kanonik kategori kodları.
  static const Set<String> values = <String>{
    documents,
    packing,
    bookings,
    other,
  };

  /// Verilen kodun canlı veritabanı CHECK kısıtıyla uyumlu olup olmadığını döndürür.
  static bool isValid(String? code) {
    if (code == null) return false;
    return values.contains(code.trim().toLowerCase());
  }

  /// Dış kaynaktan okunan kategori değerini canlı kanonik koda normalize eder.
  static String normalize(String? raw) {
    final normalized = (raw ?? '').trim().toLowerCase();
    return switch (normalized) {
      documents || 'docs' || 'document' => documents,
      packing || 'gear' || 'equip' || 'equipment' || 'clothing' => packing,
      bookings || 'booking' || 'hotel' || 'stay' || 'accommodation' => bookings,
      other || 'general' => other,
      _ => other,
    };
  }
}

/// `public.trip_checklist_items` tablosuna karşılık gelen hazırlık maddesi varlığı.
@immutable
class TripChecklistItemEntity {
  /// Kontrol listesi maddesi oluşturur.
  const TripChecklistItemEntity({
    required this.id,
    required this.tripId,
    required this.title,
    this.category = TripChecklistCategory.other,
    this.isCompleted = false,
    this.sortOrder = 0,
  });

  /// Madde kimliği (`trip_checklist_items.id`).
  final String id;

  /// Bağlı olduğu seyahat kimliği (`trips.id`).
  final String tripId;

  /// Hazırlık maddesi metni.
  final String title;

  /// Veritabanı kategori kodu (`documents`, `packing`, `bookings`, `other`).
  final String category;

  /// Tamamlanma durumu.
  final bool isCompleted;

  /// Liste içi sıralama indeksi (`trip_checklist_items.sort_order`).
  final int sortOrder;

  /// Tamamlanma, sıra veya başlık bilgisini güncelleyerek yeni örnek döndürür.
  TripChecklistItemEntity copyWith({
    String? title,
    String? category,
    bool? isCompleted,
    int? sortOrder,
  }) {
    return TripChecklistItemEntity(
      id: id,
      tripId: tripId,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// `public.trips` tablosuna karşılık gelen seyahat planı domain varlığı.
@immutable
class TripEntity {
  /// Seyahat planı varlığı oluşturur.
  const TripEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.country,
    this.city,
    this.description,
    this.startDate,
    this.endDate,
    this.status = TripStatus.planned,
    this.coverImageUrl,
    this.days = const [],
    this.checklist = const [],
  });

  /// Seyahat kimliği (`trips.id`).
  final String id;

  /// Seyahat sahibi kullanıcı kimliği (`auth.uid()`).
  final String userId;

  /// Seyahat başlığı.
  final String title;

  /// Hedef ülke.
  final String? country;

  /// Hedef şehir veya bölge.
  final String? city;

  /// Genel rota açıklaması.
  final String? description;

  /// Başlangıç tarihi.
  final DateTime? startDate;

  /// Bitiş tarihi.
  final DateTime? endDate;

  /// Seyahat durumu (`planned`, `ongoing`, `completed`).
  final TripStatus status;

  /// Varsa kapak fotoğrafı URL'si.
  final String? coverImageUrl;

  /// Seyahatin günleri (`trip_days`).
  final List<TripDayEntity> days;

  /// Seyahatin hazırlık listesi (`trip_checklist_items`).
  final List<TripChecklistItemEntity> checklist;

  /// Toplam gün sayısını başlangıç/bitiş tarihinden veya `days` listesinden hesaplar.
  int get totalDays {
    if (days.isNotEmpty) {
      return days.length;
    }
    if (startDate != null &&
        endDate != null &&
        !endDate!.isBefore(startDate!)) {
      return endDate!.difference(startDate!).inDays + 1;
    }
    return 1;
  }

  /// Tüm günlerdeki toplam durak sayısı.
  int get totalStops => days.fold<int>(0, (sum, day) => sum + day.stops.length);

  /// Tamamlanan kontrol listesi maddesi sayısı.
  int get completedChecklistCount =>
      checklist.where((item) => item.isCompleted).length;

  /// Şehir ve ülke bilgisini birleştirir.
  String get destinationLabel {
    final c = city?.trim() ?? '';
    final co = country?.trim() ?? '';
    if (c.isEmpty) {
      return co;
    }
    if (co.isEmpty) {
      return c;
    }
    return '$c, $co';
  }

  /// Seçili alanları güncelleyerek kopya üretir.
  TripEntity copyWith({
    String? title,
    String? country,
    String? city,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    TripStatus? status,
    List<TripDayEntity>? days,
    List<TripChecklistItemEntity>? checklist,
  }) {
    return TripEntity(
      id: id,
      userId: userId,
      title: title ?? this.title,
      country: country ?? this.country,
      city: city ?? this.city,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      coverImageUrl: coverImageUrl,
      days: days ?? this.days,
      checklist: checklist ?? this.checklist,
    );
  }
}

/// Yeni seyahat oluşturma veya mevcut seyahati güncelleme isteği.
@immutable
class UpsertTripRequest {
  /// Seyahat kaydetme isteği oluşturur.
  const UpsertTripRequest({
    this.tripId,
    required this.userId,
    required this.title,
    this.country,
    this.city,
    this.description,
    this.startDate,
    this.endDate,
    this.status = TripStatus.planned,
  });

  /// Güncellemede mevcut seyahat kimliği; yeni kayıtta `null`.
  final String? tripId;

  /// Kullanıcı kimliği (`auth.uid()`).
  final String userId;

  /// Seyahat başlığı.
  final String title;

  /// Hedef ülke.
  final String? country;

  /// Hedef şehir.
  final String? city;

  /// Rota açıklaması.
  final String? description;

  /// Başlangıç tarihi.
  final DateTime? startDate;

  /// Bitiş tarihi (`endDate >= startDate` kuralı doğrulanır).
  final DateTime? endDate;

  /// Seyahat durumu.
  final TripStatus status;
}
