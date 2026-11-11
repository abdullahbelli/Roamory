import 'package:flutter/material.dart';

/// Roamory uygulamasının tek otoriter renk tokenlarını ve tema uzantısını tanımlar.
///
/// `design.md` içinde belirlenen Earthy Modernist Journal paleti temel alınır;
/// ekranlarda doğrudan sabit hex kodu kullanılmaz, bunun yerine `Theme.of(context)`
/// veya [RoamoryColors.of] üzerinden erişilir.
@immutable
class RoamoryColors extends ThemeExtension<RoamoryColors> {
  /// Semantik renk tokenlarıyla yeni bir [RoamoryColors] örneği oluşturur.
  const RoamoryColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.accent,
    required this.onAccent,
    required this.accentContainer,
    required this.onAccentContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.outline,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.warning,
    required this.success,
    required this.cardShadow,
    required this.floatingShadow,
    required this.navBarSurface,
  });

  /// Açık tema (Earthy Modernist Journal) otoriter marka renkleri.
  static const RoamoryColors light = RoamoryColors(
    primary: Color(0xFF176B5B),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE0F2ED),
    onPrimaryContainer: Color(0xFF0F4A3F),
    accent: Color(0xFFD7A65C),
    onAccent: Color(0xFF1F2D2A),
    accentContainer: Color(0xFFFBF3E6),
    onAccentContainer: Color(0xFF6A4C17),
    tertiary: Color(0xFF4A90E2),
    onTertiary: Color(0xFFFFFFFF),
    background: Color(0xFFF7F8F5),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEEF2EE),
    outline: Color(0xFFD9E2DF),
    textPrimary: Color(0xFF1F2D2A),
    textSecondary: Color(0xFF596D68),
    error: Color(0xFFD34538),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFCE8E6),
    onErrorContainer: Color(0xFF8C251C),
    warning: Color(0xFFE68A1B),
    success: Color(0xFF2E8B57),
    // Tinted ambient occlusion: yeşilimsi yumuşak kart gölgesi (design.md).
    cardShadow: Color(0x0F176B5B),
    floatingShadow: Color(0x1A176B5B),
    // Frosted alt navigasyon yüzeyi (%90 opak beyaz).
    navBarSurface: Color(0xE6FFFFFF),
  );

  /// Koyu tema için yüksek kontrastlı ve göz yormayan semantik tokenlar.
  static const RoamoryColors dark = RoamoryColors(
    primary: Color(0xFF4BB89F),
    onPrimary: Color(0xFF072922),
    primaryContainer: Color(0xFF13443A),
    onPrimaryContainer: Color(0xFFBDEEE1),
    accent: Color(0xFFE2B874),
    onAccent: Color(0xFF2A1D08),
    accentContainer: Color(0xFF3D2F18),
    onAccentContainer: Color(0xFFF7DFB6),
    tertiary: Color(0xFF6BA6EB),
    onTertiary: Color(0xFF0A2442),
    background: Color(0xFF0F1715),
    surface: Color(0xFF16221F),
    surfaceVariant: Color(0xFF1E2E2A),
    outline: Color(0xFF2C3F3A),
    textPrimary: Color(0xFFEDF2F0),
    textSecondary: Color(0xFF9BB0AA),
    error: Color(0xFFF06A5E),
    onError: Color(0xFF3B0E0A),
    errorContainer: Color(0xFF4D1A15),
    onErrorContainer: Color(0xFFFAD2CE),
    warning: Color(0xFFF2A33C),
    success: Color(0xFF45B073),
    cardShadow: Color(0x33000000),
    floatingShadow: Color(0x4D000000),
    navBarSurface: Color(0xE616221F),
  );

  /// Ana eylemler, aktif navigasyon öğesi ve ziyaret edilmiş harita pini rengi.
  final Color primary;

  /// [primary] üzerindeki metin ve ikon rengi.
  final Color onPrimary;

  /// Chip, rozet ve seçili liste satırı arka planı.
  final Color primaryContainer;

  /// [primaryContainer] üzerindeki metin ve ikon rengi.
  final Color onPrimaryContainer;

  /// İstek listesi pini, yıldızlar ve dönüm noktaları için sıcak kum taşı vurgusu.
  final Color accent;

  /// [accent] üzerindeki metin ve ikon rengi.
  final Color onAccent;

  /// Sıcak vurgu kartları ve rozet dolguları.
  final Color accentContainer;

  /// [accentContainer] üzerindeki metin ve ikon rengi.
  final Color onAccentContainer;

  /// Topluluk akışı ve diğer gezgin harita pinleri için kullanılan renk.
  final Color tertiary;

  /// [tertiary] üzerindeki metin ve ikon rengi.
  final Color onTertiary;

  /// Sayfa ana tuval arka plan rengi.
  final Color background;

  /// Kartlar, alt sayfalar ve açılır yüzeyler için ana yüzey rengi.
  final Color surface;

  /// Arama çubukları, segmented kontrol yuvaları ve pasif girdi yüzeyleri.
  final Color surfaceVariant;

  /// İnce ayırıcılar ve kart kenarlıkları.
  final Color outline;

  /// Başlık ve ana içerik metin rengi.
  final Color textPrimary;

  /// Yardımcı açıklamalar, tarih damgaları ve ikincil etiketler.
  final Color textSecondary;

  /// Doğrulama ve ağ hataları için uyarı/hata rengi.
  final Color error;

  /// [error] üzerindeki metin ve ikon rengi.
  final Color onError;

  /// Hata özet kutuları için yumuşak hata arka planı.
  final Color errorContainer;

  /// [errorContainer] üzerindeki metin rengi.
  final Color onErrorContainer;

  /// Dikkat gerektiren durumlar için uyarı rengi.
  final Color warning;

  /// Başarılı kayıt ve doğrulama durumu rengi.
  final Color success;

  /// Kartlar için hafif çevresel gölge rengi.
  final Color cardShadow;

  /// Yüzen alt menü ve overlay bileşenleri için gölge rengi.
  final Color floatingShadow;

  /// Yarı saydam yüzen alt navigasyon çubuğu arka planı.
  final Color navBarSurface;

  /// Mevcut [BuildContext] içinden aktif [RoamoryColors] uzantısını döndürür.
  ///
  /// Tema uzantısı tanımlanmamış izole test ağaçlarında güvenli fallback olarak
  /// [RoamoryColors.light] döner.
  static RoamoryColors of(BuildContext context) {
    return Theme.of(context).extension<RoamoryColors>() ?? light;
  }

  @override
  RoamoryColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? accent,
    Color? onAccent,
    Color? accentContainer,
    Color? onAccentContainer,
    Color? tertiary,
    Color? onTertiary,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? outline,
    Color? textPrimary,
    Color? textSecondary,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? warning,
    Color? success,
    Color? cardShadow,
    Color? floatingShadow,
    Color? navBarSurface,
  }) {
    return RoamoryColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentContainer: accentContainer ?? this.accentContainer,
      onAccentContainer: onAccentContainer ?? this.onAccentContainer,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      outline: outline ?? this.outline,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      cardShadow: cardShadow ?? this.cardShadow,
      floatingShadow: floatingShadow ?? this.floatingShadow,
      navBarSurface: navBarSurface ?? this.navBarSurface,
    );
  }

  @override
  RoamoryColors lerp(ThemeExtension<RoamoryColors>? other, double t) {
    if (other is! RoamoryColors) {
      return this;
    }
    // Tema geçişlerinde tüm renk tokenlarını yumuşak biçimde enterpole ediyoruz.
    return RoamoryColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentContainer: Color.lerp(accentContainer, other.accentContainer, t)!,
      onAccentContainer: Color.lerp(
        onAccentContainer,
        other.onAccentContainer,
        t,
      )!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(
        onErrorContainer,
        other.onErrorContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      floatingShadow: Color.lerp(floatingShadow, other.floatingShadow, t)!,
      navBarSurface: Color.lerp(navBarSurface, other.navBarSurface, t)!,
    );
  }
}
