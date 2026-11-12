import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/trips/domain/entities/trip_entity.dart';
import 'package:roamory/features/trips/presentation/providers/trips_controller.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Seyahat Kontrol Listesi Ekranı (`D05` — Stitch `98ee3f26a6d24afbbacbfa1eaf77a2e9`).
///
/// Seyahate ait `trip_checklist_items` maddelerini ilerleme çubuğu, durum filtresi
/// (`Tümü`, `Eksikler`, `Tamamlananlar`), kategori seçimi (`docs`, `gear`, `hotel`,
/// `general`), tamamlama işaretlemesi ve silme aksiyonlarıyla yönetir.
class TripChecklistScreen extends ConsumerStatefulWidget {
  /// Seyahat kontrol listesi ekranı oluşturur.
  const TripChecklistScreen({super.key, required this.tripId});

  /// İlgili seyahat kimliği (`trips.id`).
  final String tripId;

  @override
  ConsumerState<TripChecklistScreen> createState() =>
      _TripChecklistScreenState();
}

class _TripChecklistScreenState extends ConsumerState<TripChecklistScreen> {
  final TextEditingController _itemController = TextEditingController();
  String _selectedCategory = TripChecklistCategory.general;
  String _statusFilter = 'all';

  /// Veritabanı kategori kodunu (`general`, `docs`, `gear`, `hotel`) yalnızca
  /// arayüzde gösterilmek üzere yerelleştirilmiş etikete dönüştürür.
  String _localizedCategoryLabel(AppLocalizations l10n, String categoryCode) {
    return switch (TripChecklistCategory.normalize(categoryCode)) {
      TripChecklistCategory.docs => l10n.checklistCategoryDocs,
      TripChecklistCategory.gear => l10n.checklistCategoryGear,
      TripChecklistCategory.hotel => l10n.checklistCategoryHotel,
      _ => l10n.checklistCategoryGeneral,
    };
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final text = _itemController.text.trim();
    if (text.isEmpty) {
      return;
    }
    final ok = await ref
        .read(tripsControllerProvider.notifier)
        .addChecklistItem(
          tripId: widget.tripId,
          title: text,
          category: _selectedCategory,
        );
    if (!mounted) {
      return;
    }
    if (ok) {
      _itemController.clear();
      return;
    }
    final err = ref.read(tripsControllerProvider).error;
    if (err != null) {
      // Kontrol listesi öğesi eklenemediğinde kullanıcıya yerelleştirilmiş hata gösteriyoruz.
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err.localizedMessage(l10n))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(tripsControllerProvider);
    final notifier = ref.read(tripsControllerProvider.notifier);
    final trip = state.findById(widget.tripId);

    if (trip == null) {
      return RoamoryScaffold(
        appBar: AppBar(title: Text(l10n.checklistTitle)),
        body: EmptyState(title: l10n.errorNotFoundMessage),
      );
    }

    final total = trip.checklist.length;
    final done = trip.completedChecklistCount;
    final progress = total == 0 ? 0.0 : done / total;

    final items = trip.checklist.where((item) {
      if (_statusFilter == 'pending') {
        return !item.isCompleted;
      }
      if (_statusFilter == 'completed') {
        return item.isCompleted;
      }
      return true;
    }).toList();

    return RoamoryScaffold(
      appBar: AppBar(title: Text(l10n.checklistTitle)),
      body: Column(
        children: [
          // İlerleme Özeti Kartı.
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
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
                        l10n.checklistProgressTitle,
                        style: textTheme.titleMedium,
                      ),
                      Text(
                        '${(progress * 100).round()}% • ${l10n.tripDetailsChecklistStat(done, total)}',
                        style: textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ],
              ),
            ),
          ),

          // Filtre chipleri.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageMargin,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  ChoiceChip(
                    label: Text(l10n.checklistFilterAll),
                    selected: _statusFilter == 'all',
                    onSelected: (_) => setState(() => _statusFilter = 'all'),
                  ),
                  ChoiceChip(
                    label: Text(l10n.checklistFilterPending),
                    selected: _statusFilter == 'pending',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'pending'),
                  ),
                  ChoiceChip(
                    label: Text(l10n.checklistFilterCompleted),
                    selected: _statusFilter == 'completed',
                    onSelected: (_) =>
                        setState(() => _statusFilter = 'completed'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Yeni madde ekleme çubuğu.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageMargin,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    decoration: InputDecoration(
                      hintText: l10n.checklistAddItemHint,
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: [
                    DropdownMenuItem(
                      value: TripChecklistCategory.general,
                      child: Text(l10n.checklistCategoryGeneral),
                    ),
                    DropdownMenuItem(
                      value: TripChecklistCategory.docs,
                      child: Text(l10n.checklistCategoryDocs),
                    ),
                    DropdownMenuItem(
                      value: TripChecklistCategory.gear,
                      child: Text(l10n.checklistCategoryGear),
                    ),
                    DropdownMenuItem(
                      value: TripChecklistCategory.hotel,
                      child: Text(l10n.checklistCategoryHotel),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedCategory = v);
                    }
                  },
                ),
                IconButton.filled(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: Icons.checklist_rounded,
                    title: l10n.checklistEmptyMessage,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageMargin,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return CheckboxListTile(
                        value: item.isCompleted,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          item.title,
                          style: TextStyle(
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          _localizedCategoryLabel(l10n, item.category),
                        ),
                        secondary: IconButton(
                          tooltip: l10n.commonDelete,
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final ok = await notifier.deleteChecklistItem(
                              tripId: trip.id,
                              itemId: item.id,
                            );
                            if (!ok && mounted) {
                              final err = ref
                                  .read(tripsControllerProvider)
                                  .error;
                              if (err != null) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(err.localizedMessage(l10n)),
                                  ),
                                );
                              }
                            }
                          },
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: colors.error,
                          ),
                        ),
                        onChanged: (_) async {
                          final messenger = ScaffoldMessenger.of(context);
                          final ok = await notifier.toggleChecklistItem(
                            tripId: trip.id,
                            item: item,
                          );
                          if (!ok && mounted) {
                            final err = ref.read(tripsControllerProvider).error;
                            if (err != null) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(err.localizedMessage(l10n)),
                                ),
                              );
                            }
                          }
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
