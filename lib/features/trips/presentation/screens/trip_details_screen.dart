import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/core/utils/app_date_formatter.dart';
import 'package:roamory/features/trips/presentation/providers/trips_controller.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Seyahat Detayı ve Genel Bakış Ekranı (`D03` — Stitch `eaa6270a8a3d4d199df61c1c1e55e16f`).
///
/// Seyahatin gün sayısını, toplam duraklarını, hazırlık kontrol listesi ilerlemesini
/// ve gün gün plan özetini gösterir; Günlük Rota Planlayıcı (`D04`) ile Kontrol
/// Listesi (`D05`) ekranlarına geçiş sağlar.
class TripDetailsScreen extends ConsumerWidget {
  /// Seyahat detay ekranı oluşturur.
  const TripDetailsScreen({super.key, required this.tripId});

  /// Görüntülenecek seyahat kimliği (`trips.id`).
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(tripsControllerProvider);
    final trip = state.findById(tripId);

    if (trip == null) {
      return RoamoryScaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.luggage_outlined,
          title: l10n.errorNotFoundMessage,
          actionLabel: l10n.commonBack,
          onAction: () => context.pop(),
        ),
      );
    }

    return RoamoryScaffold(
      appBar: AppBar(
        title: Text(trip.title),
        actions: [
          IconButton(
            tooltip: l10n.tripEditTitle,
            onPressed: () =>
                context.push('${AppRoutes.tripCreate}?tripId=${trip.id}'),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: l10n.commonDelete,
            onPressed: () async {
              final confirmed = await showAppConfirmSheet(
                context: context,
                title: l10n.tripDetailsDeleteConfirmTitle,
                message: l10n.tripDetailsDeleteConfirmMessage,
                confirmLabel: l10n.commonDelete,
                isDestructive: true,
              );
              if (confirmed && context.mounted) {
                final deleted = await ref
                    .read(tripsControllerProvider.notifier)
                    .deleteTrip(trip.id);
                if (deleted && context.mounted) {
                  context.pop();
                }
              }
            },
            icon: Icon(Icons.delete_outline_rounded, color: colors.error),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          // Üst özet kartı.
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.title, style: textTheme.headlineMedium),
                if (trip.destinationLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    trip.destinationLabel,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                if (trip.startDate != null && trip.endDate != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    AppDateFormatter.formatRange(
                      context,
                      trip.startDate!,
                      trip.endDate!,
                    ),
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
                if (trip.description != null &&
                    trip.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(trip.description!, style: textTheme.bodyMedium),
                ],
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Chip(label: Text(l10n.tripDetailsDaysStat(trip.totalDays))),
                    Chip(
                      label: Text(l10n.tripDetailsStopsStat(trip.totalStops)),
                    ),
                    Chip(
                      label: Text(
                        l10n.tripDetailsChecklistStat(
                          trip.completedChecklistCount,
                          trip.checklist.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // D04 Günlük Plan ve D05 Kontrol Listesi geçiş butonları.
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: l10n.tripDetailsItineraryButton,
                  icon: Icons.edit_calendar_outlined,
                  onPressed: () =>
                      context.push(AppRoutes.tripItineraryPath(trip.id)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SecondaryButton(
                  label: l10n.tripDetailsChecklistButton,
                  icon: Icons.checklist_rounded,
                  outlined: true,
                  onPressed: () =>
                      context.push(AppRoutes.tripChecklistPath(trip.id)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Gün Gün Rota Özeti.
          ...trip.days.map((day) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.itineraryDayLabel(day.dayNumber),
                          style: textTheme.titleMedium,
                        ),
                        if (day.dayDate != null)
                          Text(
                            AppDateFormatter.formatMonthDay(
                              context,
                              day.dayDate!,
                            ),
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (day.stops.isEmpty)
                      Text(
                        l10n.itineraryEmptyStops,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      )
                    else
                      ...day.stops.map((stop) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: colors.primaryContainer,
                            child: Text(
                              '${stop.orderIndex + 1}',
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: Text(stop.place?.name ?? stop.placeId),
                          subtitle: stop.notes != null
                              ? Text(stop.notes!)
                              : null,
                        );
                      }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
