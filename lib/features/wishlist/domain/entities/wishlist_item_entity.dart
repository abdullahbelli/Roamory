import 'package:flutter/foundation.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';

/// `public.wishlist_items` tablosuna karşılık gelen istek listesi kaydı varlığı.
///
/// Kullanıcının gelecekte ziyaret etmek üzere kaydettiği mekanı (`PlaceEntity`)
/// ve kişisel kısa notunu tutar. Veritabanında `(user_id, place_id)` tekildir.
@immutable
class WishlistItemEntity {
  /// İstek listesi öğesi oluşturur.
  const WishlistItemEntity({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.createdAt,
    this.note,
    this.place,
  });

  /// Kayıt kimliği (`wishlist_items.id`).
  final String id;

  /// Kaydı oluşturan kullanıcı kimliği (`auth.uid()`).
  final String userId;

  /// Kaydedilen mekan kimliği (`places.id`).
  final String placeId;

  /// Kaydedilme tarihi.
  final DateTime createdAt;

  /// Kullanıcının mekana özel kısa notu.
  final String? note;

  /// İlişkili mekan detay bilgisi.
  final PlaceEntity? place;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          placeId == other.placeId &&
          note == other.note;

  @override
  int get hashCode => Object.hash(id, userId, placeId, note);
}
