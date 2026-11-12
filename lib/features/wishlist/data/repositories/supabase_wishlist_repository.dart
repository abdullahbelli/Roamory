import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/features/explore/data/repositories/supabase_explore_repository.dart';
import 'package:roamory/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:roamory/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// [WishlistRepository] sözleşmesinin Supabase `wishlist_items` implementasyonu.
///
/// `(user_id, place_id)` tekillik kısıtına uygun olarak upsert/insert ve silme
/// işlemlerini yürütür; ilişkili `places` kaydını birlikte okur.
class SupabaseWishlistRepository implements WishlistRepository {
  /// Supabase istemcisiyle repository oluşturur.
  const SupabaseWishlistRepository(this._client);

  final sb.SupabaseClient? _client;

  sb.SupabaseClient get _requireClient {
    final client = _client;
    if (client == null) {
      throw const SupabaseNotConfiguredException();
    }
    return client;
  }

  @override
  Future<List<WishlistItemEntity>> fetchWishlist(String userId) async {
    try {
      final rows = await _requireClient
          .from('wishlist_items')
          .select('*, places(*, categories(slug))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (rows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(mapWishlistRow)
          .toList();
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<WishlistItemEntity> addToWishlist({
    required String userId,
    required String placeId,
    String? note,
  }) async {
    try {
      // unique(user_id, place_id) kısıtını ihlal etmemek için upsert kullanıyoruz.
      // Canlı wishlist_items tablosunda not alanı `notes` kolonu olarak tanımlıdır.
      final row = await _requireClient
          .from('wishlist_items')
          .upsert({
            'user_id': userId,
            'place_id': placeId,
            if (note != null && note.trim().isNotEmpty) 'notes': note.trim(),
          }, onConflict: 'user_id,place_id')
          .select('*, places(*, categories(slug))')
          .single();

      return mapWishlistRow(row);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<WishlistItemEntity> updateWishlistNote({
    required String itemId,
    required String userId,
    String? note,
  }) async {
    try {
      final row = await _requireClient
          .from('wishlist_items')
          .update({'notes': note?.trim()})
          .eq('id', itemId)
          .eq('user_id', userId)
          .select('*, places(*, categories(slug))')
          .single();

      return mapWishlistRow(row);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> removeFromWishlist({
    required String userId,
    required String placeId,
  }) async {
    try {
      await _requireClient
          .from('wishlist_items')
          .delete()
          .eq('user_id', userId)
          .eq('place_id', placeId);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  /// Supabase `wishlist_items` satırını [WishlistItemEntity] varlığına dönüştürür.
  static WishlistItemEntity mapWishlistRow(Map<String, dynamic> row) {
    final placeMap = row['places'];
    final place = placeMap is Map<String, dynamic>
        ? SupabaseExploreRepository.mapPlaceRow(placeMap)
        : null;

    return WishlistItemEntity(
      id: (row['id'] ?? '').toString(),
      userId: (row['user_id'] ?? '').toString(),
      placeId: (row['place_id'] ?? '').toString(),
      note: (row['notes'] ?? row['note']) as String?,
      createdAt:
          DateTime.tryParse((row['created_at'] ?? '').toString()) ??
          DateTime.now(),
      place: place,
    );
  }
}

/// Uygulama genelinde kullanılan [WishlistRepository] bağımlılık sağlayıcısı.
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseWishlistRepository(client);
});
