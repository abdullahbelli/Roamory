import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_theme.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';

/// Roamory Flutter uygulamasının kök widget'ı.
///
/// Merkezi tema (`AppTheme`), çoklu dil desteği (`AppLocalizations` TR/EN),
/// kullanıcı tercihleri (`appPreferencesProvider`) ve `go_router` yönlendirmesini
/// tek noktada birleştirir.
class RoamoryApp extends ConsumerWidget {
  /// Uygulamanın kök widget'ını oluşturur.
  ///
  /// [useGoogleFonts] test ortamlarında ağ bağımlılığını önlemek için `false`
  /// verilebilir; üretimde varsayılan olarak `true` kullanılır.
  const RoamoryApp({super.key, this.useGoogleFonts = true});

  /// Tipografi için Google Fonts indirme davranışını kontrol eder.
  final bool useGoogleFonts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final preferences = ref.watch(appPreferencesProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(useGoogleFonts: useGoogleFonts),
      darkTheme: AppTheme.dark(useGoogleFonts: useGoogleFonts),
      themeMode: preferences.themeMode,
      locale: preferences.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    );
  }
}
