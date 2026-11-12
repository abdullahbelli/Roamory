import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/community/domain/entities/post_entity.dart';
import 'package:roamory/features/explore/data/repositories/supabase_explore_repository.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';
import 'package:roamory/features/visits/domain/entities/visit_entity.dart';
import 'package:roamory/features/wishlist/data/repositories/supabase_wishlist_repository.dart';
import 'package:roamory/features/wishlist/domain/entities/wishlist_item_entity.dart';

/// Keşfet, arama filtreleri ve istek listesi durumunu birlikte temsil eder.
@immutable
class ExploreState {
  /// Keşfet durumu oluşturur.
  const ExploreState({
    this.isLoading = false,
    this.categories = const [],
    this.places = const [],
    this.wishlist = const [],
    this.filter = const PlaceSearchFilter(),
    this.error,
  });

  /// Yüklenme durumu.
  final bool isLoading;

  /// Katalog kategorileri (`categories`).
  final List<CategoryEntity> categories;

  /// Filtrelenmiş mekan listesi (`places`).
  final List<PlaceEntity> places;

  /// Kullanıcının istek listesi (`wishlist_items`).
  final List<WishlistItemEntity> wishlist;

  /// Aktif arama ve kategori filtresi.
  final PlaceSearchFilter filter;

  /// Varsa son işlem hatası.
  final AppException? error;

  /// Belirtilen mekanın kullanıcının istek listesinde olup olmadığını döndürür.
  bool isInWishlist(String placeId) =>
      wishlist.any((item) => item.placeId == placeId);

  /// Kimliğe göre mekanı mevcut önbellekten veya istek listesinden bulur.
  PlaceEntity? findPlaceById(String placeId) {
    for (final p in places) {
      if (p.id == placeId) {
        return p;
      }
    }
    for (final w in wishlist) {
      if (w.placeId == placeId && w.place != null) {
        return w.place;
      }
    }
    return null;
  }

  /// Mekan kartları (`B01`, `B02`, `B04`, `B05`) için gizlilik kurallarına uygun
  /// kapak görseli URL'sini çözümler:
  ///
  /// 1. Mekanın kendi `coverImageUrl` alanı doluysa onu döndürür.
  /// 2. Yalnızca oturumdaki kullanıcıya ait özel mekanlar (`isPublished == false`
  ///    ve `createdBy == currentUserId`) için, aynı kullanıcının kendi `visits`
  ///    listesindeki imzalı ziyaret fotoğrafını (`visit-photos` signed URL) kullanır.
  ///    Özel ziyaret fotoğrafları genel katalog mekanlarında veya başka bir
  ///    kullanıcıda ASLA kullanılmaz.
  /// 3. Genel katalog mekanları (veya özel fotoğrafı olmayan mekanlar) için
  ///    yalnızca herkese açık yayınlanmış (`status == 'published'`) topluluk
  ///    gönderilerinin (`post_photos`) imzalı URL'sini kullanır.
  /// 4. Uygun görsel yoksa `null` döner (`AppNetworkImage` placeholder gösterir).
  String? resolvePlaceCoverUrl(
    PlaceEntity? place, {
    List<VisitEntity> userVisits = const [],
    List<PostEntity> feedPosts = const [],
    String? currentUserId,
  }) {
    if (place == null) {
      return null;
    }
    if (place.coverImageUrl != null && place.coverImageUrl!.trim().isNotEmpty) {
      return place.coverImageUrl;
    }

    final cleanUserId = currentUserId?.trim() ?? '';
    if (!place.isPublished &&
        cleanUserId.isNotEmpty &&
        place.createdBy == cleanUserId) {
      for (final visit in userVisits) {
        if (visit.placeId != place.id || visit.userId != cleanUserId) {
          continue;
        }
        for (final photo in visit.photos) {
          final signed = photo.signedUrl?.trim();
          final path = photo.storagePath.trim();
          if (signed != null &&
              signed.isNotEmpty &&
              (path.isEmpty || path.startsWith('$cleanUserId/'))) {
            return signed;
          }
        }
      }
    }

    for (final post in feedPosts) {
      if (post.placeId != place.id || post.status != 'published') {
        continue;
      }
      for (final photo in post.photos) {
        final signed = photo.signedUrl?.trim();
        if (signed != null && signed.isNotEmpty) {
          return signed;
        }
      }
    }
    return null;
  }

  /// Seçili alanları güncelleyerek yeni bir durum kopyası üretir.
  ExploreState copyWith({
    bool? isLoading,
    List<CategoryEntity>? categories,
    List<PlaceEntity>? places,
    List<WishlistItemEntity>? wishlist,
    PlaceSearchFilter? filter,
    AppException? error,
    bool clearError = false,
  }) {
    return ExploreState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      places: places ?? this.places,
      wishlist: wishlist ?? this.wishlist,
      filter: filter ?? this.filter,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Keşfet, arama ve istek listesi işlemlerini yöneten Riverpod Notifier.
class ExploreController extends Notifier<ExploreState> {
  @override
  ExploreState build() {
    // Oturum açıldığında veya kapatıldığında mekan ve istek listesini yeniden yükleriz.
    ref.watch(authControllerProvider.select((s) => s.user?.id));
    Future.microtask(loadInitial);
    return const ExploreState(isLoading: true);
  }

  String get _currentUserId =>
      ref.read(authControllerProvider).user?.id ??
      ref.read(supabaseClientProvider)?.auth.currentUser?.id ??
      '';

  /// Kategorileri, mekanları ve kullanıcının istek listesini yükler.
  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final exploreRepo = ref.read(exploreRepositoryProvider);
      final wishlistRepo = ref.read(wishlistRepositoryProvider);
      final userId = _currentUserId;

      final categories = await exploreRepo.fetchCategories();
      if (!ref.mounted) return;
      final places = await exploreRepo.fetchPlaces(
        filter: state.filter,
        currentUserId: userId.isEmpty ? null : userId,
      );
      if (!ref.mounted) return;
      final wishlist = userId.isEmpty
          ? const <WishlistItemEntity>[]
          : await wishlistRepo.fetchWishlist(userId);
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoading: false,
        categories: categories,
        places: places,
        wishlist: wishlist,
        clearError: true,
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: ErrorMapper.map(error, stackTrace),
      );
    }
  }

  /// Arama veya kategori filtresini günceller ve mekanları yeniden sorgular.
  Future<void> updateFilter(PlaceSearchFilter newFilter) async {
    state = state.copyWith(
      filter: newFilter,
      isLoading: true,
      clearError: true,
    );
    try {
      final userId = _currentUserId;
      final places = await ref
          .read(exploreRepositoryProvider)
          .fetchPlaces(
            filter: newFilter,
            currentUserId: userId.isEmpty ? null : userId,
          );
      state = state.copyWith(isLoading: false, places: places);
    } catch (error, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorMapper.map(error, stackTrace),
      );
    }
  }

  /// Tüm arama filtrelerini sıfırlar.
  Future<void> resetFilters() => updateFilter(const PlaceSearchFilter());

  /// Mekanı istek listesine ekler veya listedeyse çıkarır (`B04`, `B05`).
  Future<bool> toggleWishlist(PlaceEntity place, {String? note}) async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      state = state.copyWith(error: const UnauthorizedAppException());
      return false;
    }

    final wishlistRepo = ref.read(wishlistRepositoryProvider);
    try {
      if (state.isInWishlist(place.id)) {
        await wishlistRepo.removeFromWishlist(
          userId: userId,
          placeId: place.id,
        );
        state = state.copyWith(
          wishlist: state.wishlist
              .where((item) => item.placeId != place.id)
              .toList(),
          clearError: true,
        );
        return false;
      } else {
        final added = await wishlistRepo.addToWishlist(
          userId: userId,
          placeId: place.id,
          note: note,
        );
        final resolvedItem = added.place != null
            ? added
            : WishlistItemEntity(
                id: added.id,
                userId: added.userId,
                placeId: added.placeId,
                createdAt: added.createdAt,
                note: added.note,
                place: place,
              );
        state = state.copyWith(
          wishlist: [resolvedItem, ...state.wishlist],
          clearError: true,
        );
        return true;
      }
    } catch (error, stackTrace) {
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// İstek listesindeki bir mekanın kişisel notunu günceller (`B05`).
  Future<bool> updateWishlistNote({
    required String itemId,
    String? note,
  }) async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      state = state.copyWith(error: const UnauthorizedAppException());
      return false;
    }
    try {
      final updated = await ref
          .read(wishlistRepositoryProvider)
          .updateWishlistNote(itemId: itemId, userId: userId, note: note);
      state = state.copyWith(
        wishlist: state.wishlist.map((item) {
          if (item.id != itemId) {
            return item;
          }
          return WishlistItemEntity(
            id: updated.id,
            userId: updated.userId,
            placeId: updated.placeId,
            createdAt: updated.createdAt,
            note: updated.note,
            place: updated.place ?? item.place,
          );
        }).toList(),
        clearError: true,
      );
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// Kullanıcının kendi haritası için yeni özel mekan (`is_published=false`) oluşturur.
  Future<PlaceEntity?> createPrivatePlace(
    CreatePrivatePlaceRequest request,
  ) async {
    try {
      final created = await ref
          .read(exploreRepositoryProvider)
          .createPrivatePlace(request);
      state = state.copyWith(
        places: [created, ...state.places],
        clearError: true,
      );
      return created;
    } catch (error, stackTrace) {
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
      return null;
    }
  }
}

/// Keşfet ve İstek Listesi durumunu sunan Riverpod sağlayıcısı.
final exploreControllerProvider =
    NotifierProvider<ExploreController, ExploreState>(ExploreController.new);
