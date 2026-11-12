import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/core/utils/app_date_formatter.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/community/presentation/providers/community_controller.dart';
import 'package:roamory/features/explore/presentation/providers/explore_controller.dart';
import 'package:roamory/features/profile/presentation/providers/profile_settings_controller.dart';
import 'package:roamory/features/trips/presentation/providers/trips_controller.dart';
import 'package:roamory/features/visits/presentation/providers/visits_controller.dart';
import 'package:roamory/shared/widgets/app_network_image.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Ana Sayfa (`B01` — Stitch `f3d34ff9d41b4c21ada6da3016df99ed`).
///
/// Kullanıcının gerçek Dijital Pasaport istatistiklerini (ülke, şehir, ziyaret,
/// istek listesi), hızlı eylem kısayollarını (`Ziyaret Ekle`, `Rota Planla`,
/// `Günlüğüm`, `Kaydedilenler`), yaklaşan seyahat kartını, öne çıkan mekanları,
/// son özel ziyaret anısını ve topluluk paylaşım özetini gösterir.
/// Üretim akışında hiçbir sahte sayı veya uydurma hedef göstermez.
class HomeScreen extends ConsumerWidget {
  /// Ana sayfa ekranı oluşturur.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final authState = ref.watch(authControllerProvider);
    final visitsState = ref.watch(visitsControllerProvider);
    final exploreState = ref.watch(exploreControllerProvider);
    final tripsState = ref.watch(tripsControllerProvider);
    final communityState = ref.watch(communityControllerProvider);
    final notifState = ref.watch(profileSettingsControllerProvider);

    final displayName = authState.profile?.fullName?.trim().isNotEmpty == true
        ? authState.profile!.fullName!
        : (authState.user?.fullName ?? l10n.appTitle);
    final upcomingTrip = tripsState.upcomingTrip;

    return RoamoryScaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(visitsControllerProvider.notifier).loadVisits(),
              ref.read(exploreControllerProvider.notifier).loadInitial(),
              ref.read(tripsControllerProvider.notifier).loadTrips(),
              ref.read(communityControllerProvider.notifier).loadFeed(),
              ref
                  .read(profileSettingsControllerProvider.notifier)
                  .loadNotifications(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageMargin,
              AppSpacing.md,
              AppSpacing.pageMargin,
              AppSpacing.bottomNavHeight + AppSpacing.xl * 2,
            ),
            children: [
              // 1. Üst karşılama satırı, bildirim zili (F03) ve profil avatarı (F01).
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.homeGreetingPrefix} $displayName',
                          style: textTheme.headlineMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.homeGreetingSubtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        tooltip: l10n.notificationsTitle,
                        onPressed: () => context.push(AppRoutes.notifications),
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (notifState.unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.profile),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: colors.primaryContainer,
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Dijital Pasaport Özeti Kartı (gerçek veritabanı sayaçlarıyla).
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: colors.cardShadow,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.onPrimary.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                            ),
                            child: Text(
                              l10n.homePassportBadge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        TextButton.icon(
                          onPressed: () => context.go(AppRoutes.map),
                          icon: Icon(
                            Icons.map_outlined,
                            size: 16,
                            color: colors.onPrimary,
                          ),
                          label: Text(
                            l10n.exploreViewMap,
                            style: textTheme.labelMedium?.copyWith(
                              color: colors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.homePassportTitle,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _PassportMetricTile(
                            label: l10n.homePassportCountries,
                            value: visitsState.uniqueCountriesCount.toString(),
                          ),
                        ),
                        Expanded(
                          child: _PassportMetricTile(
                            label: l10n.homePassportCities,
                            value: visitsState.uniqueCitiesCount.toString(),
                          ),
                        ),
                        Expanded(
                          child: _PassportMetricTile(
                            label: l10n.homePassportVisits,
                            value: visitsState.visits.length.toString(),
                          ),
                        ),
                        Expanded(
                          child: _PassportMetricTile(
                            label: l10n.homePassportWishlist,
                            value: exploreState.wishlist.length.toString(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Hızlı Eylem Butonları (Ziyaret Ekle, Rota Planla, Günlüğüm, Kaydedilenler).
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _QuickActionChip(
                    icon: Icons.add_location_alt_outlined,
                    label: l10n.homeQuickAddVisit,
                    onTap: () => context.push(AppRoutes.visitAdd),
                  ),
                  _QuickActionChip(
                    icon: Icons.route_outlined,
                    label: l10n.homeQuickPlanTrip,
                    onTap: () => context.push(AppRoutes.trips),
                  ),
                  _QuickActionChip(
                    icon: Icons.menu_book_outlined,
                    label: l10n.homeQuickMyJournal,
                    onTap: () => context.push(AppRoutes.visitsHistory),
                  ),
                  _QuickActionChip(
                    icon: Icons.bookmark_border_rounded,
                    label: l10n.homeQuickWishlist,
                    onTap: () => context.push(AppRoutes.wishlist),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4. Yaklaşan Seyahat Özeti (D01 / D03 bağlantılı).
              _SectionHeader(
                title: l10n.homeUpcomingTripTitle,
                actionLabel: l10n.commonSeeAll,
                onAction: () => context.push(AppRoutes.trips),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: colors.outline),
                ),
                child: upcomingTrip == null
                    ? Row(
                        children: [
                          Icon(
                            Icons.luggage_outlined,
                            color: colors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              l10n.homeUpcomingTripEmpty,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.tripCreate),
                            child: Text(l10n.homeQuickPlanTrip),
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: () => context.push(
                          AppRoutes.tripDetailsPath(upcomingTrip.id),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    upcomingTrip.title,
                                    style: textTheme.titleMedium,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    l10n.tripDetailsDaysStat(
                                      upcomingTrip.totalDays,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (upcomingTrip.destinationLabel.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                upcomingTrip.destinationLabel,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 5. Öne Çıkan Rotalar / Mekanlar (Explore bağlantılı).
              _SectionHeader(
                title: l10n.homeFeaturedTitle,
                actionLabel: l10n.commonSeeAll,
                onAction: () => context.go(AppRoutes.explore),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (exploreState.places.isEmpty)
                Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: colors.outline),
                  ),
                  child: Text(
                    l10n.exploreEmptyMessage,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 175,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: exploreState.places.take(6).length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final place = exploreState.places[index];
                      // Özel mekanlarda yalnızca sahibinin ziyaret fotoğrafını,
                      // katalogda ise izinli görselleri güvenli biçimde çözümlüyoruz.
                      final coverUrl = exploreState.resolvePlaceCoverUrl(
                        place,
                        userVisits: visitsState.visits,
                        feedPosts: communityState.feedPosts,
                        currentUserId: authState.user?.id,
                      );
                      return InkWell(
                        onTap: () =>
                            context.push(AppRoutes.placeDetailsPath(place.id)),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                        child: Container(
                          width: 220,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                            border: Border.all(color: colors.outline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AppNetworkImage(
                                  imageUrl: coverUrl,
                                  width: double.infinity,
                                  borderRadius: AppSpacing.radiusMd,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                place.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleSmall,
                              ),
                              Text(
                                place.locationLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),

              // 6. Son Özel Ziyaret Anıları (C03 / C06 bağlantılı, özel rozetli).
              _SectionHeader(
                title: l10n.homeRecentMemoriesTitle,
                actionLabel: l10n.commonSeeAll,
                onAction: () => context.push(AppRoutes.visitsHistory),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (visitsState.visits.isEmpty)
                Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: colors.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline_rounded, color: colors.primary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          l10n.homeRecentMemoriesEmpty,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...visitsState.visits.take(2).map((visit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: InkWell(
                      onTap: () =>
                          context.push(AppRoutes.visitDetailsPath(visit.id)),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      child: Container(
                        padding: AppSpacing.cardPadding,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                          border: Border.all(color: colors.outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 16,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.commonPrivateBadge,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colors.primary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  AppDateFormatter.format(
                                    context,
                                    visit.visitedAt,
                                  ),
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              visit.title?.trim().isNotEmpty == true
                                  ? visit.title!
                                  : (visit.place?.name ??
                                        l10n.visitDetailsTitle),
                              style: textTheme.titleMedium,
                            ),
                            if (visit.notes != null &&
                                visit.notes!.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                visit.notes!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: AppSpacing.md),

              // 7. Topluluktan İlham Al (E01 / E03 bağlantılı).
              _SectionHeader(
                title: l10n.homeCommunityHighlightTitle,
                actionLabel: l10n.commonSeeAll,
                onAction: () => context.go(AppRoutes.community),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (communityState.feedPosts.isEmpty)
                Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: colors.outline),
                  ),
                  child: Text(
                    l10n.homeCommunityHighlightEmpty,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                )
              else
                InkWell(
                  onTap: () => context.push(
                    AppRoutes.postDetailsPath(
                      communityState.feedPosts.first.id,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: Container(
                    padding: AppSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          communityState.feedPosts.first.title ??
                              communityState.feedPosts.first.caption,
                          style: textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '@${communityState.feedPosts.first.author?.username ?? 'roamory'}',
                          style: textTheme.labelMedium?.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PassportMetricTile extends StatelessWidget {
  const _PassportMetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: textTheme.headlineMedium?.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelSmall?.copyWith(
            color: colors.onPrimary.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: colors.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: colors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.headlineSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}
