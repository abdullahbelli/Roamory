import 'package:flutter/foundation.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';

/// `public.visit_photos` tablosuna karşılık gelen ziyaret fotoğrafı varlığı.
///
/// Fotoğraflar `visit-photos` private Storage bucket'ında `userUUID/visitUUID/dosya`
/// yolunda saklanır ve görüntüleme için süreli imzalı URL (`signedUrl`) kullanılır.
@immutable
class VisitPhotoEntity {
  /// Ziyaret fotoğrafı varlığı oluşturur.
  const VisitPhotoEntity({
    required this.id,
    required this.visitId,
    required this.storagePath,
    this.signedUrl,
    this.caption,
    this.sortOrder = 0,
  });

  /// Fotoğraf metadata kimliği (`visit_photos.id`).
  final String id;

  /// Bağlı olduğu ziyaret kimliği (`visits.id`).
  final String visitId;

  /// Storage içindeki nesne yolu (`userUUID/visitUUID/file.ext`).
  final String storagePath;

  /// Görüntüleme için üretilen geçici imzalı URL.
  final String? signedUrl;

  /// İsteğe bağlı fotoğraf altı açıklaması.
  final String? caption;

  /// Galeri sıralama indeksi.
  final int sortOrder;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisitPhotoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          visitId == other.visitId &&
          storagePath == other.storagePath;

  @override
  int get hashCode => Object.hash(id, visitId, storagePath);
}

/// `public.visits` tablosuna karşılık gelen kişisel ziyaret ve gezi günlüğü varlığı.
///
/// `AGENTS.md` ve `database.md` kuralları gereği tüm ziyaret kayıtları varsayılan
/// olarak kullanıcıya özeldir (`visibility = 'private'`). Toplulukta paylaşım
/// yalnızca `posts` tablosuna açık dönüşümle (`C06` -> `E02`) gerçekleşir.
@immutable
class VisitEntity {
  /// Ziyaret ve günlük varlığı oluşturur.
  const VisitEntity({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.visitedAt,
    this.title,
    this.notes,
    this.rating,
    this.visibility = 'private',
    this.place,
    this.photos = const [],
    this.categorySlugs = const [],
    this.createdAt,
  });

  /// Ziyaret kimliği (`visits.id`).
  final String id;

  /// Ziyaret sahibi kullanıcı kimliği (`auth.uid()`).
  final String userId;

  /// Ziyaret edilen mekan kimliği (`places.id`).
  final String placeId;

  /// Ziyaret tarihi.
  final DateTime visitedAt;

  /// Günlük anı başlığı.
  final String? title;

  /// Kişisel gezi günlüğü metni.
  final String? notes;

  /// Kişisel değerlendirme puanı (`1`..`5`).
  final int? rating;

  /// Görünürlük durumu (`private` varsayılan).
  final String visibility;

  /// İlişkili mekan bilgisi.
  final PlaceEntity? place;

  /// Ziyarete ait fotoğraflar (`visit_photos`).
  final List<VisitPhotoEntity> photos;

  /// Ziyaretle ilişkilendirilmiş kategori kısa kodları (`visit_categories`).
  final List<String> categorySlugs;

  /// Kayıt oluşturulma zamanı.
  final DateTime? createdAt;

  /// Ziyaretin 4 veya 5 yıldızlı kişisel favori olup olmadığını döndürür.
  bool get isFavorite => (rating ?? 0) >= 4;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisitEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          placeId == other.placeId &&
          visitedAt == other.visitedAt &&
          title == other.title &&
          notes == other.notes &&
          rating == other.rating;

  @override
  int get hashCode =>
      Object.hash(id, userId, placeId, visitedAt, title, notes, rating);
}

/// Ziyaret fotoğrafı yükleme isteği.
@immutable
class VisitPhotoUploadPayload {
  /// Fotoğraf yükleme verisi oluşturur.
  const VisitPhotoUploadPayload({
    required this.bytes,
    required this.fileExtension,
    this.caption,
  });

  /// Görselin ham baytları (`<= 10 MB`).
  final Uint8List bytes;

  /// Dosya uzantısı (`jpg`, `jpeg`, `png`, `webp`).
  final String fileExtension;

  /// İsteğe bağlı açıklama.
  final String? caption;
}

/// Yeni ziyaret ve günlük oluşturma/güncelleme isteği.
@immutable
class UpsertVisitRequest {
  /// Ziyaret kaydetme isteği oluşturur.
  const UpsertVisitRequest({
    this.visitId,
    required this.userId,
    this.placeId,
    this.customPlace,
    required this.visitedAt,
    this.rating,
    this.title,
    this.notes,
    this.categorySlugs = const [],
    this.newPhotos = const [],
  });

  /// Güncelleme işleminde mevcut ziyaretin kimliği; yeni kayıtta `null`.
  final String? visitId;

  /// Kullanıcı kimliği (`auth.uid()`).
  final String userId;

  /// Mevcut katalog/özel mekanlardan seçilen mekan kimliği.
  final String? placeId;

  /// Katalogda olmayan yeni özel mekan oluşturulacaksa bilgileri.
  final CreatePrivatePlaceRequest? customPlace;

  /// Ziyaret tarihi.
  final DateTime visitedAt;

  /// 1 ile 5 arası kişisel puan.
  final int? rating;

  /// Günlük başlığı.
  final String? title;

  /// Kişisel günlük notu.
  final String? notes;

  /// Seçilen deneyim kategorisi kısa kodları.
  final List<String> categorySlugs;

  /// Yüklenecek yeni fotoğraflar.
  final List<VisitPhotoUploadPayload> newPhotos;
}
