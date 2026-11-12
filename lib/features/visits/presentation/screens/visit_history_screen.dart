import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/core/utils/app_date_formatter.dart';
import 'package:roamory/features/visits/presentation/providers/visits_controller.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Ziyaret Geçmişi Ekranı (`C03` — Stitch `b308dacea62d4c61955e00c145cf51ba`).
///
/// Kullanıcının tüm özel ziyaretlerini ve gezi günlüğü özetlerini kronolojik
/// olarak listeler, arama ve favori filtresi sunar, detay ekranına (`C06`) bağlar.
class VisitHistoryScreen extends ConsumerWidget {
  /// Ziyaret geçmişi ekranı oluşturur.
  const VisitHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(visitsControllerProvider);
    final notifier = ref.read(visitsControllerProvider.notifier);
    final visits = state.filteredVisits;

    return RoamoryScaffold(
      appBar: AppBar(
        title: Text(l10n.visitsHistoryTitle),
        actions: [
          IconButton(
            tooltip: l10n.homeQuickAddVisit,
            onPressed: () => context.push(AppRoutes.visitAdd),
            icon: const Icon(Icons.add_location_alt_outlined),
          ),
        ],
      ),
      body: state.isLoading
          ? const LoadingSkeleton(itemCount: 3)
          : state.visits.isEmpty
          ? EmptyState(
              icon: Icons.menu_book_outlined,
              title: l10n.visitsEmptyTitle,
              message: l10n.visitsEmptyMessage,
              actionLabel: l10n.homeQuickAddVisit,
              onAction: () => context.push(AppRoutes.visitAdd),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.pageMargin),
              children: [
                Text(
                  l10n.visitsHistorySubtitle(visits.length),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    FilterChip(
                      label: Text(l10n.mapFilterOnlyFavorites),
                      selected: state.filter.onlyFavorites,
                      onSelected: (v) => notifier.updateFilter(
                        state.filter.copyWith(onlyFavorites: v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ...visits.map((visit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
                            if (visit.place != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                visit.place!.locationLabel,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                            if (visit.rating != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < visit.rating!
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    size: 16,
                                    color: colors.accent,
                                  ),
                                ),
                              ),
                            ],
                            if (visit.notes != null &&
                                visit.notes!.trim().isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                visit.notes!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
