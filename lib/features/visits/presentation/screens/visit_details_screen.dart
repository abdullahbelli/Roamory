import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/core/utils/app_date_formatter.dart';
import 'package:roamory/features/visits/presentation/providers/visits_controller.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_network_image.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Ziyaret Detayı Ekranı (`C06` — Stitch `8b0cbcd9cdee41228d5febfde96e3249`).
///
/// Kullanıcının özel ziyaret kaydını, fotoğraflarını, puanını ve günlük notlarını
/// gösterir; düzenleme (`C05`), onaylı silme (`visit-photos` Storage temizliğiyle)
/// ve bilinçli topluluk gönderisine dönüştürme (`C06` -> `E02`) aksiyonlarını sunar.
class VisitDetailsScreen extends ConsumerWidget {
  /// Ziyaret detayı ekranı oluşturur.
  const VisitDetailsScreen({super.key, required this.visitId});

  /// Görüntülenecek ziyaret kimliği (`visits.id`).
  final String visitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(visitsControllerProvider);
    final visit = state.findById(visitId);

    if (visit == null) {
      return RoamoryScaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.event_busy_outlined,
          title: l10n.errorNotFoundMessage,
          actionLabel: l10n.commonBack,
          onAction: () => context.pop(),
        ),
      );
    }

    return RoamoryScaffold(
      appBar: AppBar(
        title: Text(l10n.visitDetailsTitle),
        actions: [
          IconButton(
            tooltip: l10n.commonEdit,
            onPressed: () => context.push(AppRoutes.visitJournalPath(visit.id)),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: l10n.commonDelete,
            onPressed: () async {
              final confirmed = await showAppConfirmSheet(
                context: context,
                title: l10n.visitDetailsDeleteConfirmTitle,
                message: l10n.visitDetailsDeleteConfirmMessage,
                confirmLabel: l10n.commonDelete,
                isDestructive: true,
              );
              if (confirmed && context.mounted) {
                final deleted = await ref
                    .read(visitsControllerProvider.notifier)
                    .deleteVisit(visit.id);
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
          // Gizlilik rozeti ve tarih damgası.
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.commonPrivateBadge,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                AppDateFormatter.format(
                  context,
                  visit.visitedAt,
                  longMonth: true,
                ),
                style: textTheme.labelMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            visit.title?.trim().isNotEmpty == true
                ? visit.title!
                : (visit.place?.name ?? l10n.visitDetailsTitle),
            style: textTheme.headlineMedium,
          ),
          if (visit.place != null) ...[
            const SizedBox(height: 4),
            InkWell(
              onTap: () =>
                  context.push(AppRoutes.placeDetailsPath(visit.place!.id)),
              child: Row(
                children: [
                  Icon(Icons.place_outlined, size: 18, color: colors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${visit.place!.name} • ${visit.place!.locationLabel}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (visit.rating != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < visit.rating!
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: colors.accent,
                  size: 22,
                ),
              ),
            ),
          ],

          // Ziyaret fotoğrafları (visit-photos signed URL galerisi).
          if (visit.photos.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: visit.photos.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  return AppNetworkImage(
                    imageUrl: visit.photos[index].signedUrl,
                    width: 260,
                    height: 200,
                    borderRadius: AppSpacing.radiusLg,
                  );
                },
              ),
            ),
          ],

          // Kişisel günlük notu.
          if (visit.notes != null && visit.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: colors.outline),
              ),
              child: Text(visit.notes!, style: textTheme.bodyLarge),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),

          // C06 -> E02 Topluluk Gönderisine Dönüştür kartı (bilinçli paylaşım).
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: colors.accentContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.visitDetailsConvertToPostTitle,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onAccentContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.visitDetailsConvertToPostSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onAccentContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: l10n.visitDetailsConvertToPostButton,
                  icon: Icons.public_rounded,
                  onPressed: () => context.push(
                    '${AppRoutes.postCreate}?visitId=${visit.id}&placeId=${visit.placeId}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
