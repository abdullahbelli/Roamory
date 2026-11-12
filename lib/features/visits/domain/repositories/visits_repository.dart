import 'package:roamory/features/visits/domain/entities/visit_entity.dart';

/// Kişisel ziyaret geçmişi, gezi günlüğü ve `visit-photos` Storage sözleşmesi.
///
/// Tüm ziyaretler varsayılan olarak kullanıcıya özeldir (`visibility = 'private'`).
/// Fotoğraf yükleme hatasında yetim (orphan) Storage nesneleri otomatik temizlenir.
abstract interface class VisitsRepository {
  /// Kullanıcının tüm ziyaret ve gezi günlüğü kayıtlarını en yeniden eskiye getirir.
  Future<List<VisitEntity>> fetchVisits(String userId);

  /// Tek bir ziyaretin tüm detaylarını, fotoğraflarını ve etiketlerini getirir.
  Future<VisitEntity> fetchVisitById({
    required String visitId,
    required String userId,
  });

  /// Yeni bir ziyaret oluşturur veya mevcut ziyareti günceller.
  ///
  /// İsteğin içinde `customPlace` varsa önce özel mekanı oluşturur, ardından
  /// `visits`, `visit_categories` ve `visit_photos` kayıtlarını tamamlar.
  Future<VisitEntity> upsertVisit(UpsertVisitRequest request);

  /// Ziyareti ve ona bağlı `visit-photos` Storage dosyalarını kalıcı olarak siler.
  Future<void> deleteVisit({required String visitId, required String userId});
}
