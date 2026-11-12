import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/core/utils/travel_validators.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/explore/presentation/providers/explore_controller.dart';
import 'package:roamory/features/visits/data/repositories/supabase_visits_repository.dart';
import 'package:roamory/features/visits/domain/entities/visit_entity.dart';

/// Harita (`C01`, `C02`) üzerindeki pin katmanı filtresini belirler.
enum MapLayerFilter {
  /// Hem ziyaret edilen hem de istek listesindeki mekanları gösterir.
  all,

  /// Yalnızca kişisel ziyaretleri (`visits`) gösterir.
  visited,

  /// Yalnızca istek listesini (`wishlist_items`) gösterir.
  wishlist,
}

/// Harita ve Ziyaret Geçmişi ekranlarında kullanılan filtre durumu (`C02`).
@immutable
class MapAndVisitFilter {
  /// Harita ve ziyaret filtresi oluşturur.
  const MapAndVisitFilter({
    this.layer = MapLayerFilter.all,
    this.onlyFavorites = false,
    this.year,
    this.country,
    this.categorySlug,
    this.searchQuery = '',
  });

  /// Seçili pin katmanı (`Tümü`, `Ziyaretlerim`, `İstek Listem`).
  final MapLayerFilter layer;

  /// Yalnızca 4+ yıldızlı kişisel favorileri göster.
  final bool onlyFavorites;

  /// Belirli bir ziyaret yılı filtresi.
  final int? year;

  /// Ülke filtresi.
  final String? country;

  /// Kategori kısa kodu filtresi.
  final String? categorySlug;

  /// Serbest metin araması.
  final String searchQuery;

  /// Herhangi bir filtrenin etkin olup olmadığını döndürür.
  bool get hasActiveFilters =>
      layer != MapLayerFilter.all ||
      onlyFavorites ||
      year != null ||
      (country != null && country!.trim().isNotEmpty) ||
      (categorySlug != null && categorySlug!.trim().isNotEmpty) ||
      searchQuery.trim().isNotEmpty;

  /// Seçili alanları güncelleyerek kopya üretir.
  MapAndVisitFilter copyWith({
    MapLayerFilter? layer,
    bool? onlyFavorites,
    int? year,
    bool clearYear = false,
    String? country,
    bool clearCountry = false,
    String? categorySlug,
    bool clearCategory = false,
    String? searchQuery,
  }) {
    return MapAndVisitFilter(
      layer: layer ?? this.layer,
      onlyFavorites: onlyFavorites ?? this.onlyFavorites,
      year: clearYear ? null : (year ?? this.year),
      country: clearCountry ? null : (country ?? this.country),
      categorySlug: clearCategory ? null : (categorySlug ?? this.categorySlug),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Kişisel ziyaret geçmişi, gezi günlüğü ve harita durumunu tutar.
@immutable
class VisitsState {
  /// Ziyaret durumu oluşturur.
  const VisitsState({
    this.isLoading = false,
    this.isSaving = false,
    this.visits = const [],
    this.filter = const MapAndVisitFilter(),
    this.selectedPlaceIdOnMap,
    this.error,
  });

  /// Yüklenme durumu.
  final bool isLoading;

  /// Kayıt/silme işlemi devam ediyor mu.
  final bool isSaving;

  /// Kullanıcının tüm ziyaret kayıtları (`visits`).
  final List<VisitEntity> visits;

  /// Aktif harita ve geçmiş filtresi (`C02`).
  final MapAndVisitFilter filter;

  /// Haritada (`C01`) seçilen pinin mekan kimliği.
  final String? selectedPlaceIdOnMap;

  /// Varsa son işlem hatası.
  final AppException? error;

  /// Filtrelenmiş ziyaret listesini döndürür.
  List<VisitEntity> get filteredVisits {
    final query = filter.searchQuery.trim().toLowerCase();
    final country = filter.country?.trim().toLowerCase() ?? '';
    final cat = filter.categorySlug?.trim().toLowerCase() ?? '';

    return visits.where((visit) {
      if (filter.onlyFavorites && !visit.isFavorite) {
        return false;
      }
      if (filter.year != null && visit.visitedAt.year != filter.year) {
        return false;
      }
      if (country.isNotEmpty &&
          !(visit.place?.country.toLowerCase().contains(country) ?? false)) {
        return false;
      }
      if (cat.isNotEmpty &&
          !visit.categorySlugs.any((s) => s.toLowerCase() == cat) &&
          (visit.place?.categorySlug?.toLowerCase() ?? '') != cat) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchTitle = visit.title?.toLowerCase().contains(query) ?? false;
        final matchNotes = visit.notes?.toLowerCase().contains(query) ?? false;
        final matchPlace =
            visit.place?.name.toLowerCase().contains(query) ?? false;
        final matchCity =
            visit.place?.city.toLowerCase().contains(query) ?? false;
        if (!matchTitle && !matchNotes && !matchPlace && !matchCity) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Gerçek ziyaret kayıtlarından benzersiz ülke sayısını hesaplar (`B01`, `F01`).
  ///
  /// Aynı ülkenin farklı yazımlarını (`"TR"`, `"Türkiye"`, `"turkiye"`, `"Turkey"`)
  /// kanonik ISO anahtarına indirgeyerek mükerrer sayımı önler.
  int get uniqueCountriesCount => visits
      .map((v) => TravelValidators.canonicalCountryKey(v.place?.country))
      .where((c) => c.isNotEmpty)
      .toSet()
      .length;

  /// Gerçek ziyaret kayıtlarından benzersiz şehir sayısını hesaplar (`B01`, `F01`).
  ///
  /// Türkçe karakter ve büyük/küçük harf farklarını (`"istanbul"`, `"İstanbul"`)
  /// tekilleştirerek doğru şehir sayısını hesaplar.
  int get uniqueCitiesCount => visits
      .map(
        (v) => TravelValidators.canonicalCityKey(
          v.place?.city,
          country: v.place?.country,
        ),
      )
      .where((c) => c.isNotEmpty)
      .toSet()
      .length;

  /// Kimliğe göre ziyaret bulur.
  VisitEntity? findById(String visitId) {
    for (final v in visits) {
      if (v.id == visitId) {
        return v;
      }
    }
    return null;
  }

  /// Seçili alanları güncelleyerek kopya üretir.
  VisitsState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<VisitEntity>? visits,
    MapAndVisitFilter? filter,
    String? selectedPlaceIdOnMap,
    bool clearSelectedPlace = false,
    AppException? error,
    bool clearError = false,
  }) {
    return VisitsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      visits: visits ?? this.visits,
      filter: filter ?? this.filter,
      selectedPlaceIdOnMap: clearSelectedPlace
          ? null
          : (selectedPlaceIdOnMap ?? this.selectedPlaceIdOnMap),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Kişisel ziyaretleri, gezi günlüğünü ve harita seçimlerini yöneten Riverpod Notifier.
class VisitsController extends Notifier<VisitsState> {
  @override
  VisitsState build() {
    // Oturum açan kullanıcı değiştiğinde kişisel ziyaretleri ve harita pinlerini yeniliyoruz.
    ref.watch(authControllerProvider.select((s) => s.user?.id));
    Future.microtask(loadVisits);
    return const VisitsState(isLoading: true);
  }

  String get _currentUserId =>
      ref.read(authControllerProvider).user?.id ??
      ref.read(supabaseClientProvider)?.auth.currentUser?.id ??
      '';

  /// Kullanıcının tüm ziyaret geçmişini veritabanından yükler.
  Future<void> loadVisits() async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      state = state.copyWith(isLoading: false, visits: const []);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await ref.read(visitsRepositoryProvider).fetchVisits(userId);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, visits: list, clearError: true);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: ErrorMapper.map(error, stackTrace),
      );
    }
  }

  /// Harita ve ziyaret geçmişi filtresini günceller (`C02`).
  void updateFilter(MapAndVisitFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Tüm harita ve geçmiş filtrelerini sıfırlar.
  void resetFilter() {
    state = state.copyWith(filter: const MapAndVisitFilter());
  }

  /// Haritada bir mekan pinini seçer veya seçimi kaldırır (`C01`).
  void selectPlaceOnMap(String? placeId) {
    state = state.copyWith(
      selectedPlaceIdOnMap: placeId,
      clearSelectedPlace: placeId == null,
    );
  }

  /// Yeni ziyaret ve gezi günlüğü kaydeder veya mevcut kaydı günceller (`C04`, `C05`).
  Future<VisitEntity?> saveVisit(UpsertVisitRequest request) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final saved = await ref
          .read(visitsRepositoryProvider)
          .upsertVisit(request);
      if (!ref.mounted) return saved;
      // Katalog dışı yeni özel mekan oluşturulduysa veya yeni ziyaret fotoğrafı
      // eklendiyse Keşif/Ana Sayfa mekan kartlarının güncellenmesi için yeniliyoruz.
      if (request.customPlace != null || request.newPhotos.isNotEmpty) {
        await ref.read(exploreControllerProvider.notifier).loadInitial();
      }
      if (!ref.mounted) return saved;
      final updatedList = [
        saved,
        ...state.visits.where((v) => v.id != saved.id),
      ];
      state = state.copyWith(
        isSaving: false,
        visits: updatedList,
        clearError: true,
      );
      return saved;
    } catch (error, stackTrace) {
      if (!ref.mounted) return null;
      state = state.copyWith(
        isSaving: false,
        error: ErrorMapper.map(error, stackTrace),
      );
      return null;
    }
  }

  /// Ziyareti ve bağlı Storage fotoğraflarını siler (`C06`).
  ///
  /// Başarılı silme sonrasında keşif/ana sayfa kapak görseli önbelleğinin de
  /// güncellenmesi için `exploreControllerProvider` yenilenir; böylece silinen
  /// ziyarete ait fotoğraf varsa mekan kartından da kaldırılır.
  Future<bool> deleteVisit(String visitId) async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      return false;
    }
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await ref
          .read(visitsRepositoryProvider)
          .deleteVisit(visitId: visitId, userId: userId);
      if (!ref.mounted) return true;
      state = state.copyWith(
        isSaving: false,
        visits: state.visits.where((v) => v.id != visitId).toList(),
        clearError: true,
      );
      // Silinen ziyaretin fotoğrafı özel bir mekanın kapak görseli olarak
      // önbellekte kalmasın diye keşif listesini sessizce yeniliyoruz.
      await ref.read(exploreControllerProvider.notifier).loadInitial();
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSaving: false,
        error: ErrorMapper.map(error, stackTrace),
      );
      return false;
    }
  }
}

/// Ziyaret ve harita durumunu sunan Riverpod sağlayıcısı.
final visitsControllerProvider =
    NotifierProvider<VisitsController, VisitsState>(VisitsController.new);
