import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/community/presentation/providers/community_controller.dart';
import 'package:roamory/features/explore/presentation/providers/explore_controller.dart';
import 'package:roamory/features/trips/presentation/providers/trips_controller.dart';
import 'package:roamory/features/visits/presentation/providers/visits_controller.dart';
import 'package:roamory/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_network_image.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory İstek Listesi / Kaydedilen Mekanlar Ekranı (`B05` — Stitch `cc1d396ee299461595e6faf0e0e18b12`).
///
/// Kullanıcının `wishlist_items` tablosuna kaydettiği gerçek mekanları listeler,
/// ülke bazında filtreleme, detay görüntüleme, seyahat rotasına dahil etme ve
/// onaylı silme (`showAppConfirmSheet`) işlemlerini sağlar.
class WishlistScreen extends ConsumerStatefulWidget {
  /// İstek listesi ekranı oluşturur.
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  String? _selectedCountry;

  /// İstek listesindeki mekan için kişisel not ekleme/güncelleme alt sayfasını açar.
  Future<void> _showEditNoteSheet(WishlistItemEntity item) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: item.note ?? '');
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
                item.place?.name ?? l10n.wishlistTitle,
                style: Theme.of(sheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l10n.commonOptional,
                controller: controller,
                hintText: l10n.wishlistNoteHint,
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: l10n.commonSave,
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  await ref
                      .read(exploreControllerProvider.notifier)
                      .updateWishlistNote(
                        itemId: item.id,
                        note: controller.text.trim(),
                      );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// İstek listesindeki mekanı doğrudan mevcut bir seyahatin ilk gününe durak
  /// olarak ekler; henüz seyahat yoksa seyahat oluşturma ekranına yönlendirir.
  Future<void> _showAddToTripSheet(WishlistItemEntity item) async {
    final place = item.place;
    final trips = ref.read(tripsControllerProvider).trips;
    if (place == null || trips.isEmpty) {
      context.push(AppRoutes.trips);
      return;
    }
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            children: [
              Text(
                l10n.wishlistAddToTrip,
                style: Theme.of(sheetContext).textTheme.headlineSmall,
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
                            notes: item.note,
                          );
                    }
                    if (!mounted) {
                      return;
                    }
                    final err = ref.read(tripsControllerProvider).error;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          err != null
                              ? err.localizedMessage(l10n)
                              : l10n.wishlistAddedToTripMessage,
                        ),
                      ),
                    );
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
    final communityState = ref.watch(communityControllerProvider);
    final state = ref.watch(exploreControllerProvider);
    final notifier = ref.read(exploreControllerProvider.notifier);

    final countries = state.wishlist
        .map((w) => w.place?.country.trim())
        .whereType<String>()
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    final filteredItems = _selectedCountry == null
        ? state.wishlist
        : state.wishlist
              .where((w) => w.place?.country == _selectedCountry)
              .toList();

    return RoamoryScaffold(
      appBar: AppBar(title: Text(l10n.wishlistTitle)),
      body: state.wishlist.isEmpty
          ? EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: l10n.wishlistEmptyTitle,
              message: l10n.wishlistEmptyMessage,
              actionLabel: l10n.wishlistExploreCta,
              onAction: () => context.go(AppRoutes.explore),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.pageMargin),
              children: [
                Text(
                  l10n.wishlistSubtitle(filteredItems.length),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (countries.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.commonAll),
                        selected: _selectedCountry == null,
                        onSelected: (_) =>
                            setState(() => _selectedCountry = null),
                      ),
                      ...countries.map((country) {
                        return ChoiceChip(
                          label: Text(country),
                          selected: _selectedCountry == country,
                          onSelected: (_) => setState(
                            () => _selectedCountry = _selectedCountry == country
                                ? null
                                : country,
                          ),
                        );
                      }),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                ...filteredItems.map((item) {
                  final place = item.place;
                  final coverUrl = state.resolvePlaceCoverUrl(
                    place,
                    userVisits: visitsState.visits,
                    feedPosts: communityState.feedPosts,
                    currentUserId: authState.user?.id,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
                              AppNetworkImage(
                                imageUrl: coverUrl,
                                width: 64,
                                height: 64,
                                borderRadius: AppSpacing.radiusMd,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: InkWell(
                                  onTap: () => context.push(
                                    AppRoutes.placeDetailsPath(item.placeId),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place?.name ?? item.placeId,
                                        style: textTheme.titleMedium,
                                      ),
                                      if (place != null)
                                        Text(
                                          place.locationLabel,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                      if (item.note != null &&
                                          item.note!.trim().isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          item.note!,
                                          style: textTheme.labelSmall?.copyWith(
                                            color: colors.primary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.wishlistNoteHint,
                                onPressed: () => _showEditNoteSheet(item),
                                icon: Icon(
                                  Icons.edit_note_rounded,
                                  color: colors.primary,
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.commonDelete,
                                onPressed: () async {
                                  if (place == null) {
                                    return;
                                  }
                                  final confirmed = await showAppConfirmSheet(
                                    context: context,
                                    title: l10n.wishlistRemoveConfirmTitle,
                                    message: l10n.wishlistRemoveConfirmMessage,
                                    confirmLabel: l10n.commonDelete,
                                    isDestructive: true,
                                  );
                                  if (confirmed) {
                                    await notifier.toggleWishlist(place);
                                  }
                                },
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: colors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              alignment: WrapAlignment.end,
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xs,
                              children: [
                                TextButton.icon(
                                  onPressed: () => context.push(
                                    '${AppRoutes.visitAdd}?placeId=${item.placeId}',
                                  ),
                                  icon: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    l10n.placeDetailsActionMarkVisited,
                                  ),
                                ),
                                FilledButton.tonalIcon(
                                  onPressed: () => _showAddToTripSheet(item),
                                  icon: const Icon(
                                    Icons.route_outlined,
                                    size: 18,
                                  ),
                                  label: Text(l10n.wishlistAddToTrip),
                                ),
                              ],
                            ),
                          ),
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
