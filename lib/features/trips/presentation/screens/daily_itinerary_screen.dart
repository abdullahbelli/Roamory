import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';
import 'package:roamory/features/explore/presentation/providers/explore_controller.dart';
import 'package:roamory/features/trips/domain/entities/trip_entity.dart';
import 'package:roamory/features/trips/presentation/providers/trips_controller.dart';
import 'package:roamory/features/visits/presentation/providers/visits_controller.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Günlük Rota Planlayıcı Ekranı (`D04` — Stitch `cc44ec026ada4b7bb5b0f374831c10d8`).
///
/// Seyahatin günleri (`trip_days`) arasında geçiş yapmayı, katalogdan veya istek
/// listesinden yeni durak (`trip_stops`) eklemeyi, durakları yukarı/aşağı taşıyarak
/// sıralamayı (`order_index`) ve durak silmeyi sağlar.
class DailyItineraryScreen extends ConsumerStatefulWidget {
  /// Günlük rota düzenleyici ekranı oluşturur.
  const DailyItineraryScreen({super.key, required this.tripId});

  /// Düzenlenen seyahat kimliği (`trips.id`).
  final String tripId;

  @override
  ConsumerState<DailyItineraryScreen> createState() =>
      _DailyItineraryScreenState();
}

class _DailyItineraryScreenState extends ConsumerState<DailyItineraryScreen> {
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) {
        return;
      }
      // Durak eklerken hem keşif/istek listesi hem de kullanıcının özel ziyaret mekanları hazır olsun diye gerekirse yükleriz.
      final explore = ref.read(exploreControllerProvider);
      if (explore.places.isEmpty && !explore.isLoading) {
        ref.read(exploreControllerProvider.notifier).loadInitial();
      }
      final visits = ref.read(visitsControllerProvider);
      if (visits.visits.isEmpty && !visits.isLoading) {
        ref.read(visitsControllerProvider.notifier).loadVisits();
      }
    });
  }

  /// Seçili günün tema başlığını veya günlük notunu düzenleme alt sayfasını açar (`trip_days`).
  Future<void> _showEditDayNotesSheet(TripDayEntity day) async {
    final l10n = AppLocalizations.of(context);
    final notesController = TextEditingController(
      text: day.notes ?? day.title ?? '',
    );
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageMargin,
            AppSpacing.md,
            AppSpacing.pageMargin,
            MediaQuery.viewInsetsOf(sheetContext).bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.itineraryDayLabel(day.dayNumber),
                style: Theme.of(sheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l10n.commonOptional,
                controller: notesController,
                hintText: l10n.itineraryDayNotesHint,
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: l10n.commonSave,
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  await ref
                      .read(tripsControllerProvider.notifier)
                      .updateDayInfo(
                        tripId: widget.tripId,
                        tripDayId: day.id,
                        notes: notesController.text.trim(),
                      );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Seçili güne katalog, istek listesi veya kullanıcının özel ziyaretlerinden durak (`trip_stops`) ekler.
  Future<void> _showAddStopSheet(String tripDayId) async {
    final l10n = AppLocalizations.of(context);
    final exploreState = ref.read(exploreControllerProvider);
    final visitsState = ref.read(visitsControllerProvider);
    final noteController = TextEditingController();

    // Aynı mekanın hem keşif hem istek listesi hem ziyarette tekrar etmemesi için kimliğe göre tekilleştiriyoruz.
    final uniquePlacesById = <String, PlaceEntity>{};
    for (final place in exploreState.places) {
      uniquePlacesById[place.id] = place;
    }
    for (final item in exploreState.wishlist) {
      final place = item.place;
      if (place != null) {
        uniquePlacesById.putIfAbsent(place.id, () => place);
      }
    }
    for (final visit in visitsState.visits) {
      final place = visit.place;
      if (place != null) {
        uniquePlacesById.putIfAbsent(place.id, () => place);
      }
    }
    final candidatePlaces = uniquePlacesById.values.toList();
    String? selectedPlaceId = candidatePlaces.isNotEmpty
        ? candidatePlaces.first.id
        : null;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final selectedPlace = selectedPlaceId == null
                ? null
                : uniquePlacesById[selectedPlaceId];
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                AppSpacing.md,
                AppSpacing.pageMargin,
                MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.itineraryAddStopButton,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (candidatePlaces.isEmpty) ...[
                    Text(
                      l10n.itineraryNoPlacesAvailable,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        if (mounted) {
                          this.context.push(AppRoutes.visitAdd);
                        }
                      },
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: Text(l10n.itineraryAddPrivatePlaceAction),
                    ),
                  ] else ...[
                    // PlaceEntity.== görsel URL değişimlerinden etkilenebileceği için dropdown değerini kimlik (String) üzerinden yönetiyoruz.
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedPlaceId,
                      items: candidatePlaces
                          .map(
                            (p) => DropdownMenuItem<String>(
                              value: p.id,
                              child: Text(
                                p.isPublished
                                    ? p.name
                                    : '${p.name} (${l10n.commonPrivateBadge})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setModalState(() => selectedPlaceId = v),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      label: l10n.commonOptional,
                      controller: noteController,
                      hintText: l10n.itineraryStopNoteHint,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      label: l10n.commonAdd,
                      onPressed: selectedPlace == null
                          ? null
                          : () async {
                              Navigator.of(sheetContext).pop();
                              await ref
                                  .read(tripsControllerProvider.notifier)
                                  .addStopToDay(
                                    tripId: widget.tripId,
                                    tripDayId: tripDayId,
                                    place: selectedPlace,
                                    notes: noteController.text.trim(),
                                  );
                              if (!mounted) {
                                return;
                              }
                              final err = ref
                                  .read(tripsControllerProvider)
                                  .error;
                              if (err != null) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text(err.localizedMessage(l10n)),
                                  ),
                                );
                              }
                            },
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(tripsControllerProvider);
    final notifier = ref.read(tripsControllerProvider.notifier);
    final trip = state.findById(widget.tripId);

    if (trip == null || trip.days.isEmpty) {
      return RoamoryScaffold(
        appBar: AppBar(title: Text(l10n.itineraryTitle)),
        body: EmptyState(
          icon: Icons.calendar_today_outlined,
          title: l10n.itineraryEmptyStops,
        ),
      );
    }

    final safeIndex = _selectedDayIndex.clamp(0, trip.days.length - 1);
    final currentDay = trip.days[safeIndex];

    return RoamoryScaffold(
      appBar: AppBar(title: Text(l10n.itineraryTitle)),
      body: Column(
        children: [
          // Gün seçici şeridi + yeni gün ekleme butonu.
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageMargin,
              ),
              itemCount: trip.days.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, index) {
                if (index == trip.days.length) {
                  return ActionChip(
                    avatar: const Icon(Icons.add_rounded, size: 16),
                    label: Text(l10n.itineraryAddDayButton),
                    onPressed: () async {
                      final added = await notifier.addDayToTrip(trip.id);
                      if (!mounted) {
                        return;
                      }
                      if (added != null) {
                        final updatedTrip = ref
                            .read(tripsControllerProvider)
                            .findById(trip.id);
                        final nextIndex =
                            (updatedTrip?.days.length ?? trip.days.length) - 1;
                        setState(
                          () =>
                              _selectedDayIndex = nextIndex < 0 ? 0 : nextIndex,
                        );
                        return;
                      }
                      final err = ref.read(tripsControllerProvider).error;
                      if (err != null) {
                        // Gün ekleme başarısız olduğunda sessiz kalmamak için hata mesajı gösteriyoruz.
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text(err.localizedMessage(l10n))),
                        );
                      }
                    },
                  );
                }
                final day = trip.days[index];
                return ChoiceChip(
                  label: Text(l10n.itineraryDayLabel(day.dayNumber)),
                  selected: index == safeIndex,
                  onSelected: (_) => setState(() => _selectedDayIndex = index),
                );
              },
            ),
          ),
          // Seçili günün teması veya günlük notu.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageMargin,
              vertical: AppSpacing.xs,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              onTap: () => _showEditDayNotesSheet(currentDay),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      size: 18,
                      color: colors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        (currentDay.notes != null &&
                                currentDay.notes!.trim().isNotEmpty)
                            ? currentDay.notes!
                            : l10n.itineraryDayNotesHint,
                        style: textTheme.bodySmall?.copyWith(
                          color:
                              (currentDay.notes != null &&
                                  currentDay.notes!.trim().isNotEmpty)
                              ? colors.textPrimary
                              : colors.textSecondary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: currentDay.stops.isEmpty
                ? EmptyState(
                    icon: Icons.alt_route_outlined,
                    title: l10n.itineraryEmptyStops,
                    actionLabel: l10n.itineraryAddStopButton,
                    onAction: () => _showAddStopSheet(currentDay.id),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.pageMargin),
                    itemCount: currentDay.stops.length,
                    onReorderItem: (oldIndex, newIndex) async {
                      final ok = await notifier.reorderStops(
                        tripId: trip.id,
                        tripDayId: currentDay.id,
                        oldIndex: oldIndex,
                        newIndex: newIndex,
                      );
                      if (!ok && mounted) {
                        final err = ref.read(tripsControllerProvider).error;
                        if (err != null) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(content: Text(err.localizedMessage(l10n))),
                          );
                        }
                      }
                    },
                    itemBuilder: (context, index) {
                      final stop = currentDay.stops[index];
                      return Card(
                        key: ValueKey(stop.id),
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors.primaryContainer,
                            child: Text(
                              '${index + 1}',
                              style: textTheme.labelMedium?.copyWith(
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: Text(stop.place?.name ?? stop.placeId),
                          subtitle: stop.notes != null && stop.notes!.isNotEmpty
                              ? Text(stop.notes!)
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: l10n.commonDelete,
                                onPressed: () async {
                                  final ok = await notifier.removeStop(
                                    tripId: trip.id,
                                    tripDayId: currentDay.id,
                                    stopId: stop.id,
                                  );
                                  if (!ok && mounted) {
                                    final err = ref
                                        .read(tripsControllerProvider)
                                        .error;
                                    if (err != null) {
                                      ScaffoldMessenger.of(this.context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                err.localizedMessage(l10n),
                                              ),
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
                              // Mobilde uzun basmaya gerek kalmadan tutamaçtan doğrudan sürükleme başlatılır.
                              ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle_rounded),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            child: PrimaryButton(
              label: l10n.itineraryAddStopButton,
              icon: Icons.add_location_alt_outlined,
              onPressed: () => _showAddStopSheet(currentDay.id),
            ),
          ),
        ],
      ),
    );
  }
}
