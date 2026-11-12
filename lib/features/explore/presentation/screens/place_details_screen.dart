import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/community/presentation/providers/community_controller.dart';
import 'package:roamory/features/explore/data/repositories/supabase_explore_repository.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';
import 'package:roamory/features/explore/presentation/providers/explore_controller.dart';
import 'package:roamory/features/trips/presentation/providers/trips_controller.dart';
import 'package:roamory/features/visits/presentation/providers/visits_controller.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_network_image.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Mekan Detayları Ekranı (`B04` — Stitch `5de6a72d74ef4f91b9a8cc8b9864b650`).
///
/// Mekanın fotoğraflarını, hikayesini, `flutter_map` + OpenStreetMap mini önizlemesini,
/// hızlı eylemlerini (`İstek Listem`, `Rotaya Ekle`, `Gittim / Günlüğe Ekle`) ve
/// bu mekana bağlı topluluk paylaşımlarını gösterir.
class PlaceDetailsScreen extends ConsumerStatefulWidget {
  /// Mekan detay ekranı oluşturur.
  const PlaceDetailsScreen({super.key, required this.placeId});

  /// Görüntülenecek mekan kimliği (`places.id`).
  final String placeId;

  @override
  ConsumerState<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends ConsumerState<PlaceDetailsScreen> {
  PlaceEntity? _remotePlace;
  bool _loadingRemote = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_ensurePlaceLoaded);
  }

  Future<void> _ensurePlaceLoaded() async {
    final cached = ref
        .read(exploreControllerProvider)
        .findPlaceById(widget.placeId);
    if (cached != null) {
      return;
    }
    setState(() => _loadingRemote = true);
    try {
      final fetched = await ref
          .read(exploreRepositoryProvider)
          .fetchPlaceById(widget.placeId);
      if (mounted) {
        setState(() {
          _remotePlace = fetched;
          _loadingRemote = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingRemote = false);
      }
    }
  }

  Future<void> _showAddToTripSheet(
    BuildContext context,
    PlaceEntity place,
  ) async {
    final l10n = AppLocalizations.of(context);
    final trips = ref.read(tripsControllerProvider).trips;
    if (trips.isEmpty) {
      context.push(AppRoutes.tripCreate);
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            children: [
              Text(
                l10n.placeDetailsActionAddToTrip,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              ...trips.map((trip) {
                final firstDayId = trip.days.isNotEmpty
                    ? trip.days.first.id
                    : null;
                return ListTile(
                  title: Text(trip.title),
                  subtitle: Text(trip.destinationLabel),
                  trailing: const Icon(Icons.add_circle_outline_rounded),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    if (firstDayId != null) {
                      await ref
                          .read(tripsControllerProvider.notifier)
                          .addStopToDay(
                            tripId: trip.id,
                            tripDayId: firstDayId,
                            place: place,
                          );
                    }
                    if (context.mounted) {
                      context.push(AppRoutes.tripDetailsPath(trip.id));
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final authState = ref.watch(authControllerProvider);
    final visitsState = ref.watch(visitsControllerProvider);
    final exploreState = ref.watch(exploreControllerProvider);
    final communityState = ref.watch(communityControllerProvider);
    final place = exploreState.findPlaceById(widget.placeId) ?? _remotePlace;

    if (_loadingRemote && place == null) {
      return const RoamoryScaffold(body: LoadingSkeleton(itemCount: 2));
    }
    if (place == null) {
      return RoamoryScaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.location_off_outlined,
          title: l10n.errorNotFoundMessage,
          actionLabel: l10n.commonBack,
          onAction: () => context.pop(),
        ),
      );
    }

    final isSaved = exploreState.isInWishlist(place.id);
    final placePosts = communityState.feedPosts
        .where((p) => p.placeId == place.id)
        .toList();
    final coverUrl = exploreState.resolvePlaceCoverUrl(
      place,
      userVisits: visitsState.visits,
      feedPosts: communityState.feedPosts,
      currentUserId: authState.user?.id,
    );

    return RoamoryScaffold(
      appBar: AppBar(
        title: Text(place.name),
        actions: [
          IconButton(
            tooltip: isSaved
                ? l10n.placeDetailsActionWishlistRemove
                : l10n.placeDetailsActionWishlistAdd,
            onPressed: () async {
              await ref
                  .read(exploreControllerProvider.notifier)
                  .toggleWishlist(place);
              if (!context.mounted) {
                return;
              }
              final err = ref.read(exploreControllerProvider).error;
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(err.localizedMessage(l10n))),
                );
              }
            },
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? colors.accent : colors.textPrimary,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.sm,
          AppSpacing.pageMargin,
          AppSpacing.xl * 2,
        ),
        children: [
          AppNetworkImage(
            imageUrl: coverUrl,
            width: double.infinity,
            height: 220,
            borderRadius: AppSpacing.radiusLg,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(place.name, style: textTheme.headlineMedium),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.place_outlined, size: 18, color: colors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  place.locationLabel,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              if (place.averageRating != null) ...[
                Icon(Icons.star_rounded, size: 18, color: colors.accent),
                const SizedBox(width: 4),
                Text(
                  place.averageRating!.toStringAsFixed(1),
                  style: textTheme.labelLarge,
                ),
              ],
            ],
          ),
          if (!place.isPublished) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: colors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.placeDetailsPrivateNotice,
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          // Hızlı Aksiyonlar: İstek Listem, Rotaya Ekle, Gittim/Günlüğe Ekle.
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  await ref
                      .read(exploreControllerProvider.notifier)
                      .toggleWishlist(place);
                  if (!context.mounted) {
                    return;
                  }
                  final err = ref.read(exploreControllerProvider).error;
                  if (err != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err.localizedMessage(l10n))),
                    );
                  }
                },
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
                label: Text(
                  isSaved
                      ? l10n.placeDetailsActionWishlistRemove
                      : l10n.placeDetailsActionWishlistAdd,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showAddToTripSheet(context, place),
                icon: const Icon(Icons.route_outlined),
                label: Text(l10n.placeDetailsActionAddToTrip),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: l10n.placeDetailsActionMarkVisited,
            icon: Icons.edit_location_alt_outlined,
            onPressed: () =>
                context.push('${AppRoutes.visitAdd}?placeId=${place.id}'),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Mekan Hikayesi.
          if (place.description != null &&
              place.description!.trim().isNotEmpty) ...[
            Text(l10n.placeDetailsStoryTitle, style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(place.description!, style: textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Konum & flutter_map mini önizleme + OpenStreetMap atfı.
          Text(
            l10n.placeDetailsCoordinatesTitle,
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}',
            style: textTheme.labelMedium?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: SizedBox(
              height: 180,
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(place.latitude, place.longitude),
                      initialZoom: 12,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'io.roamory.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(place.latitude, place.longitude),
                            width: 44,
                            height: 44,
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 40,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    right: 8,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.mapAttribution,
                        style: textTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Bu mekana ait topluluk paylaşımları.
          Text(l10n.placeDetailsCommunityTitle, style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          if (placePosts.isEmpty)
            Text(
              l10n.placeDetailsCommunityEmpty,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            )
          else
            ...placePosts.map((post) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(post.title ?? post.caption),
                subtitle: Text('@${post.author?.username ?? 'roamory'}'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(AppRoutes.postDetailsPath(post.id)),
              );
            }),
        ],
      ),
    );
  }
}
