import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/community/presentation/providers/community_controller.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';
import 'package:roamory/features/explore/presentation/providers/explore_controller.dart';
import 'package:roamory/features/visits/presentation/providers/visits_controller.dart';
import 'package:roamory/shared/widgets/app_network_image.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Keşfet Ekranı (`B02` — Stitch `76e6753b2acb4052b3168cf459c9914a`).
///
/// Katalogdaki gerçek `categories` ve `places` verilerini listeler; arama ve
/// gelişmiş filtreleme (`B03`), istek listesi (`B05`), mekan detayı (`B04`) ve
/// harita (`C01`) geçişlerini yönetir. Katalog boşsa sahte kart üretmez.
class ExploreScreen extends ConsumerWidget {
  /// Keşfet ekranı oluşturur.
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final langCode = Localizations.localeOf(context).languageCode;
    final authState = ref.watch(authControllerProvider);
    final visitsState = ref.watch(visitsControllerProvider);
    final communityState = ref.watch(communityControllerProvider);
    final state = ref.watch(exploreControllerProvider);
    final notifier = ref.read(exploreControllerProvider.notifier);

    return RoamoryScaffold(
      appBar: AppBar(
        title: Text(l10n.navExplore),
        actions: [
          IconButton(
            tooltip: l10n.exploreWishlistButton,
            onPressed: () => context.push(AppRoutes.wishlist),
            icon: Badge(
              isLabelVisible: state.wishlist.isNotEmpty,
              label: Text(state.wishlist.length.toString()),
              child: const Icon(Icons.bookmark_border_rounded),
            ),
          ),
          IconButton(
            tooltip: l10n.exploreViewMap,
            onPressed: () => context.go(AppRoutes.map),
            icon: const Icon(Icons.map_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          // Üst arama çubuğu ve B03 filtre ekranı tetikleyicisi.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageMargin,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.exploreSearch),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Container(
                      height: AppSpacing.inputHeight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              state.filter.query.isNotEmpty
                                  ? state.filter.query
                                  : l10n.exploreSearchHint,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                color: state.filter.query.isNotEmpty
                                    ? colors.textPrimary
                                    : colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.tonalIcon(
                  onPressed: () => context.push(AppRoutes.exploreSearch),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: Text(l10n.exploreFilterButton),
                ),
              ],
            ),
          ),

          // Yatay kategori filtre şeridi (`categories` tablosundan).
          if (state.categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageMargin,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text(l10n.commonAll),
                      selected: state.filter.categorySlug == null,
                      onSelected: (_) => notifier.updateFilter(
                        state.filter.copyWith(clearCategory: true),
                      ),
                    ),
                  ),
                  ...state.categories.map((cat) {
                    final isSelected = state.filter.categorySlug == cat.slug;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: ChoiceChip(
                        label: Text(cat.localizedName(langCode)),
                        selected: isSelected,
                        onSelected: (_) => notifier.updateFilter(
                          state.filter.copyWith(
                            categorySlug: isSelected ? null : cat.slug,
                            clearCategory: isSelected,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

          // İçerik alanı: yükleniyor, hata, boş veya gerçek mekan listesi.
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return const LoadingSkeleton(itemCount: 3);
                }
                if (state.error != null && state.places.isEmpty) {
                  return ErrorState(
                    exception: state.error,
                    onRetry: notifier.loadInitial,
                  );
                }
                if (state.places.isEmpty) {
                  return EmptyState(
                    icon: Icons.travel_explore_rounded,
                    title: l10n.exploreEmptyTitle,
                    message: l10n.exploreEmptyMessage,
                    actionLabel: state.filter.hasActiveFilters
                        ? l10n.searchClearFilters
                        : l10n.homeQuickAddVisit,
                    onAction: () {
                      if (state.filter.hasActiveFilters) {
                        notifier.resetFilters();
                      } else {
                        context.push(AppRoutes.visitAdd);
                      }
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageMargin,
                    AppSpacing.md,
                    AppSpacing.pageMargin,
                    AppSpacing.bottomNavHeight + AppSpacing.xl * 2,
                  ),
                  itemCount: state.places.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final place = state.places[index];
                    final isSaved = state.isInWishlist(place.id);
                    final coverUrl = state.resolvePlaceCoverUrl(
                      place,
                      userVisits: visitsState.visits,
                      feedPosts: communityState.feedPosts,
                      currentUserId: authState.user?.id,
                    );
                    return _ExplorePlaceCard(
                      place: place,
                      coverImageUrl: coverUrl,
                      isSaved: isSaved,
                      onTap: () =>
                          context.push(AppRoutes.placeDetailsPath(place.id)),
                      onToggleWishlist: () => notifier.toggleWishlist(place),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplorePlaceCard extends StatelessWidget {
  const _ExplorePlaceCard({
    required this.place,
    required this.coverImageUrl,
    required this.isSaved,
    required this.onTap,
    required this.onToggleWishlist,
  });

  final PlaceEntity place;
  final String? coverImageUrl;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onToggleWishlist;

  @override
  Widget build(BuildContext context) {
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: colors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AppNetworkImage(
                  imageUrl: coverImageUrl,
                  width: double.infinity,
                  height: 160,
                  borderRadius: AppSpacing.radiusLg,
                ),
                Positioned(
                  right: AppSpacing.sm,
                  top: AppSpacing.sm,
                  child: IconButton.filledTonal(
                    onPressed: onToggleWishlist,
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isSaved ? colors.accent : colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (place.averageRating != null) ...[
                        Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: colors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          place.averageRating!.toStringAsFixed(1),
                          style: textTheme.labelMedium,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.locationLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  if (place.description != null &&
                      place.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      place.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
