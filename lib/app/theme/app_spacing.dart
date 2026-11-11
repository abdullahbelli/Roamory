import 'package:flutter/material.dart';

/// Roamory 8pt ızgara (4pt alt ızgara) boşluk, kenarlık yarıçapı ve bileşen ölçüleri.
///
/// Tüm ekranlar `design.md` yerleşim ölçüleriyle uyumlu olması için bu sabitleri kullanır.
abstract final class AppSpacing {
  /// Çok küçük boşluk (4px) - rozet/ikon hizalamaları.
  static const double xs = 4;

  /// Küçük boşluk (8px) - iç grup ve etiket aralıkları.
  static const double sm = 8;

  /// Orta boşluk (16px) - kart içi dolgu ve standart dikey/yatay oluk.
  static const double md = 16;

  /// Sayfa kenar boşluğu (20px) - mobil 393px referansında dış tuval boşluğu.
  static const double pageMargin = 20;

  /// Büyük boşluk (24px) - bölüm ayrımları.
  static const double lg = 24;

  /// Ekstra büyük boşluk (32px) - hero ve boş durum dikey boşlukları.
  static const double xl = 32;

  /// Mikro köşe yarıçapı (4px).
  static const double radiusXs = 4;

  /// Küçük köşe yarıçapı (8px).
  static const double radiusSm = 8;

  /// Standart girdi alanı ve küçük buton yarıçapı (12px).
  static const double radiusMd = 12;

  /// Ana aksiyon butonu köşe yarıçapı (14px).
  static const double radiusButton = 14;

  /// Kartlar ve günlük önizlemeleri için köşe yarıçapı (16px).
  static const double radiusLg = 16;

  /// Alt sayfaların (modal bottom sheet) üst köşe yarıçapı (24px).
  static const double radiusSheet = 24;

  /// Tam hap (pill) köşe yarıçapı.
  static const double radiusPill = 999;

  /// Birincil ve ikincil butonların standart dokunma yüksekliği (52px).
  static const double buttonHeight = 52;

  /// Metin giriş alanlarının standart yüksekliği (48px).
  static const double inputHeight = 48;

  /// Filtre ve kategori chip yüksekliği (36px).
  static const double chipHeight = 36;

  /// Yüzen alt navigasyon çubuğu yüksekliği (64px).
  static const double bottomNavHeight = 64;

  /// Yüzen alt navigasyon çubuğunun safe area üzerindeki boşluğu (16px).
  static const double bottomNavOffset = 16;

  /// Sayfa kenarları için yatay dolgu.
  static const EdgeInsets horizontalPagePadding = EdgeInsets.symmetric(
    horizontal: pageMargin,
  );

  /// Kart içi standart dolgu.
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
}
