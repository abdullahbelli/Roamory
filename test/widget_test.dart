import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roamory/app/app.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
import 'package:roamory/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:roamory/features/auth/domain/entities/auth_user.dart';
import 'package:roamory/features/auth/domain/entities/user_profile.dart';
import 'package:roamory/features/auth/domain/repositories/auth_repository.dart';

/// Testlerde SharedPreferences disk erişimi olmadan çalışan sahte tercih deposu.
class _FakePreferencesStorage implements AppPreferencesStorage {
  AppPreferencesState state = const AppPreferencesState(
    locale: Locale('tr'),
    themeMode: ThemeMode.light,
    onboardingCompleted: true,
  );

  @override
  AppPreferencesState loadSync() => state;

  @override
  Future<void> saveLocaleCode(String? languageCode) async {
    state = state.copyWith(
      locale: languageCode == null ? null : Locale(languageCode),
      clearLocale: languageCode == null,
    );
  }

  @override
  Future<void> saveOnboardingCompleted(bool completed) async {
    state = state.copyWith(onboardingCompleted: completed);
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
  }
}

/// Ana kabuk testlerinde profili tamamlanmış oturumu temsil eden sahte repository.
class _AuthenticatedShellFakeAuthRepository implements AuthRepository {
  static const _user = AuthUser(
    id: 'smoke-user',
    email: 'smoke@roamory.com',
    emailVerified: true,
    fullName: 'Smoke Gezgin',
  );

  static const _profile = UserProfile(
    id: 'smoke-user',
    username: 'smoke_gezgin',
    fullName: 'Smoke Gezgin',
  );

  @override
  AuthUser? getCurrentUser() => _user;

  @override
  Stream<AuthUser?> watchAuthChanges() => const Stream<AuthUser?>.empty();

  @override
  Future<UserProfile?> fetchProfile(String userId) async => _profile;

  @override
  Future<bool> isUsernameAvailable({
    required String username,
    required String currentUserId,
  }) async => true;

  @override
  Future<AuthUser?> refreshCurrentUser() async => _user;

  @override
  Future<void> resendVerificationEmail({required String email}) async {}

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async => _user;

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser?> signUpWithEmail(SignUpRequest request) async => _user;

  @override
  Future<UserProfile> upsertProfile(ProfileUpsertRequest request) async =>
      _profile;

  @override
  Future<AuthUser> verifyEmailOtp({
    required String email,
    required String token,
  }) async => _user;
}

void main() {
  testWidgets(
    // Senaryo: Oturumu açık kullanıcıda uygulama kök kabuğu 5 sabit alt sekmeyle
    // açılmalı ve sekmeler arası geçişte hata vermemelidir.
    'RoamoryApp 5 sabit alt sekmeyi gösterir ve sekme geçişi çalışır',
    (tester) async {
      final storage = _FakePreferencesStorage();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesStorageProvider.overrideWithValue(storage),
            authRepositoryProvider.overrideWithValue(
              _AuthenticatedShellFakeAuthRepository(),
            ),
          ],
          child: const RoamoryApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ana Sayfa'), findsWidgets);
      expect(find.text('Keşfet'), findsOneWidget);
      expect(find.text('Haritam'), findsOneWidget);
      expect(find.text('Topluluk'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      await tester.tap(find.text('Keşfet'));
      await tester.pumpAndSettle();
      expect(find.text('Ülke, şehir veya mekan ara...'), findsOneWidget);
    },
  );

  testWidgets(
    // Senaryo: Dil tercihi İngilizceye çevrildiğinde sabit alt sekmeler anında
    // İngilizce metinlere dönüşmelidir.
    'Dil tercihi değiştirildiğinde alt navigasyon anında güncellenir',
    (tester) async {
      final storage = _FakePreferencesStorage();
      final container = ProviderContainer(
        overrides: [
          appPreferencesStorageProvider.overrideWithValue(storage),
          authRepositoryProvider.overrideWithValue(
            _AuthenticatedShellFakeAuthRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RoamoryApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      await container
          .read(appPreferencesProvider.notifier)
          .setLocale(const Locale('en'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('My Map'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    },
  );

  testWidgets(
    // Senaryo: 320px, 393px ve 430px ekran genişliklerinde dahi alt navigasyon
    // ve ana iskele taşma (overflow) üretmemelidir.
    '320px, 393px ve 430px genişliklerde layout taşması oluşmaz',
    (tester) async {
      final storage = _FakePreferencesStorage();

      for (final width in [320.0, 393.0, 430.0]) {
        await tester.binding.setSurfaceSize(Size(width, 852));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appPreferencesStorageProvider.overrideWithValue(storage),
              authRepositoryProvider.overrideWithValue(
                _AuthenticatedShellFakeAuthRepository(),
              ),
            ],
            child: const RoamoryApp(useGoogleFonts: false),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      }

      await tester.binding.setSurfaceSize(null);
    },
  );
}
