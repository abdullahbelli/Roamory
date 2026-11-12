import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/core/utils/app_date_formatter.dart';
import 'package:roamory/features/trips/domain/entities/trip_entity.dart';
import 'package:roamory/features/trips/presentation/providers/trips_controller.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Seyahatlerim Listesi Ekranı (`D01` — Stitch `326e74e374f14a72a33bd82f6900279b`
/// ve `S01` Boş Seyahat Durumu — Stitch `2ce4b3a218084af5b3f87207b2c04959`).
///
/// 6. alt sekme OLMADAN, `/trips` iç rotası olarak çalışır. Planlanan (`planned`),
/// Devam Eden (`ongoing`) ve Tamamlanan (`completed`) seyahatleri sekmeli olarak
/// filtreler ve yeni seyahat oluşturma (`D02`) ile detay (`D03`) ekranlarına bağlar.
class MyTripsScreen extends ConsumerWidget {
  /// Seyahatlerim ekranı oluşturur.
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(tripsControllerProvider);
    final notifier = ref.read(tripsControllerProvider.notifier);
    final filtered = state.filteredByTab;

    return RoamoryScaffold(
      appBar: AppBar(
        title: Text(l10n.tripsTitle),
        actions: [
          IconButton(
            tooltip: l10n.tripsCreateButton,
            onPressed: () => context.push(AppRoutes.tripCreate),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Durum sekmeleri: Planlanan / Devam Eden / Tamamlanan.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageMargin,
              vertical: AppSpacing.xs,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text(l10n.tripsTabPlanned),
                    selected: state.selectedStatusTab == TripStatus.planned,
                    onSelected: (_) =>
                        notifier.setStatusTab(TripStatus.planned),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ChoiceChip(
                    label: Text(l10n.tripsTabOngoing),
                    selected: state.selectedStatusTab == TripStatus.ongoing,
                    onSelected: (_) =>
                        notifier.setStatusTab(TripStatus.ongoing),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ChoiceChip(
                    label: Text(l10n.tripsTabCompleted),
                    selected: state.selectedStatusTab == TripStatus.completed,
                    onSelected: (_) =>
                        notifier.setStatusTab(TripStatus.completed),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const LoadingSkeleton(itemCount: 3)
                : filtered.isEmpty
                ? EmptyState(
                    icon: Icons.luggage_outlined,
                    title: l10n.tripsEmptyTitle,
                    message: l10n.tripsEmptyMessage,
                    actionLabel: l10n.tripsCreateButton,
                    onAction: () => context.push(AppRoutes.tripCreate),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.pageMargin),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final trip = filtered[index];
                      return InkWell(
                        onTap: () =>
                            context.push(AppRoutes.tripDetailsPath(trip.id)),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      trip.title,
                                      style: textTheme.titleMedium,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      l10n.tripDetailsDaysStat(trip.totalDays),
                                    ),
                                  ),
                                ],
                              ),
                              if (trip.destinationLabel.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  trip.destinationLabel,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                              if (trip.startDate != null &&
                                  trip.endDate != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  AppDateFormatter.formatRange(
                                    context,
                                    trip.startDate!,
                                    trip.endDate!,
                                  ),
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.sm),
                              Wrap(
                                spacing: AppSpacing.sm,
                                children: [
                                  Text(
                                    l10n.tripDetailsStopsStat(trip.totalStops),
                                    style: textTheme.labelMedium,
                                  ),
                                  Text(
                                    l10n.tripDetailsChecklistStat(
                                      trip.completedChecklistCount,
                                      trip.checklist.length,
                                    ),
                                    style: textTheme.labelMedium?.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
