import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulamanın yerel tercihlerini (dil, tema modu, karşılama turu) temsil eder.
@immutable
class AppPreferencesState {
  /// Tercih durumunu oluşturur.
  const AppPreferencesState({
    this.locale,
    this.themeMode = ThemeMode.system,
    this.onboardingCompleted = false,
  });

  /// Seçili uygulama dili; `null` ise cihaz dili kullanılır (TR/EN destekli).
  final Locale? locale;

  /// Kullanıcının seçtiği tema modu (`system`, `light`, `dark`).
  final ThemeMode themeMode;

  /// Kullanıcının A02 karşılama turunu tamamlayıp tamamlamadığı.
  final bool onboardingCompleted;

  /// Seçili alanları güncelleyerek yeni bir durum kopyası döner.
  AppPreferencesState copyWith({
    Locale? locale,
    bool clearLocale = false,
    ThemeMode? themeMode,
    bool? onboardingCompleted,
  }) {
    return AppPreferencesState(
      locale: clearLocale ? null : (locale ?? this.locale),
      themeMode: themeMode ?? this.themeMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}

/// Tercih verilerini kalıcı depolamaya yazan ve okuyan sözleşme.
///
/// Testlerde sahte (in-memory) implementasyonla değiştirilebilmesi için
/// soyutlanmıştır (SOLID - Dependency Inversion).
abstract interface class AppPreferencesStorage {
  /// Başlangıç tercihlerini senkron okur; açılışta tema/dil sıçramasını önler.
  AppPreferencesState loadSync();

  /// Dil kodunu (`tr` / `en` / `null`) kaydeder.
  Future<void> saveLocaleCode(String? languageCode);

  /// Tema modunu kaydeder.
  Future<void> saveThemeMode(ThemeMode mode);

  /// Karşılama turu tamamlanma bilgisini kaydeder.
  Future<void> saveOnboardingCompleted(bool completed);
}

/// [SharedPreferences] kullanan kalıcı tercih depolama implementasyonu.
class SharedPreferencesAppStorage implements AppPreferencesStorage {
  /// Verilen [SharedPreferences] örneğiyle depolama katmanını başlatır.
  const SharedPreferencesAppStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _localeKey = 'roamory.preferred_locale';
  static const _themeKey = 'roamory.theme_mode';
  static const _onboardingKey = 'roamory.onboarding_completed';

  @override
  AppPreferencesState loadSync() {
    final localeCode = _prefs.getString(_localeKey);
    final themeIndex = _prefs.getString(_themeKey);
    final onboarding = _prefs.getBool(_onboardingKey) ?? false;

    return AppPreferencesState(
      locale: localeCode == null ? null : Locale(localeCode),
      themeMode: switch (themeIndex) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      onboardingCompleted: onboarding,
    );
  }

  @override
  Future<void> saveLocaleCode(String? languageCode) async {
    if (languageCode == null) {
      await _prefs.remove(_localeKey);
      return;
    }
    await _prefs.setString(_localeKey, languageCode);
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.name);
  }

  @override
  Future<void> saveOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingKey, completed);
  }
}

/// Başlangıçta sağlanan tercih deposu provider'ı.
///
/// `main.dart` içinde uygulama açılmadan `overrideWithValue` ile gerçek
/// [SharedPreferencesAppStorage] verilir; testlerde sahte depo enjekte edilir.
final appPreferencesStorageProvider = Provider<AppPreferencesStorage?>((ref) {
  return null;
});

/// Uygulama dili, tema modu ve onboarding durumunu yöneten Riverpod Notifier.
class AppPreferencesNotifier extends Notifier<AppPreferencesState> {
  @override
  AppPreferencesState build() {
    // Tercihleri doğrudan senkron okuyarak async microtask yarış durumlarını önlüyoruz.
    final storage = ref.watch(appPreferencesStorageProvider);
    return storage?.loadSync() ?? const AppPreferencesState();
  }

  /// Uygulama dilini günceller ve tercihi kalıcı olarak saklar.
  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: locale, clearLocale: locale == null);
    await ref
        .read(appPreferencesStorageProvider)
        ?.saveLocaleCode(locale?.languageCode);
  }

  /// Tema modunu (`system` / `light` / `dark`) anında günceller.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await ref.read(appPreferencesStorageProvider)?.saveThemeMode(mode);
  }

  /// Karşılama turunun tamamlandığını işaretler.
  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingCompleted: true);
    await ref
        .read(appPreferencesStorageProvider)
        ?.saveOnboardingCompleted(true);
  }
}

/// Aktif [AppPreferencesState] durumunu sunan Riverpod sağlayıcısı.
final appPreferencesProvider =
    NotifierProvider<AppPreferencesNotifier, AppPreferencesState>(
      AppPreferencesNotifier.new,
    );
