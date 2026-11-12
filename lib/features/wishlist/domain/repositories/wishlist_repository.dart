import 'package:roamory/features/wishlist/domain/entities/wishlist_item_entity.dart';

/// Kullanıcının kişisel istek listesi (`wishlist_items`) sözleşmesi.
abstract interface class WishlistRepository {
  /// Kullanıcının kaydettiği tüm istek listesi mekanlarını getirir.
  Future<List<WishlistItemEntity>> fetchWishlist(String userId);

  /// Bir mekanı istek listesine ekler; zaten varsa mevcut kaydı döndürür (`unique(user_id, place_id)`).
  Future<WishlistItemEntity> addToWishlist({
    required String userId,
    required String placeId,
    String? note,
  });

  /// İstek listesindeki mekan notunu günceller.
  Future<WishlistItemEntity> updateWishlistNote({
    required String itemId,
    required String userId,
    String? note,
  });

  /// Mekanı kullanıcının istek listesinden kaldırır.
  Future<void> removeFromWishlist({
    required String userId,
    required String placeId,
  });
}
