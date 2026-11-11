import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roamory/app/theme/app_colors.dart';

/// Roamory tipografi hiyerarşisini (`Plus Jakarta Sans` + `Inter`) üretir.
///
/// Başlıklar için karakterli geometrik `Plus Jakarta Sans`, gövde ve etiketler için
/// yüksek okunurluklu `Inter` kullanılır; Türkçe özel karakterler desteklenir.
abstract final class AppTypography {
  /// [colors] renk paletiyle uyumlu Material [TextTheme] oluşturur.
  ///
  /// [useGoogleFonts] test ortamlarında ağ font indirmelerini engellemek için
  /// `false` olarak geçirilebilir; üretimde varsayılan `true`'dur.
  static TextTheme buildTextTheme(
    RoamoryColors colors, {
    bool useGoogleFonts = true,
  }) {
    // Başlık ve gövde stillerini Türkçe diakritik desteğiyle oluşturuyoruz.
    TextStyle headlineStyle({
      required double size,
      required double height,
      required FontWeight weight,
      required double letterSpacingEm,
    }) {
      final base = TextStyle(
        fontSize: size,
        height: height / size,
        fontWeight: weight,
        letterSpacing: size * letterSpacingEm,
        color: colors.textPrimary,
      );
      if (!useGoogleFonts) {
        return base.copyWith(fontFamily: 'Plus Jakarta Sans');
      }
      return GoogleFonts.plusJakartaSans(textStyle: base);
    }

    TextStyle bodyStyle({
      required double size,
      required double height,
      required FontWeight weight,
      required double letterSpacingEm,
      Color? color,
    }) {
      final base = TextStyle(
        fontSize: size,
        height: height / size,
        fontWeight: weight,
        letterSpacing: size * letterSpacingEm,
        color: color ?? colors.textPrimary,
      );
      if (!useGoogleFonts) {
        return base.copyWith(fontFamily: 'Inter');
      }
      return GoogleFonts.inter(textStyle: base);
    }

    return TextTheme(
      displayLarge: headlineStyle(
        size: 30,
        height: 38,
        weight: FontWeight.w700,
        letterSpacingEm: -0.02,
      ),
      headlineLarge: headlineStyle(
        size: 26,
        height: 32,
        weight: FontWeight.w700,
        letterSpacingEm: -0.015,
      ),
      headlineMedium: headlineStyle(
        size: 22,
        height: 28,
        weight: FontWeight.w600,
        letterSpacingEm: -0.01,
      ),
      headlineSmall: headlineStyle(
        size: 18,
        height: 24,
        weight: FontWeight.w600,
        letterSpacingEm: 0,
      ),
      titleMedium: bodyStyle(
        size: 16,
        height: 22,
        weight: FontWeight.w600,
        letterSpacingEm: -0.005,
      ),
      bodyLarge: bodyStyle(
        size: 16,
        height: 24,
        weight: FontWeight.w400,
        letterSpacingEm: 0,
      ),
      bodyMedium: bodyStyle(
        size: 14,
        height: 20,
        weight: FontWeight.w400,
        letterSpacingEm: 0,
      ),
      bodySmall: bodyStyle(
        size: 12,
        height: 16,
        weight: FontWeight.w400,
        letterSpacingEm: 0,
        color: colors.textSecondary,
      ),
      labelLarge: bodyStyle(
        size: 14,
        height: 18,
        weight: FontWeight.w600,
        letterSpacingEm: 0.01,
      ),
      labelMedium: bodyStyle(
        size: 12,
        height: 16,
        weight: FontWeight.w600,
        letterSpacingEm: 0.02,
        color: colors.textSecondary,
      ),
      labelSmall: bodyStyle(
        size: 10,
        height: 14,
        weight: FontWeight.w500,
        letterSpacingEm: 0.03,
        color: colors.textSecondary,
      ),
    );
  }
}
