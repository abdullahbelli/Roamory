import 'package:roamory/features/explore/domain/entities/place_entity.dart';

/// Keşfet, kategori listeleme ve mekan arama işlemleri için domain sözleşmesi.
///
/// Presentation katmanı yalnızca bu arayüzle konuşur; Supabase `places` ve
/// `categories` sorguları `data` katmanında uygulanır.
abstract interface class ExploreRepository {
  /// `public.categories` tablosundaki tüm deneyim kategorilerini getirir.
  Future<List<CategoryEntity>> fetchCategories();

  /// Verilen [filter] kriterlerine uyan yayınlanmış (`is_published=true`) veya
  /// kullanıcının kendisine ait özel mekanları getirir.
  Future<List<PlaceEntity>> fetchPlaces({
    PlaceSearchFilter filter = const PlaceSearchFilter(),
    String? currentUserId,
  });

  /// Tek bir mekanın detay bilgisini kimliğine göre getirir.
  Future<PlaceEntity> fetchPlaceById(String placeId);

  /// Kullanıcının kendi haritası/ziyareti için yeni özel mekan (`is_published=false`) oluşturur.
  Future<PlaceEntity> createPrivatePlace(CreatePrivatePlaceRequest request);
}
