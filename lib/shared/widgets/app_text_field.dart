import 'package:flutter/material.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';

/// Roamory tasarım sistemine uygun etiketli metin giriş alanı (`48px` yükseklik).
///
/// Doğrulama hatalarını ve odaktaki çerçeveyi tema üzerinden yönetir; ekranlarda
/// tekrar eden `InputDecoration` kalıplarını önler.
class AppTextField extends StatelessWidget {
  /// Metin giriş alanı oluşturur.
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.autofillHints,
  });

  /// Alanın üstünde gösterilecek etiket.
  final String label;

  /// Metin denetleyicisi.
  final TextEditingController? controller;

  /// Boşken gösterilecek ipucu metni.
  final String? hintText;

  /// Manuel veya sunucu kaynaklı hata metni.
  final String? errorText;

  /// Giriş alanının sol ikonu.
  final IconData? prefixIcon;

  /// Sağ tarafta yer alacak özel ikon/aksiyon.
  final Widget? suffixIcon;

  /// Parola girişlerinde karakterleri gizler.
  final bool obscureText;

  /// Klavye türü.
  final TextInputType? keyboardType;

  /// Klavye aksiyon tuşu.
  final TextInputAction? textInputAction;

  /// Satır sayısı (`1` dışındaysa çok satırlı günlük/not alanı olarak davranır).
  final int maxLines;

  /// Form doğrulama fonksiyonu.
  final FormFieldValidator<String>? validator;

  /// Değer değiştikçe tetiklenen geri çağrım.
  final ValueChanged<String>? onChanged;

  /// Klavyeden onaylandığında tetiklenen geri çağrım.
  final ValueChanged<String>? onFieldSubmitted;

  /// Alanın düzenlenebilir olup olmadığı.
  final bool enabled;

  /// Otomatik doldurma ipuçları.
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          enabled: enabled,
          autofillHints: autofillHints,
          style: textTheme.bodyMedium?.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            constraints: maxLines == 1
                ? const BoxConstraints(minHeight: AppSpacing.inputHeight)
                : null,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: colors.textSecondary)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
