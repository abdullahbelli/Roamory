import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roamory/app/app.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
import 'package:roamory/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:roamory/features/auth/domain/entities/auth_user.dart';
import 'package:roamory/features/auth/domain/entities/user_profile.dart';
import 'package:roamory/features/auth/domain/repositories/auth_repository.dart';
import 'package:roamory/shared/widgets/app_bottom_navigation.dart';

class _TestPreferencesStorage implements AppPreferencesStorage {
  _TestPreferencesStorage({this.onboardingCompleted = true});

  bool onboardingCompleted;
  Locale? locale = const Locale('tr');
  ThemeMode themeMode = ThemeMode.light;

  @override
  AppPreferencesState loadSync() => AppPreferencesState(
    locale: locale,
    themeMode: themeMode,
    onboardingCompleted: onboardingCompleted,
  );

  @override
  Future<void> saveLocaleCode(String? languageCode) async {
    locale = languageCode == null ? null : Locale(languageCode);
  }

  @override
  Future<void> saveOnboardingCompleted(bool completed) async {
    onboardingCompleted = completed;
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    themeMode = mode;
  }
}

class _WidgetFakeAuthRepository implements AuthRepository {
  _WidgetFakeAuthRepository({
    this.currentUser,
    this.profile,
    this.signInCompleter,
    this.failSignIn = false,
  });

  AuthUser? currentUser;
  UserProfile? profile;
  Completer<AuthUser>? signInCompleter;
  bool failSignIn;
  final _controller = StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? getCurrentUser() => currentUser;

  @override
  Stream<AuthUser?> watchAuthChanges() => _controller.stream;

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (signInCompleter != null) {
      final user = await signInCompleter!.future;
      currentUser = user;
      return user;
    }
    if (failSignIn) {
      throw const UnauthorizedAppException(code: 'invalid_login');
    }
    final user = AuthUser(
      id: 'user-1',
      email: email,
      emailVerified: true,
      fullName: 'Deniz Aksoy',
    );
    currentUser = user;
    return user;
  }

  @override
  Future<AuthUser?> signUpWithEmail(SignUpRequest request) async => null;

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> resendVerificationEmail({required String email}) async {}

  @override
  Future<AuthUser> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final user = AuthUser(id: 'user-1', email: email, emailVerified: true);
    currentUser = user;
    return user;
  }

  @override
  Future<AuthUser?> refreshCurrentUser() async => currentUser;

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<UserProfile?> fetchProfile(String userId) async => profile;

  @override
  Future<bool> isUsernameAvailable({
    required String username,
    required String currentUserId,
  }) async => true;

  @override
  Future<UserProfile> upsertProfile(ProfileUpsertRequest request) async {
    final saved = UserProfile(
      id: request.userId,
      username: request.username,
      fullName: request.fullName,
      bio: request.bio,
      preferredLanguage: request.preferredLanguage,
    );
    profile = saved;
    return saved;
  }

  @override
  Future<void> signOut() async {
    currentUser = null;
    _controller.add(null);
  }
}

void main() {
  testWidgets(
    // Amaç: İlk açılışta onboarding (A02) gösterilmeli; Atla basılınca giriş ekranına geçilmeli.
    'İlk açılışta Onboarding gösterilir ve Atla ile Giriş ekranına geçilir',
    (tester) async {
      final prefs = _TestPreferencesStorage(onboardingCompleted: false);
      final repo = _WidgetFakeAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesStorageProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(repo),
          ],
          child: const RoamoryApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dünyayı Kendi Ritminle Keşfet'), findsOneWidget);

      await tester.tap(find.text('Atla'));
      await tester.pumpAndSettle();

      expect(find.text('Tekrar Hoş Geldin'), findsOneWidget);
      expect(prefs.onboardingCompleted, isTrue);
    },
  );

  testWidgets(
    // Amaç: Login ekranında form doğrulaması, şifre görünürlüğü, loading ve hatalı/başarılı giriş akışı test edilir.
    'LoginScreen form doğrulama, şifre görünürlüğü, loading ve hata durumlarını gösterir',
    (tester) async {
      final prefs = _TestPreferencesStorage(onboardingCompleted: true);
      final completer = Completer<AuthUser>();
      final repo = _WidgetFakeAuthRepository(
        signInCompleter: completer,
        profile: const UserProfile(
          id: 'user-1',
          username: 'deniz_aksoy',
          fullName: 'Deniz Aksoy',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesStorageProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(repo),
          ],
          child: const RoamoryApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      // 1) Geçersiz e-posta ve boş şifrede doğrulama uyarıları görünmelidir.
      await tester.enterText(find.byType(TextFormField).first, 'gecersiz');
      // Varsayılan test yüksekliğinde (600px) alt butonun görünür alana kaydırılmasını sağlıyoruz.
      await tester.ensureVisible(find.text('Giriş Yap'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Giriş Yap'));
      await tester.pumpAndSettle();
      expect(find.text('Geçerli bir e-posta adresi girin.'), findsOneWidget);

      // 2) Şifre görünürlüğü ikonu obscureText değerini değiştirmelidir.
      final passwordEditableBefore = tester.widget<EditableText>(
        find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.byType(EditableText),
        ),
      );
      expect(passwordEditableBefore.obscureText, isTrue);

      final toggleFinder = find.byKey(
        const Key('login_password_visibility_toggle'),
      );
      await tester.ensureVisible(toggleFinder);
      await tester.pumpAndSettle();
      await tester.tap(toggleFinder);
      await tester.pump();

      final passwordEditableAfter = tester.widget<EditableText>(
        find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.byType(EditableText),
        ),
      );
      expect(passwordEditableAfter.obscureText, isFalse);

      // 3) Geçerli bilgilerle gönderimde loading göstergesi açılmalıdır.
      await tester.enterText(
        find.byType(TextFormField).first,
        'deniz@roamory.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Roamory1');
      await tester.ensureVisible(find.text('Giriş Yap'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Giriş Yap'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 4) İstek tamamlandığında profili tam kullanıcı ana kabuğa geçmelidir.
      completer.complete(
        const AuthUser(
          id: 'user-1',
          email: 'deniz@roamory.com',
          emailVerified: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomNavigation), findsOneWidget);
    },
  );

  testWidgets(
    // Amaç: Başarısız giriş denemesinde kullanıcıya hata banner'ı gösterilmelidir.
    'LoginScreen hatalı kimlik bilgisinde hata bannerı gösterir',
    (tester) async {
      final prefs = _TestPreferencesStorage(onboardingCompleted: true);
      final repo = _WidgetFakeAuthRepository(failSignIn: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesStorageProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(repo),
          ],
          child: const RoamoryApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'deniz@roamory.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Yanlis123');
      await tester.ensureVisible(find.text('Giriş Yap'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Giriş Yap'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Bu işlem için oturum açmanız veya yetkiniz olması gerekiyor.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    // Amaç: Profili eksik kullanıcı girişte A07'de tutulmalı; profili tamamlayınca ana uygulamaya geçmelidir.
    'Profil kurulumu tamamlanmadan ana uygulamaya geçilmez; kurulum bitince geçilir',
    (tester) async {
      final prefs = _TestPreferencesStorage(onboardingCompleted: true);
      final repo = _WidgetFakeAuthRepository(
        currentUser: const AuthUser(
          id: 'user-1',
          email: 'deniz@roamory.com',
          emailVerified: true,
        ),
        profile: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesStorageProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(repo),
          ],
          child: const RoamoryApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      // Kullanıcı A07 ekranında tutulmalı, alt navigasyon görünmemelidir.
      expect(find.text('Gezgin Kimliğini Oluştur'), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);

      // "Şimdilik Atla" ana uygulamaya geçirmemeli, uyarı göstermelidir.
      await tester.tap(find.text('Şimdilik Atla'));
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomNavigation), findsNothing);

      // Zorunlu ad soyad ve kullanıcı adı girilip kaydedildiğinde ana kabuğa geçilir.
      await tester.enterText(find.byType(TextFormField).at(0), 'Deniz Aksoy');
      await tester.enterText(find.byType(TextFormField).at(1), 'deniz_aksoy');
      await tester.ensureVisible(find.text("Roamory'yi Keşfet"));
      await tester.tap(find.text("Roamory'yi Keşfet"));
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomNavigation), findsOneWidget);
    },
  );

  testWidgets(
    // Amaç: Kayıt ekranında zayıf parola ve koşul onayı olmadan kayıt engellenmeli,
    // geçerli kayıt sonrasında A06 e-posta doğrulama ekranına gidilmelidir.
    'RegisterScreen doğrulamaları uygular ve kayıt sonrası A06 ekranına geçer',
    (tester) async {
      final prefs = _TestPreferencesStorage(onboardingCompleted: true);
      final repo = _WidgetFakeAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesStorageProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(repo),
          ],
          child: const RoamoryApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      // Kayıt Ol sayfasına git.
      await tester.ensureVisible(find.text('Kayıt Ol'));
      await tester.tap(find.text('Kayıt Ol'));
      await tester.pumpAndSettle();
      expect(find.text('Aramıza Katıl'), findsOneWidget);

      // Alanları doldur ve koşulları işaretlemeden gönder.
      await tester.enterText(find.byType(TextFormField).at(0), 'Deniz Aksoy');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'deniz@roamory.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'Roamory1');
      await tester.enterText(find.byType(TextFormField).at(3), 'Roamory1');

      await tester.ensureVisible(find.text('Kayıt Ol'));
      await tester.tap(find.text('Kayıt Ol'));
      await tester.pumpAndSettle();
      expect(
        find.text('Devam etmek için kullanım koşullarını onaylamalısınız.'),
        findsOneWidget,
      );

      // Koşulları onayla ve kayıt ol -> A06 ekranı gelmelidir.
      await tester.ensureVisible(
        find.byKey(const Key('register_terms_checkbox')),
      );
      await tester.tap(find.byKey(const Key('register_terms_checkbox')));
      await tester.ensureVisible(find.text('Kayıt Ol'));
      await tester.tap(find.text('Kayıt Ol'));
      await tester.pumpAndSettle();

      expect(find.text('E-postanı Doğrula'), findsOneWidget);
    },
  );

  testWidgets(
    // Amaç: Şifremi Unuttum ekranında geçerli e-posta ile gönderimde onay banner'ı görünmelidir.
    'ForgotPasswordScreen sıfırlama bağlantısı gönderildiğinde onay bannerı gösterir',
    (tester) async {
      final prefs = _TestPreferencesStorage(onboardingCompleted: true);
      final repo = _WidgetFakeAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesStorageProvider.overrideWithValue(prefs),
            authRepositoryProvider.overrideWithValue(repo),
          ],
          child: const RoamoryApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Şifremi Unuttum?'));
      await tester.pumpAndSettle();
      expect(find.text('Şifreni mi Unuttun?'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).first,
        'selim@roamory.com',
      );
      await tester.tap(find.text('Şifre Sıfırlama Bağlantısı Gönder'));
      await tester.pumpAndSettle();

      expect(find.text('Sıfırlama bağlantısı gönderildi!'), findsOneWidget);
    },
  );
}
