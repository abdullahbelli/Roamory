import 'package:flutter/material.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';

/// Auth ekranlarında hata, başarı veya uyarı bildirimlerini gösteren banner.
class AuthFeedbackBanner extends StatelessWidget {
  /// Geri bildirim kutusu oluşturur.
  const AuthFeedbackBanner({
    super.key,
    required this.message,
    this.title,
    this.isError = true,
    this.isInfo = false,
    this.onClose,
  });

  /// Ana bildirim metni.
  final String message;

  /// İsteğe bağlı kalın başlık.
  final String? title;

  /// Hata görünümü kullanılıp kullanılmayacağı (`isInfo` false iken).
  final bool isError;

  /// Sıcak amber bilgilendirme banner'ı (`A05` sıfırlama bağlantısı gönderildi).
  final bool isInfo;

  /// Kapatma ikonu geri çağrımı.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final Color bgColor;
    final Color fgColor;
    final Color badgeColor;
    final IconData icon;

    if (isInfo) {
      bgColor = colors.accentContainer;
      fgColor = colors.onAccentContainer;
      badgeColor = colors.accent;
      icon = Icons.check_rounded;
    } else if (isError) {
      bgColor = colors.errorContainer;
      fgColor = colors.onErrorContainer;
      badgeColor = colors.error;
      icon = Icons.error_outline_rounded;
    } else {
      bgColor = colors.primaryContainer;
      fgColor = colors.onPrimaryContainer;
      badgeColor = colors.primary;
      icon = Icons.check_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isInfo ? colors.onAccent : colors.onPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: textTheme.labelLarge?.copyWith(color: fgColor),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: textTheme.bodySmall?.copyWith(
                    color: fgColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close, size: 18, color: fgColor),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}
