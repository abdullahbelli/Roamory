import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
import 'package:roamory/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:roamory/features/auth/domain/entities/auth_status.dart';
import 'package:roamory/features/auth/domain/entities/auth_user.dart';
import 'package:roamory/features/auth/domain/entities/user_profile.dart';
import 'package:roamory/features/auth/domain/repositories/auth_repository.dart';

/// Kimlik doğrulama formlarındaki anlık işlem sonucunu sınıflandırır.
enum AuthActionSuccess {
  /// E-posta/şifre ile giriş başarılı.
  signedIn,

  /// E-posta doğrulama kodu/bağlantısı gönderildi.
  verificationPending,

  /// Doğrulama e-postası yeniden gönderildi.
  verificationResent,

  /// Şifre sıfırlama bağlantısı gönderildi.
  passwordResetSent,

  /// Profil kurulumu tamamlandı.
  profileCompleted,

  /// Oturum kapatıldı.
  signedOut,
}

/// Auth ekranlarındaki yüklenme, hata ve başarı geri bildirim durumunu tutar.
@immutable
class AuthActionState {
  /// Yeni bir [AuthActionState] oluşturur.
  const AuthActionState({
    this.isLoading = false,
    this.error,
    this.success,
    this.infoMessage,
  });

  /// Devam eden ağ veya auth işlemi olup olmadığı.
  final bool isLoading;

  /// Son işlemde oluşan güvenli domain hatası.
  final AppException? error;

  /// Başarılı işlem türü.
  final AuthActionSuccess? success;

  /// Hata dışındaki bilgilendirme kodu (ör. doğrulama henüz onaylanmadı).
  final String? infoMessage;

  /// Yüklenme durumuna geçerken önceki hata ve mesajları temizler.
  AuthActionState loading() => const AuthActionState(isLoading: true);

  /// Hata durumuna geçer.
  AuthActionState failed(AppException error) => AuthActionState(error: error);

  /// Başarı durumuna geçer.
  AuthActionState succeeded(AuthActionSuccess success) =>
      AuthActionState(success: success);
}

/// Oturum, e-posta doğrulaması ve profil kurulumu yaşam döngüsünü yönetir.
///
/// `go_router` yönlendirmesi doğrudan bu controller'ın ürettiği
/// [AuthSessionState] üzerinden karar verir; böylece profil kurulumu bitmeden
/// ana uygulamaya geçiş engellenir.
class AuthController extends Notifier<AuthSessionState> {
  StreamSubscription<AuthUser?>? _authSubscription;
  bool _manualMutationActive = false;

  /// Kayıt veya doğrulanmamış giriş sonrasında A06 ekranında "Doğrulamayı Kontrol Et"
  /// butonuna basıldığında oturum açabilmek için yalnızca bellekte tutulan geçici parola.
  /// Güvenlik kuralı gereği diske veya loglara asla yazılmaz; doğrulama tamamlandığında silinir.
  String? _pendingVerificationPassword;

  @override
  AuthSessionState build() {
    final repository = ref.watch(authRepositoryProvider);

    // Önceki abonelik varsa temizleyip yeni oturum akışına bağlanıyoruz.
    _authSubscription?.cancel();
    _authSubscription = repository.watchAuthChanges().listen((user) async {
      // Manuel işlem devam ederken ara stream olaylarının state'i bozmasını önleriz.
      if (_manualMutationActive) {
        return;
      }
      await _syncUserState(user);
    });
    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    // Açılışta mevcut oturum kontrolünü mikro-görevle başlatıyoruz (A01 Splash).
    Future.microtask(resolveInitialSession);
    return const AuthSessionState.initializing();
  }

  /// Açılışta mevcut oturumu ve profil kurulumu durumunu çözer.
  Future<void> resolveInitialSession() async {
    if (_manualMutationActive) {
      return;
    }
    final repository = ref.read(authRepositoryProvider);
    final currentUser = repository.getCurrentUser();
    final resolved = await _buildStateForUser(currentUser);

    // Eğer kullanıcı bu arada manuel bir auth işlemi başlattıysa üzerine yazmayız.
    if (state.status == AuthFlowStatus.initializing && !_manualMutationActive) {
      state = resolved;
    }
  }

  /// E-posta ve şifreyle giriş yapar ve profil durumuna göre akışı günceller.
  ///
  /// Eğer hesap oluşturulmuş ancak e-posta doğrulaması henüz tamamlanmamışsa
  /// (`email_not_confirmed`), kullanıcıyı doğrudan `A06` doğrulama ekranına yönlendirir.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _manualMutationActive = true;
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signInWithEmail(
        email: email,
        password: password,
      );
      _pendingVerificationPassword = null;
      state = await _buildStateForUser(user);
    } catch (error) {
      if (error is ValidationAppException &&
          error.code == 'email_not_confirmed') {
        _pendingVerificationPassword = password;
        state = AuthSessionState(
          status: AuthFlowStatus.needsEmailVerification,
          pendingVerificationEmail: email.trim(),
        );
      }
      rethrow;
    } finally {
      _manualMutationActive = false;
    }
  }

  /// Yeni e-posta kaydı başlatır; doğrulama gerekiyorsa A06 durumuna geçirir.
  Future<AuthFlowStatus> signUpWithEmail(SignUpRequest request) async {
    _manualMutationActive = true;
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signUpWithEmail(request);
      if (user == null) {
        _pendingVerificationPassword = request.password;
        state = AuthSessionState(
          status: AuthFlowStatus.needsEmailVerification,
          pendingVerificationEmail: request.email.trim(),
        );
        return AuthFlowStatus.needsEmailVerification;
      }
      _pendingVerificationPassword = null;
      final resolved = await _buildStateForUser(user);
      state = resolved;
      return resolved.status;
    } finally {
      _manualMutationActive = false;
    }
  }

  /// Google OAuth akışını başlatır.
  Future<void> signInWithGoogle() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.signInWithGoogle();
  }

  /// Bekleyen e-posta adresine doğrulama bağlantısını/kodunu yeniden gönderir.
  Future<void> resendVerificationEmail(String email) async {
    final repository = ref.read(authRepositoryProvider);
    await repository.resendVerificationEmail(email: email);
  }

  /// 6-8 haneli doğrulama kodunu kontrol eder ve oturumu sonraki adıma taşır.
  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    _manualMutationActive = true;
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.verifyEmailOtp(email: email, token: token);
      _pendingVerificationPassword = null;
      state = await _buildStateForUser(user);
    } finally {
      _manualMutationActive = false;
    }
  }

  /// Kullanıcının e-posta bağlantısına tıklayıp tıklamadığını sunucudan kontrol eder.
  ///
  /// Supabase `mailer_autoconfirm = false` iken kayıt sonrası yerel oturum (`session`)
  /// açılmadığından, kullanıcı e-postasındaki doğrulama bağlantısını tarayıcıda onaylayıp
  /// A06 ekranında "Doğrulamayı Kontrol Et" butonuna bastığında bellekteki geçici
  /// kayıt bilgileriyle oturum açmayı dener; doğrulandıysa otomatik olarak `A07`
  /// profil kurulum adımına geçirir.
  Future<bool> refreshVerificationStatus() async {
    _manualMutationActive = true;
    try {
      final repository = ref.read(authRepositoryProvider);
      var user = await repository.refreshCurrentUser();

      if ((user == null || !user.emailVerified) &&
          state.pendingVerificationEmail != null &&
          _pendingVerificationPassword != null) {
        try {
          user = await repository.signInWithEmail(
            email: state.pendingVerificationEmail!,
            password: _pendingVerificationPassword!,
          );
        } on AppException catch (e) {
          if (e.code == 'email_not_confirmed') {
            return false;
          }
          rethrow;
        }
      }

      if (user == null || !user.emailVerified) {
        return false;
      }
      _pendingVerificationPassword = null;
      state = await _buildStateForUser(user);
      return true;
    } finally {
      _manualMutationActive = false;
    }
  }

  /// Şifre sıfırlama e-postası gönderir.
  Future<void> sendPasswordResetEmail(String email) async {
    final repository = ref.read(authRepositoryProvider);
    await repository.sendPasswordResetEmail(email: email);
  }

  /// Seçilen kullanıcı adının uygun olup olmadığını veritabanından sorgular.
  Future<bool> isUsernameAvailable(String username) async {
    final userId = state.user?.id;
    if (userId == null) {
      return false;
    }
    return ref
        .read(authRepositoryProvider)
        .isUsernameAvailable(username: username, currentUserId: userId);
  }

  /// Profil kurulumunu kaydeder ve ana uygulamaya geçiş kilidini açar.
  Future<UserProfile> completeProfileSetup(ProfileUpsertRequest request) async {
    _manualMutationActive = true;
    try {
      final repository = ref.read(authRepositoryProvider);
      final savedProfile = await repository.upsertProfile(request);

      // Profildeki dil tercihini yerel uygulama tercihine de yansıtıyoruz.
      await ref
          .read(appPreferencesProvider.notifier)
          .setLocale(Locale(savedProfile.preferredLanguage));

      final user = state.user ?? repository.getCurrentUser();
      state = AuthSessionState(
        status: savedProfile.isSetupComplete
            ? AuthFlowStatus.authenticated
            : AuthFlowStatus.needsProfileSetup,
        user: user,
        profile: savedProfile,
      );
      return savedProfile;
    } finally {
      _manualMutationActive = false;
    }
  }

  /// Profil düzenleme (`F02`) sonrasında oturumdaki profil bilgisini günceller.
  void updateCurrentProfile(UserProfile updatedProfile) {
    final user = state.user;
    if (user == null) {
      return;
    }
    state = AuthSessionState(
      status: updatedProfile.isSetupComplete
          ? AuthFlowStatus.authenticated
          : AuthFlowStatus.needsProfileSetup,
      user: user,
      profile: updatedProfile,
    );
  }

  /// Mevcut kullanıcı oturumunu kapatır ve giriş akışına döndürür.
  Future<void> signOut() async {
    _manualMutationActive = true;
    try {
      _pendingVerificationPassword = null;
      await ref.read(authRepositoryProvider).signOut();
      state = const AuthSessionState.unauthenticated();
    } finally {
      _manualMutationActive = false;
    }
  }

  /// E-posta doğrulama ekranında adres değiştirmek için oturumsuz duruma döner.
  void resetPendingVerification() {
    _pendingVerificationPassword = null;
    state = const AuthSessionState.unauthenticated();
  }

  Future<void> _syncUserState(AuthUser? user) async {
    // Kayıt sonrası doğrulama beklenirken stream'in null oturumu A06'yı ezmemelidir.
    if (user == null && state.status == AuthFlowStatus.needsEmailVerification) {
      return;
    }
    state = await _buildStateForUser(user);
  }

  Future<AuthSessionState> _buildStateForUser(AuthUser? user) async {
    if (user == null) {
      return const AuthSessionState.unauthenticated();
    }
    if (!user.emailVerified) {
      return AuthSessionState(
        status: AuthFlowStatus.needsEmailVerification,
        user: user,
        pendingVerificationEmail: user.email,
      );
    }

    try {
      final profile = await ref
          .read(authRepositoryProvider)
          .fetchProfile(user.id);
      if (profile == null || !profile.isSetupComplete) {
        return AuthSessionState(
          status: AuthFlowStatus.needsProfileSetup,
          user: user,
          profile: profile,
        );
      }
      return AuthSessionState(
        status: AuthFlowStatus.authenticated,
        user: user,
        profile: profile,
      );
    } catch (_) {
      // Profil okunamazsa güvenli varsayılan olarak profil kurulum adımında tutarız.
      return AuthSessionState(
        status: AuthFlowStatus.needsProfileSetup,
        user: user,
      );
    }
  }
}

/// Auth form aksiyonlarını (loading/error/success) yöneten Riverpod Notifier.
class AuthActionController extends Notifier<AuthActionState> {
  @override
  AuthActionState build() => const AuthActionState();

  /// Önceki hata ve bildirim durumlarını temizler.
  void clearFeedback() {
    state = const AuthActionState();
  }

  /// E-posta ve parola ile giriş işlemini yürütür.
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.loading();
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signInWithEmail(email: email, password: password);
      state = state.succeeded(AuthActionSuccess.signedIn);
      return true;
    } catch (error, stackTrace) {
      state = state.failed(ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// E-posta ve parola ile yeni hesap kaydı başlatır.
  Future<AuthFlowStatus?> signUpWithEmail(SignUpRequest request) async {
    state = state.loading();
    try {
      final status = await ref
          .read(authControllerProvider.notifier)
          .signUpWithEmail(request);
      state = state.succeeded(
        status == AuthFlowStatus.needsEmailVerification
            ? AuthActionSuccess.verificationPending
            : AuthActionSuccess.signedIn,
      );
      return status;
    } catch (error, stackTrace) {
      state = state.failed(ErrorMapper.map(error, stackTrace));
      return null;
    }
  }

  /// Google OAuth akışını tetikler.
  Future<bool> signInWithGoogle() async {
    state = state.loading();
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
      state = const AuthActionState();
      return true;
    } catch (error, stackTrace) {
      state = state.failed(ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// Şifre sıfırlama bağlantısı gönderir.
  Future<bool> sendPasswordResetEmail(String email) async {
    state = state.loading();
    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordResetEmail(email);
      state = state.succeeded(AuthActionSuccess.passwordResetSent);
      return true;
    } catch (error, stackTrace) {
      state = state.failed(ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// Doğrulama e-postasını tekrar yollar.
  Future<bool> resendVerificationEmail(String email) async {
    state = state.loading();
    try {
      await ref
          .read(authControllerProvider.notifier)
          .resendVerificationEmail(email);
      state = state.succeeded(AuthActionSuccess.verificationResent);
      return true;
    } catch (error, stackTrace) {
      state = state.failed(ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// 6 haneli doğrulama kodunu onaylar.
  Future<bool> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    state = state.loading();
    try {
      await ref
          .read(authControllerProvider.notifier)
          .verifyEmailOtp(email: email, token: token);
      state = state.succeeded(AuthActionSuccess.signedIn);
      return true;
    } catch (error, stackTrace) {
      state = state.failed(ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// Kullanıcının bağlantıya tıklayıp tıklamadığını yenileyerek denetler.
  Future<bool> checkEmailVerification() async {
    state = state.loading();
    try {
      final verified = await ref
          .read(authControllerProvider.notifier)
          .refreshVerificationStatus();
      if (!verified) {
        state = const AuthActionState(infoMessage: 'not_verified_yet');
        return false;
      }
      state = state.succeeded(AuthActionSuccess.signedIn);
      return true;
    } catch (error, stackTrace) {
      state = state.failed(ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// Profil kurulumunu kaydeder.
  Future<bool> completeProfileSetup(ProfileUpsertRequest request) async {
    state = state.loading();
    try {
      await ref
          .read(authControllerProvider.notifier)
          .completeProfileSetup(request);
      state = state.succeeded(AuthActionSuccess.profileCompleted);
      return true;
    } catch (error, stackTrace) {
      state = state.failed(ErrorMapper.map(error, stackTrace));
      return false;
    }
  }

  /// Oturumu kapatır.
  Future<bool> signOut() async {
    state = state.loading();
    try {
      await ref.read(authControllerProvider.notifier).signOut();
      state = state.succeeded(AuthActionSuccess.signedOut);
      return true;
    } catch (error, stackTrace) {
      state = state.failed(ErrorMapper.map(error, stackTrace));
      return false;
    }
  }
}

/// Aktif oturum durumunu sağlayan ana Riverpod sağlayıcısı.
final authControllerProvider =
    NotifierProvider<AuthController, AuthSessionState>(AuthController.new);

/// Auth ekranlarındaki form işlem durumunu (loading/error/success) sağlar.
final authActionProvider =
    NotifierProvider<AuthActionController, AuthActionState>(
      AuthActionController.new,
    );
