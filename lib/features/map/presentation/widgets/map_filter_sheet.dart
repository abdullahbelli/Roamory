import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/visits/presentation/providers/visits_controller.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';

/// Harita Filtreleme Alt Sayfasını (`C02` — Stitch `3895b391baab46d0b52ab1f6d282b877`) açar.
Future<void> showMapFilterSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const MapFilterSheet(),
  );
}

/// Kişisel harita (`C01`) üzerindeki pinleri katmana, yıla ve 4+ yıldızlı
/// favorilere göre filtreleyen alt sayfa bileşeni (`C02`).
class MapFilterSheet extends ConsumerWidget {
  /// Harita filtre sayfası oluşturur.
  const MapFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(visitsControllerProvider);
    final notifier = ref.read(visitsControllerProvider.notifier);
    final filter = state.filter;

    final years = state.visits.map((v) => v.visitedAt.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        AppSpacing.md,
        AppSpacing.pageMargin,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.mapFilterButton, style: textTheme.headlineSmall),
              TextButton(
                onPressed: notifier.resetFilter,
                child: Text(l10n.commonReset),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.mapFilterLayerTitle, style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              ChoiceChip(
                label: Text(l10n.mapFilterLayerAll),
                selected: filter.layer == MapLayerFilter.all,
                onSelected: (_) => notifier.updateFilter(
                  filter.copyWith(layer: MapLayerFilter.all),
                ),
              ),
              ChoiceChip(
                label: Text(l10n.mapFilterLayerVisited),
                selected: filter.layer == MapLayerFilter.visited,
                onSelected: (_) => notifier.updateFilter(
                  filter.copyWith(layer: MapLayerFilter.visited),
                ),
              ),
              ChoiceChip(
                label: Text(l10n.mapFilterLayerWishlist),
                selected: filter.layer == MapLayerFilter.wishlist,
                onSelected: (_) => notifier.updateFilter(
                  filter.copyWith(layer: MapLayerFilter.wishlist),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.mapFilterOnlyFavorites),
            value: filter.onlyFavorites,
            onChanged: (v) =>
                notifier.updateFilter(filter.copyWith(onlyFavorites: v)),
          ),
          if (years.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.mapFilterYearLabel, style: textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                ChoiceChip(
                  label: Text(l10n.commonAll),
                  selected: filter.year == null,
                  onSelected: (_) =>
                      notifier.updateFilter(filter.copyWith(clearYear: true)),
                ),
                ...years.map((y) {
                  return ChoiceChip(
                    label: Text(y.toString()),
                    selected: filter.year == y,
                    onSelected: (_) => notifier.updateFilter(
                      filter.copyWith(
                        year: filter.year == y ? null : y,
                        clearYear: filter.year == y,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: l10n.commonApply,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
