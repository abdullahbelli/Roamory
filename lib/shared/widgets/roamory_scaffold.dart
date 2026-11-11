import 'package:flutter/material.dart';
import 'package:roamory/app/theme/app_colors.dart';

/// Roamory sayfaları için tutarlı arka plan, safe area ve yüzen alt bar iskelesi.
///
/// Alt navigasyon yüzen bir katman olduğu için `extendBody: true` kullanılır ve
/// ana içeriklerin alt bar arkasında gizlenmemesi sağlanır.
class RoamoryScaffold extends StatelessWidget {
  /// Sayfa iskelesi oluşturur.
  const RoamoryScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.extendBody = false,
    this.resizeToAvoidBottomInset = true,
  });

  /// Sayfa ana içeriği.
  final Widget body;

  /// İsteğe bağlı üst uygulama çubuğu.
  final PreferredSizeWidget? appBar;

  /// Yüzen alt navigasyon çubuğu (yalnızca 5 ana sekmede verilir).
  final Widget? bottomNavigationBar;

  /// İsteğe bağlı yüzen aksiyon butonu.
  final Widget? floatingActionButton;

  /// Özel arka plan rengi; verilmezse tema arka planı kullanılır.
  final Color? backgroundColor;

  /// Alt navigasyon çubuğunun arkasından kaydırma akışı sağlamak için `true` yapılır.
  final bool extendBody;

  /// Klavye açıldığında gövdenin yeniden boyutlanıp boyutlanmayacağı.
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final colors = RoamoryColors.of(context);

    return Scaffold(
      backgroundColor: backgroundColor ?? colors.background,
      extendBody: extendBody || bottomNavigationBar != null,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
