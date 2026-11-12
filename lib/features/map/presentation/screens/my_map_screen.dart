import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/core/services/location_service.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';
import 'package:roamory/features/explore/presentation/providers/explore_controller.dart';
import 'package:roamory/features/map/presentation/widgets/map_filter_sheet.dart';
import 'package:roamory/features/visits/presentation/providers/visits_controller.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Kişisel Seyahat Haritası Ekranı (`C01` — Stitch `d0d6efaae0fc48fea8d713056f5a8bd2`).
///
/// `flutter_map` ve OpenStreetMap karo katmanı (`TileLayer`) kullanarak kullanıcının
/// ziyaret ettiği mekanları (`primary` koyu çam yeşili pin) ve istek listesindeki
/// mekanları (`accent` altın/kum taşı pin) gerçek koordinatlarıyla haritada çizer.
/// Sağ alt köşede zorunlu `© OpenStreetMap katkıda bulunanlar` lisans atfını gösterir.
class MyMapScreen extends ConsumerStatefulWidget {
  /// Kişisel harita ekranı oluşturur.
  const MyMapScreen({super.key});

  @override
  ConsumerState<MyMapScreen> createState() => _MyMapScreenState();
}

class _MyMapScreenState extends ConsumerState<MyMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  bool _locating = false;

  /// Cihazdan çalışma zamanı konum izni isteyerek haritayı kullanıcının
  /// gerçek GPS koordinatına taşır; izin reddedilirse veya GPS kapalıysa
  /// anlaşılır bir bilgilendirme mesajı gösterir.
  Future<void> _goToMyLocation() async {
    if (_locating) {
      return;
    }
    setState(() => _locating = true);
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(locationServiceProvider)
        .checkAndRequestCurrentLocation();
    if (!mounted) {
      return;
    }
    setState(() => _locating = false);

    if (result.hasCoordinates) {
      final point = result.coordinates!;
      setState(() => _userLocation = point);
      _mapController.move(point, 13.0);
      return;
    }

    final message = switch (result.status) {
      LocationPermissionStatus.denied => l10n.mapLocationPermissionDenied,
      LocationPermissionStatus.serviceDisabled ||
      LocationPermissionStatus.unavailable => l10n.mapLocationServiceDisabled,
      LocationPermissionStatus.granted => l10n.mapLocationServiceDisabled,
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final visitsState = ref.watch(visitsControllerProvider);
    final exploreState = ref.watch(exploreControllerProvider);
    final visitsNotifier = ref.read(visitsControllerProvider.notifier);

    final filter = visitsState.filter;
    final showVisited =
        filter.layer == MapLayerFilter.all ||
        filter.layer == MapLayerFilter.visited;
    final showWishlist =
        filter.layer == MapLayerFilter.all ||
        filter.layer == MapLayerFilter.wishlist;

    final visitedPlaces = <String, PlaceEntity>{};
    if (showVisited) {
      for (final visit in visitsState.filteredVisits) {
        final place = visit.place ?? exploreState.findPlaceById(visit.placeId);
        if (place != null && place.hasValidCoordinates) {
          visitedPlaces[place.id] = place;
        }
      }
    }

    final wishlistPlaces = <String, PlaceEntity>{};
    if (showWishlist) {
      for (final item in exploreState.wishlist) {
        final place = item.place ?? exploreState.findPlaceById(item.placeId);
        if (place != null &&
            place.hasValidCoordinates &&
            !visitedPlaces.containsKey(place.id)) {
          wishlistPlaces[place.id] = place;
        }
      }
    }

    final allPinPlaces = <PlaceEntity>[
      ...visitedPlaces.values,
      ...wishlistPlaces.values,
    ];

    // Başlangıç merkezi: ilk pin koordinatı veya Türkiye/Akdeniz merkezi.
    final initialCenter = allPinPlaces.isNotEmpty
        ? LatLng(allPinPlaces.first.latitude, allPinPlaces.first.longitude)
        : const LatLng(39.0, 35.0);

    PlaceEntity? selectedPlace;
    if (visitsState.selectedPlaceIdOnMap != null) {
      final targetId = visitsState.selectedPlaceIdOnMap!;
      selectedPlace =
          visitedPlaces[targetId] ??
          wishlistPlaces[targetId] ??
          exploreState.findPlaceById(targetId);
    }

    return RoamoryScaffold(
      body: Stack(
        children: [
          // 1. Etkileşimli flutter_map + OpenStreetMap katmanı.
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: allPinPlaces.isNotEmpty ? 6.0 : 5.0,
              onTap: (_, _) => visitsNotifier.selectPlaceOnMap(null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'io.roamory.app',
              ),
              MarkerLayer(
                markers: [
                  for (final place in visitedPlaces.values)
                    Marker(
                      point: LatLng(place.latitude, place.longitude),
                      width: 46,
                      height: 46,
                      child: GestureDetector(
                        onTap: () => visitsNotifier.selectPlaceOnMap(place.id),
                        child: _MapPinBubble(
                          color: colors.primary,
                          icon: Icons.check_rounded,
                          isSelected: selectedPlace?.id == place.id,
                        ),
                      ),
                    ),
                  for (final place in wishlistPlaces.values)
                    Marker(
                      point: LatLng(place.latitude, place.longitude),
                      width: 46,
                      height: 46,
                      child: GestureDetector(
                        onTap: () => visitsNotifier.selectPlaceOnMap(place.id),
                        child: _MapPinBubble(
                          color: colors.accent,
                          icon: Icons.bookmark_rounded,
                          isSelected: selectedPlace?.id == place.id,
                        ),
                      ),
                    ),
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 42,
                      height: 42,
                      child: _MapPinBubble(
                        color: colors.primary,
                        icon: Icons.my_location_rounded,
                        isSelected: false,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 2. Üst yüzen durum ve filtre kontrol çubuğu (C01 -> C02 / C03).
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pageMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm + 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                            border: Border.all(color: colors.outline),
                          ),
                          child: Text(
                            l10n.mapStatsPill(
                              visitsState.visits.length,
                              exploreState.wishlist.length,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelLarge,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: FilledButton.tonalIcon(
                          onPressed: () => showMapFilterSheet(context),
                          icon: const Icon(Icons.tune_rounded, size: 18),
                          label: Text(
                            l10n.mapFilterButton,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      IconButton.filledTonal(
                        tooltip: l10n.mapMyLocationTooltip,
                        onPressed: _locating ? null : _goToMyLocation,
                        icon: _locating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location_rounded),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      IconButton.filledTonal(
                        tooltip: l10n.mapHistoryButton,
                        onPressed: () => context.push(AppRoutes.visitsHistory),
                        icon: const Icon(Icons.history_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Pin renk açıklaması (Legend) ve Yeni Ziyaret Ekle hızlı butonu.
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _LegendPill(
                        color: colors.primary,
                        label: l10n.mapLegendVisited,
                      ),
                      _LegendPill(
                        color: colors.accent,
                        label: l10n.mapLegendWishlist,
                      ),
                      ActionChip(
                        avatar: Icon(
                          Icons.add_location_alt_outlined,
                          size: 16,
                          color: colors.primary,
                        ),
                        label: Text(l10n.mapAddVisitFab),
                        onPressed: () => context.push(AppRoutes.visitAdd),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Boş harita bilgilendirme etiketi (sahte pin basılmaz).
          if (allPinPlaces.isEmpty)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageMargin,
                ),
                child: Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: colors.outline),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.mapEmptyOverlay,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PrimaryButton(
                        label: l10n.mapAddVisitFab,
                        icon: Icons.add_location_alt_outlined,
                        onPressed: () => context.push(AppRoutes.visitAdd),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 4. Seçili pin önizleme alt kartı (MapPlaceSheet) + OSM Lisans Atfı.
          Positioned(
            left: AppSpacing.pageMargin,
            right: AppSpacing.pageMargin,
            bottom: AppSpacing.bottomNavHeight + AppSpacing.xl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(l10n.mapAttribution, style: textTheme.labelSmall),
                ),
                if (selectedPlace != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: AppSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: colors.outline),
                      boxShadow: [
                        BoxShadow(
                          color: colors.floatingShadow,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedPlace.name,
                                style: textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  visitsNotifier.selectPlaceOnMap(null),
                              icon: const Icon(Icons.close_rounded, size: 20),
                            ),
                          ],
                        ),
                        Text(
                          selectedPlace.locationLabel,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => context.push(
                                AppRoutes.placeDetailsPath(selectedPlace!.id),
                              ),
                              child: Text(l10n.commonSeeAll),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            FilledButton.tonal(
                              onPressed: () => context.push(
                                '${AppRoutes.visitAdd}?placeId=${selectedPlace!.id}',
                              ),
                              child: Text(l10n.homeQuickAddVisit),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPinBubble extends StatelessWidget {
  const _MapPinBubble({
    required this.color,
    required this.icon,
    required this.isSelected,
  });

  final Color color;
  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = RoamoryColors.of(context);
    return AnimatedScale(
      scale: isSelected ? 1.18 : 1.0,
      duration: const Duration(milliseconds: 180),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: colors.surface, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: colors.floatingShadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: colors.onPrimary),
      ),
    );
  }
}

class _LegendPill extends StatelessWidget {
  const _LegendPill({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: textTheme.labelSmall),
        ],
      ),
    );
  }
}
