import 'package:flutter/material.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';

/// Roamory'nin birincil aksiyon butonu (`52px` yükseklik, `14px` köşe yarıçapı).
///
/// İşlem devam ederken (`isLoading: true`) buton otomatik devre dışı bırakılır
/// ve çift gönderim/çift kayıt riski önlenir.
class PrimaryButton extends StatelessWidget {
  /// Birincil buton oluşturur.
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  /// Buton üzerinde gösterilecek yerelleştirilmiş metin.
  final String label;

  /// Tıklama geri çağrımı; `null` veya [isLoading] durumunda pasiftir.
  final VoidCallback? onPressed;

  /// Asenkron işlem sürerken yükleniyor göstergesi açar ve tıklamayı kilitler.
  final bool isLoading;

  /// Metnin yanında gösterilecek isteğe bağlı ikon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = RoamoryColors.of(context);
    final effectiveOnPressed = isLoading ? null : onPressed;

    return Semantics(
      button: true,
      enabled: effectiveOnPressed != null,
      label: label,
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton(
          onPressed: effectiveOnPressed,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: colors.onPrimary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// İkincil veya çerçeveli aksiyonlar için kullanılan Roamory butonu (`52px`).
///
/// [outlined] `true` ise ince kenarlıklı hayalet buton, `false` ise yumuşak
/// `primaryContainer` dolgulu ikincil buton olarak çizilir.
class SecondaryButton extends StatelessWidget {
  /// İkincil buton oluşturur.
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.icon,
  });

  /// Buton metni.
  final String label;

  /// Tıklama geri çağrımı.
  final VoidCallback? onPressed;

  /// Dolgulu yerine kenarlıklı stil kullanılıp kullanılmayacağı.
  final bool outlined;

  /// İsteğe bağlı ön ikon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: OutlinedButton(onPressed: onPressed, child: child),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
        ),
        child: child,
      ),
    );
  }
}
