import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/community/presentation/providers/community_controller.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';

/// İçerik veya kullanıcı bildirme (`content_reports`) alt sayfasını açar (`T16`).
Future<void> showReportContentSheet(
  BuildContext context, {
  String? targetPostId,
  String? targetCommentId,
  String? targetUserId,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ReportContentSheet(
      targetPostId: targetPostId,
      targetCommentId: targetCommentId,
      targetUserId: targetUserId,
    ),
  );
}

/// Topluluk güvenliği için uygunsuz gönderi, yorum veya gezgin bildirme formu.
class ReportContentSheet extends ConsumerStatefulWidget {
  /// Raporlama alt sayfası oluşturur.
  const ReportContentSheet({
    super.key,
    this.targetPostId,
    this.targetCommentId,
    this.targetUserId,
  });

  /// Bildirilen gönderi kimliği.
  final String? targetPostId;

  /// Bildirilen yorum kimliği.
  final String? targetCommentId;

  /// Bildirilen kullanıcı kimliği.
  final String? targetUserId;

  @override
  ConsumerState<ReportContentSheet> createState() => _ReportContentSheetState();
}

class _ReportContentSheetState extends ConsumerState<ReportContentSheet> {
  String _selectedReason = 'spam';
  final TextEditingController _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

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
          Text(l10n.reportSheetTitle, style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          RadioGroup<String>(
            groupValue: _selectedReason,
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedReason = v);
              }
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: 'spam',
                  title: Text(l10n.reportReasonSpam),
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: 'inappropriate',
                  title: Text(l10n.reportReasonInappropriate),
                ),
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: 'harassment',
                  title: Text(l10n.reportReasonHarassment),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: l10n.commonOptional,
            controller: _detailsController,
            hintText: l10n.reportDetailsHint,
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: l10n.commonConfirm,
            onPressed: () async {
              final ok = await ref
                  .read(communityControllerProvider.notifier)
                  .reportContent(
                    reason: _selectedReason,
                    targetPostId: widget.targetPostId,
                    targetCommentId: widget.targetCommentId,
                    targetUserId: widget.targetUserId,
                    details: _detailsController.text.trim(),
                  );
              if (context.mounted) {
                Navigator.of(context).pop();
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.reportSubmittedMessage)),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
