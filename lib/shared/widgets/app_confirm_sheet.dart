import 'package:flutter/material.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';

/// Kritik silme, çıkış veya kaydedilmemiş değişiklik onayları için alt sayfa açar.
///
/// Stitch `S04` ve `design.md` (`radiusSheet: 24px`) kurallarına uygun olarak
/// kullanıcının yanlışlıkla veri kaybetmesini önlemek amacıyla `true`/`false`
/// onay sonucu döndürür.
Future<bool> showAppConfirmSheet({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  bool isDestructive = false,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return AppConfirmSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      );
    },
  );
  return result ?? false;
}

/// Onay alt sayfasının içerik widget'ı.
class AppConfirmSheet extends StatelessWidget {
  /// Onay sayfası oluşturur.
  const AppConfirmSheet({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.isDestructive = false,
  });

  /// Onay başlığı.
  final String title;

  /// Kullanıcıyı sonucundan haberdar eden açıklama metni.
  final String message;

  /// Onay butonu etiketi.
  final String? confirmLabel;

  /// İptal butonu etiketi.
  final String? cancelLabel;

  /// Yıkıcı işlemlerde (`Sil`, `Değişiklikleri At` vb.) hata/uyarı rengi uygular.
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        AppSpacing.md,
        AppSpacing.pageMargin,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.outline,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDestructive
                  ? colors.errorContainer
                  : colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDestructive
                  ? Icons.warning_amber_rounded
                  : Icons.help_outline_rounded,
              color: isDestructive ? colors.error : colors.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isDestructive)
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                ),
                child: Text(confirmLabel ?? l10n.commonConfirm),
              ),
            )
          else
            PrimaryButton(
              label: confirmLabel ?? l10n.commonConfirm,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: cancelLabel ?? l10n.commonCancel,
            outlined: true,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
