import 'package:flutter/material.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/app/theme/app_typography.dart';

/// Roamory uygulamasının merkezi açık ve koyu [ThemeData] fabrikası.
///
/// Tüm Material 3 bileşen temaları `design.md` renk, köşe yuvarlaklığı ve
/// boşluk tokenlarından türetilir; doğrudan widget içinde renk ezilmez.
abstract final class AppTheme {
  /// Açık tema yapılandırmasını döndürür.
  static ThemeData light({bool useGoogleFonts = true}) {
    return _buildTheme(
      brightness: Brightness.light,
      colors: RoamoryColors.light,
      useGoogleFonts: useGoogleFonts,
    );
  }

  /// Koyu tema yapılandırmasını döndürür.
  static ThemeData dark({bool useGoogleFonts = true}) {
    return _buildTheme(
      brightness: Brightness.dark,
      colors: RoamoryColors.dark,
      useGoogleFonts: useGoogleFonts,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required RoamoryColors colors,
    required bool useGoogleFonts,
  }) {
    final textTheme = AppTypography.buildTextTheme(
      colors,
      useGoogleFonts: useGoogleFonts,
    );

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.accent,
      onSecondary: colors.onAccent,
      secondaryContainer: colors.accentContainer,
      onSecondaryContainer: colors.onAccentContainer,
      tertiary: colors.tertiary,
      onTertiary: colors.onTertiary,
      error: colors.error,
      onError: colors.onError,
      errorContainer: colors.errorContainer,
      onErrorContainer: colors.onErrorContainer,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      surfaceContainerHighest: colors.surfaceVariant,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.outline,
      outlineVariant: colors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: colors.outline),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.surfaceVariant,
          disabledForegroundColor: colors.textSecondary,
          elevation: 0,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.outline, width: 1.5),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        labelStyle: textTheme.labelLarge?.copyWith(color: colors.textPrimary),
        errorStyle: textTheme.bodySmall?.copyWith(color: colors.error),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
      ),
      // Seçili filtre chip'lerinde (ChoiceChip, FilterChip) hem açık hem koyu
      // temada yüksek metin ve ikon kontrastı sağlamak için durum bazlı (selected)
      // renk çözümlemesi, Material 3 `color` ve `secondaryLabelStyle` birlikte tanımlanır.
      chipTheme: ChipThemeData(
        color: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          if (states.contains(WidgetState.disabled)) {
            return colors.surfaceVariant;
          }
          return colors.surface;
        }),
        backgroundColor: colors.surface,
        selectedColor: colors.primary,
        secondarySelectedColor: colors.primary,
        disabledColor: colors.surfaceVariant,
        checkmarkColor: colors.onPrimary,
        deleteIconColor: colors.textSecondary,
        iconTheme: IconThemeData(
          size: 18,
          color: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.onPrimary;
            }
            if (states.contains(WidgetState.disabled)) {
              return colors.textSecondary;
            }
            return colors.primary;
          }),
        ),
        // RawChip (ChoiceChip / FilterChip) widget'ı Material 3 içinde
        // `effectiveLabelStyle.color` özelliğini `WidgetStateProperty.resolveAs`
        // ile çözer; bu nedenle renk her zaman `WidgetStateColor` olarak verilir.
        labelStyle: (textTheme.labelMedium ?? const TextStyle(fontSize: 13))
            .copyWith(
              fontWeight: FontWeight.w600,
              color: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colors.onPrimary;
                }
                if (states.contains(WidgetState.disabled)) {
                  return colors.textSecondary;
                }
                return colors.textPrimary;
              }),
            ),
        secondaryLabelStyle:
            (textTheme.labelMedium ?? const TextStyle(fontSize: 13)).copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BorderSide(color: colors.primary, width: 1.5);
          }
          return BorderSide(color: colors.outline);
        }),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusSheet),
          ),
        ),
      ),
    );
  }
}
