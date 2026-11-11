# Roamory — Yapılanlar Günlüğü

> Ev/ofis ortak, kronolojik ve eklemeli çalışma kaydı. Bu dosya kodun yerine geçmez: gerçek kaynak değişiklikleri Git ile taşınır. **Her anlamlı işlemden sonra bu kaydı güncelle.**

## Kayıt standardı
Her ekleme şu bilgileri içerir:
- **Tarih/saat ve ortam:** Yerel saat dilimi ve `Ev`, `Ofis` veya `Bilinmiyor` (tahmin etme).
- **Görev ID ve durum:** `tasks.md` referansı; başladı / ilerliyor / tamamlandı / engellendi.
- **Yapılan işlem:** Gerçekten yapılan değişiklik ve gerekçesi.
- **Değişen dosyalar:** Gerçek dosya yolları; eklenen/değiştirilen/silinen.
- **Veritabanı/Storage:** Çalıştırılan migration / schema farkı / onay durumu (varsa).
- **Test kanıtı:** Çalıştırılan komut, başarı veya tam hata özeti; çalışmadıysa `çalıştırılmadı`.
- **Commit referansı:** Varsa Git commit SHA / branch; yoksa `henüz commit yok`.
- **Sıradaki işlem ve engeller:** Diğer Antigravity'nin devam edebileceği net adım.

### Örnek (şablon; gerçek iş yapılmış sayılmaz)
```md
### YYYY-MM-DD HH:mm (+03:00) — Ev/Ofis — T05 / devam ediyor
- Yapılan: [Gerçek değişikliği yaz]
- Dosyalar: `lib/...` (eklendi), `pubspec.yaml` (değiştirildi)
- Supabase: değişiklik yok
- Test: `flutter analyze` → [gerçek çıktı]
- Git: [branch / kısa SHA ya da commit yok]
- Engel: [var/yok]
- Sonraki: [somut görev]
```

## Gerçek çalışma kayıtları

### 2026-11-11 09:44 (+03:00) — Bilinmiyor (macOS) — T01, T02, T03, T04 / tamamlandı & T03 engelli
- **Yapılan:**
  - `T01`: Flutter `3.47.9` / Dart `3.13.7`, Git durumu (`main @ a7fecdd`, `README.md` modified + dokümanlar untracked), `pubspec.yaml`, `AndroidManifest.xml`, `build.gradle.kts` (`com.example.roamory`) ve `Info.plist` incelendi.
  - `T02`: Stitch MCP `projects/2591164501540002750` doğrulandı; 38/38 ekran `docs/screen_inventory.md` ile birebir eşleşti (`Missing html: 0, Missing shot: 0`). `A01`, `A02`, `A03`, `B01` (+PNG), `B02`, `C01`, `D01`, `E01`, `E05`, `F01`, `F04`, `F05`, `S01`–`S04` HTML kaynakları incelendi.
  - `T03`: `supabase` CLI kurulu değil ve yerel proje bağlantı bilgisi/şema erişimi yok; canlı şema denetimi `blocked` olarak işaretlendi.
  - `T04`: Tasarım, nav, l10n ve V1 kapsam dışı öğe sapmaları `tasks.md` içinde belgelendi.
- **Dosyalar:** `tasks.md` (güncellendi), `YAPILANLAR.md` (güncellendi)
- **Supabase:** değişiklik yok (`T03` erişim bekliyor)
- **Test:** `flutter analyze` → `No issues found!`; `flutter test` → `All tests passed!` (1 varsayılan smoke test)
- **Git:** `main` (`a7fecdd`), yerel dokümanlar untracked
- **Engel:** `T03` için `supabase` CLI / güvenli proje erişimi eksik
- **Sonraki:** `T05` (`pubspec.yaml` bağımlılıkları, `--dart-define`, `go_router`, Riverpod, TR/EN ARB l10n, merkezi tema) kurulumuna başla.

### 2026-11-11 09:48 (+03:00) — Bilinmiyor (macOS) — T05, T06 / tamamlandı
- **Yapılan:**
  - `T05`: `pubspec.yaml` bağımlılıkları eklendi (`flutter_riverpod`, `go_router`, `supabase_flutter`, `flutter_map`, `latlong2`, `intl`, `google_fonts`, `cached_network_image`, `image_picker`, `shared_preferences`, `flutter_localizations`). `l10n.yaml` + TR/EN ARB yerelleştirme dosyaları üretildi. `design.md` marka tokenlarına uygun merkezi açık/koyu tema (`app_colors.dart`, `app_spacing.dart`, `app_typography.dart`, `app_theme.dart`), `--dart-define` Supabase yapılandırması (`supabase_config.dart`), 5 sabit sekmeli `go_router` kabuğu (`app_router.dart`), senkron okuma destekli `AppPreferencesNotifier` ve `RoamoryApp`/`main.dart` kuruldu. İlk çalıştırmada `AppPreferencesNotifier` içindeki `Future.microtask` yüklemesinin testte race condition oluşturduğu tespit edildi ve senkron `loadSync()` ile düzeltildi.
  - `T06`: `AppException` + `ErrorMapper`, `AppBottomNavigation`, `RoamoryScaffold`, `PrimaryButton`, `SecondaryButton`, `AppTextField`, `LoadingSkeleton`, `EmptyState`, `ErrorState`, `AppConfirmSheet`/`showAppConfirmSheet`, `AppNetworkImage` bileşenleri Türkçe DartDoc ve neden yorumlarıyla geliştirildi.
- **Dosyalar:** `pubspec.yaml`, `pubspec.lock`, `l10n.yaml`, `lib/main.dart`, `lib/app/app.dart`, `lib/app/l10n/*`, `lib/app/router/app_router.dart`, `lib/app/theme/*`, `lib/core/config/supabase_config.dart`, `lib/core/errors/*`, `lib/core/providers/app_preferences_provider.dart`, `lib/shared/widgets/*`, `test/widget_test.dart`, `test/core/error_mapper_and_config_test.dart`, `test/shared/shared_widgets_test.dart`, `tasks.md`, `DEVIR_NOTLARI.md`
- **Supabase:** değişiklik yok
- **Test:** `dart format lib test` (24 dosya), `flutter analyze` → `No issues found!`, `flutter test` → `13/13 All tests passed!`
- **Git:** `main` (`a7fecdd` üzerine uncommitted çalışma)
- **Engel:** `T03` canlı Supabase şema doğrulaması beklemede (`supabase` CLI ve erişim yok)
- **Sonraki:** `T07` (`A01`–`A07` Auth & Onboarding akışı, Google OAuth deep link `io.roamory.app://login-callback/`).

### 2026-11-11 15:51 (+03:00) — Bilinmiyor (macOS) — T07 (tamamlandı) & T08 (unit/widget geçti, canlı Supabase E2E engelli)
- **Yapılan:**
  - `T07`: Stitch MCP `projects/2591164501540002750` üzerinden `A01`–`A07` HTML/PNG tasarımları incelendi (`A03` görselindeki mock sayaçlar `project.md` gereği kodlanmadı, `A01`'deki kırık görsel yerine marka pusula rozeti kullanıldı). Feature-first Clean Architecture ile `lib/features/auth/` altında `domain` (`AuthUser`, `UserProfile`, `AuthFlowStatus`, `AuthSessionState`, `AuthRepository`, `AuthValidators`), `data` (`UserProfileModel`, `SupabaseAuthDatasource`, `SupabaseAuthRepository`), `presentation` (`AuthController`, `AuthActionController`, `LanguageTogglePill`, `AuthFeedbackBanner` ve `SplashScreen`, `OnboardingScreen`, `LoginScreen`, `RegisterScreen`, `ForgotPasswordScreen`, `EmailVerificationScreen`, `ProfileSetupScreen`) geliştirildi.
  - `lib/app/router/app_router.dart` içine `resolveAuthRedirect` eklendi; oturum durumu, `emailVerified` ve `UserProfile.isSetupComplete` kontrolleriyle profil kurulumu tamamlanmadan ana uygulamaya geçiş engellendi. `lib/app/l10n/app_tr.arb` ve `app_en.arb` Auth metinleriyle güncellenip `flutter gen-l10n` çalıştırıldı.
  - Android (`android/app/src/main/AndroidManifest.xml`) ve iOS (`ios/Runner/Info.plist`) için `io.roamory.app://login-callback/` deep link ve iOS medya izin açıklamaları eklendi.
  - `T08`: `test/features/auth/auth_unit_test.dart`, `test/features/auth/auth_screens_widget_test.dart` ve güncellenen `test/widget_test.dart` yazıldı. İlk koşuda 320px dar ekranda `SplashScreen` taşması (`Row` içindeki uzun metinler) ve `LoginScreen` widget testlerinde viewport kaydırma eksikliği yakalandı; `SplashScreen` metinleri `Flexible` içine alınarak ve testlerde `ensureVisible` eklenerek düzeltildi.
- **Dosyalar:** `lib/features/auth/**`, `lib/app/router/app_router.dart`, `lib/app/l10n/app_tr.arb`, `lib/app/l10n/app_en.arb`, `lib/app/l10n/app_localizations*.dart`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, `test/features/auth/auth_unit_test.dart`, `test/features/auth/auth_screens_widget_test.dart`, `test/widget_test.dart`, `tasks.md`, `DEVIR_NOTLARI.md`
- **Supabase:** Kod yalnızca mevcut Auth, `profiles` (`username`, `full_name`, `avatar_url`, `bio`, `preferred_language`) ve `avatars` Storage bucket (`<= 5 MB`) ile çalışacak şekilde yazıldı; şema değişikliği yapılmadı.
- **Test:** `dart format lib test` (44 dosya) → 0 hata, `flutter analyze` → `No issues found!`, `flutter test` → `23/23 All tests passed!`. Gerçek Supabase Auth/Storage entegrasyon testleri canlı kimlik bilgisi ve özel SMTP olmadığı için çalıştırılmadı.
- **Git:** `main` (`a7fecdd` üzerine uncommitted çalışma; `README.md` ve kullanıcı belgeleri korundu)
- **Engel:** `T03` şema doğrulaması ve `T08` canlı Supabase E2E/SMTP doğrulaması için canlı proje erişimi, Google OAuth platform/Dashboard yapılandırması (`com.example.roamory` / iOS GoogleService/URL scheme / Supabase redirect allowlist) ve özel SMTP kurulumu gerekiyor.
- **Sonraki:** Kullanıcı canlı kimlik/onay verirse `T03` ve `T08` canlı E2E doğrulamasını yap; aksi halde `T09` (`B01`–`B05` Keşif ve Yer Detayı) fazına geç.
