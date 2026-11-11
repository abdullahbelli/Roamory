import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
import 'package:roamory/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:roamory/features/auth/domain/entities/auth_status.dart';
import 'package:roamory/features/auth/domain/entities/auth_user.dart';
import 'package:roamory/features/auth/domain/entities/user_profile.dart';
import 'package:roamory/features/auth/domain/repositories/auth_repository.dart';
import 'package:roamory/features/auth/domain/usecases/auth_validators.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';

class _InMemoryPrefs implements AppPreferencesStorage {
  AppPreferencesState state = const AppPreferencesState(
    locale: Locale('tr'),
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

/// Birim testleri için kontrol edilebilir sahte [AuthRepository] uygulaması.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.shouldFailSignIn = false});

  AuthUser? initialUser;
  UserProfile? storedProfile;
  bool shouldFailSignIn;
  bool usernameAvailable = true;
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? getCurrentUser() => initialUser;

  @override
  Stream<AuthUser?> watchAuthChanges() => _controller.stream;

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (shouldFailSignIn) {
      throw const UnauthorizedAppException(code: 'invalid_credentials');
    }
    final user = AuthUser(
      id: 'user-1',
      email: email,
      emailVerified: true,
      fullName: storedProfile?.fullName ?? 'Deniz Aksoy',
    );
    initialUser = user;
    return user;
  }

  @override
  Future<AuthUser?> signUpWithEmail(SignUpRequest request) async {
    // Supabase e-posta doğrulama açık senaryosunu simüle etmek için null döner.
    return null;
  }

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
    initialUser = user;
    return user;
  }

  @override
  Future<AuthUser?> refreshCurrentUser() async => initialUser;

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<UserProfile?> fetchProfile(String userId) async => storedProfile;

  @override
  Future<bool> isUsernameAvailable({
    required String username,
    required String currentUserId,
  }) async => usernameAvailable;

  @override
  Future<UserProfile> upsertProfile(ProfileUpsertRequest request) async {
    final saved = UserProfile(
      id: request.userId,
      username: request.username,
      fullName: request.fullName,
      bio: request.bio,
      preferredLanguage: request.preferredLanguage,
    );
    storedProfile = saved;
    return saved;
  }

  @override
  Future<void> signOut() async {
    initialUser = null;
    _controller.add(null);
  }
}

void main() {
  group('AuthValidators', () {
    test(
      // Amaç: E-posta, güçlü parola, kullanıcı adı ve 6 haneli OTP doğrulamaları tutarlı çalışmalı.
      'geçerli ve geçersiz giriş değerlerini doğru ayırt eder',
      () {
        expect(AuthValidators.isValidEmail('deniz@roamory.com'), isTrue);
        expect(AuthValidators.isValidEmail('hatali-mail'), isFalse);

        expect(AuthValidators.isValidPassword('Roamory1'), isTrue);
        expect(AuthValidators.isValidPassword('kisa1'), isFalse);
        expect(AuthValidators.isValidPassword('sadeceharf'), isFalse);
        expect(AuthValidators.isValidPassword('12345678'), isFalse);

        expect(AuthValidators.normalizeUsername(' @Deniz_01 '), 'deniz_01');
        expect(AuthValidators.isValidUsername('@deniz_01'), isTrue);
        expect(AuthValidators.isValidUsername('ab'), isFalse);

        expect(AuthValidators.isValidOtpCode('123456'), isTrue);
        expect(AuthValidators.isValidOtpCode('12ab56'), isFalse);
      },
    );
  });

  group('resolveAuthRedirect', () {
    test(
      // Amaç: Oturum ve profil kurulumu durumuna göre go_router yalnızca izinli rotaya geçirmeli.
      'tüm auth akış durumlarında doğru yönlendirme rotasını döner',
      () {
        expect(
          resolveAuthRedirect(
            currentLocation: AppRoutes.home,
            authState: const AuthSessionState.initializing(),
            onboardingCompleted: false,
          ),
          AppRoutes.splash,
        );

        expect(
          resolveAuthRedirect(
            currentLocation: AppRoutes.home,
            authState: const AuthSessionState.unauthenticated(),
            onboardingCompleted: false,
          ),
          AppRoutes.onboarding,
        );

        expect(
          resolveAuthRedirect(
            currentLocation: AppRoutes.home,
            authState: const AuthSessionState.unauthenticated(),
            onboardingCompleted: true,
          ),
          AppRoutes.login,
        );

        expect(
          resolveAuthRedirect(
            currentLocation: AppRoutes.register,
            authState: const AuthSessionState.unauthenticated(),
            onboardingCompleted: true,
          ),
          isNull,
        );

        expect(
          resolveAuthRedirect(
            currentLocation: AppRoutes.home,
            authState: const AuthSessionState(
              status: AuthFlowStatus.needsEmailVerification,
              pendingVerificationEmail: 'test@roamory.com',
            ),
            onboardingCompleted: true,
          ),
          AppRoutes.emailVerification,
        );

        // Profil kurulumu eksik kullanıcı ana sayfa yerine A07'ye kilitlenmelidir.
        expect(
          resolveAuthRedirect(
            currentLocation: AppRoutes.home,
            authState: const AuthSessionState(
              status: AuthFlowStatus.needsProfileSetup,
            ),
            onboardingCompleted: true,
          ),
          AppRoutes.profileSetup,
        );

        expect(
          resolveAuthRedirect(
            currentLocation: AppRoutes.login,
            authState: const AuthSessionState(
              status: AuthFlowStatus.authenticated,
            ),
            onboardingCompleted: true,
          ),
          AppRoutes.home,
        );
      },
    );
  });

  group('AuthController & AuthActionController', () {
    test(
      // Amaç: Başarısız girişte hata state üretilmeli, profil eksikse needsProfileSetup,
      // profil tamamlandığında authenticated durumuna geçilmelidir.
      'giriş, hata yönetimi, profil kurulumu ve çıkış durumlarını doğru yönetir',
      () async {
        final fakeRepo = _FakeAuthRepository(shouldFailSignIn: true);
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
            appPreferencesStorageProvider.overrideWithValue(_InMemoryPrefs()),
          ],
        );
        addTearDown(container.dispose);

        // 1) Hatalı giriş senaryosu.
        final failed = await container
            .read(authActionProvider.notifier)
            .signInWithEmail(
              email: 'deniz@roamory.com',
              password: 'WrongPassword1',
            );
        expect(failed, isFalse);
        expect(
          container.read(authActionProvider).error,
          isA<UnauthorizedAppException>(),
        );

        // 2) Başarılı giriş fakat profil eksik -> needsProfileSetup.
        fakeRepo.shouldFailSignIn = false;
        fakeRepo.usernameAvailable = false;
        final succeeded = await container
            .read(authActionProvider.notifier)
            .signInWithEmail(email: 'deniz@roamory.com', password: 'Roamory1');
        expect(succeeded, isTrue);
        expect(
          container.read(authControllerProvider).status,
          AuthFlowStatus.needsProfileSetup,
        );
        expect(
          await container
              .read(authControllerProvider.notifier)
              .isUsernameAvailable('deniz_aksoy'),
          isFalse,
        );

        // 3) Profil kurulumu tamamlandığında -> authenticated ve dil güncellenmeli.
        final saved = await container
            .read(authActionProvider.notifier)
            .completeProfileSetup(
              const ProfileUpsertRequest(
                userId: 'user-1',
                fullName: 'Deniz Aksoy',
                username: 'deniz_aksoy',
                preferredLanguage: 'en',
              ),
            );
        expect(saved, isTrue);
        expect(
          container.read(authControllerProvider).status,
          AuthFlowStatus.authenticated,
        );
        expect(
          container.read(appPreferencesProvider).locale,
          const Locale('en'),
        );

        // 4) Çıkış yapıldığında -> unauthenticated.
        await container.read(authActionProvider.notifier).signOut();
        expect(
          container.read(authControllerProvider).status,
          AuthFlowStatus.unauthenticated,
        );
      },
    );

    test(
      // Amaç: Kayıt sonrası e-posta doğrulama beklenmeli, OTP girilince profil kurulumuna geçilmeli.
      'kayıt sonrası e-posta doğrulama ve OTP akışı doğru çalışır',
      () async {
        final fakeRepo = _FakeAuthRepository();
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
            appPreferencesStorageProvider.overrideWithValue(_InMemoryPrefs()),
          ],
        );
        addTearDown(container.dispose);

        final status = await container
            .read(authActionProvider.notifier)
            .signUpWithEmail(
              const SignUpRequest(
                fullName: 'Deniz Aksoy',
                email: 'deniz@roamory.com',
                password: 'Roamory1',
              ),
            );
        expect(status, AuthFlowStatus.needsEmailVerification);
        expect(
          container.read(authControllerProvider).pendingVerificationEmail,
          'deniz@roamory.com',
        );

        final verified = await container
            .read(authActionProvider.notifier)
            .verifyEmailOtp(email: 'deniz@roamory.com', token: '842109');
        expect(verified, isTrue);
        expect(
          container.read(authControllerProvider).status,
          AuthFlowStatus.needsProfileSetup,
        );
      },
    );
  });
}
