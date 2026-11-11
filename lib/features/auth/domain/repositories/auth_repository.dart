import 'dart:typed_data';

import 'package:roamory/features/auth/domain/entities/auth_user.dart';
import 'package:roamory/features/auth/domain/entities/user_profile.dart';

/// Kayıt isteği veri aktarım nesnesi.
class SignUpRequest {
  /// Kayıt isteği oluşturur.
  const SignUpRequest({
    required this.fullName,
    required this.email,
    required this.password,
  });

  /// Kullanıcının görünen adı.
  final String fullName;

  /// E-posta adresi.
  final String email;

  /// Parola.
  final String password;
}

/// Profil kurulum/güncelleme isteği.
class ProfileUpsertRequest {
  /// Profil güncelleme isteği oluşturur.
  const ProfileUpsertRequest({
    required this.userId,
    required this.fullName,
    required this.username,
    required this.preferredLanguage,
    this.bio,
    this.avatarBytes,
    this.avatarFileExtension,
  });

  /// Kullanıcı kimliği (`auth.uid()`).
  final String userId;

  /// Görünen ad.
  final String fullName;

  /// Benzersiz kullanıcı adı (`@` olmadan).
  final String username;

  /// Tercih edilen dil kodu (`tr` / `en`).
  final String preferredLanguage;

  /// Kısa biyografi.
  final String? bio;

  /// Seçilen profil fotoğrafının ham baytları (`<= 5 MB`).
  final Uint8List? avatarBytes;

  /// Seçilen fotoğraf uzantısı (`jpg`, `png`, `webp`).
  final String? avatarFileExtension;
}

/// Kimlik doğrulama ve profil kurulumu işlemleri için domain sözleşmesi.
///
/// Presentation katmanı yalnızca bu arayüze bağımlıdır; Supabase SDK detayları
/// `data` katmanında kapsüllenir (SOLID - Dependency Inversion).
abstract interface class AuthRepository {
  /// Mevcut oturum açmış kullanıcıyı döndürür; yoksa `null`.
  AuthUser? getCurrentUser();

  /// Oturum değişikliklerini reaktif stream olarak yayınlar.
  Stream<AuthUser?> watchAuthChanges();

  /// E-posta ve parola ile giriş yapar.
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// E-posta ve parola ile yeni kullanıcı kaydı başlatır.
  ///
  /// E-posta onayı gerekiyorsa kullanıcı doğrulama bekleyen durumda dönebilir.
  Future<AuthUser?> signUpWithEmail(SignUpRequest request);

  /// Google OAuth akışını harici tarayıcı / deep-link üzerinden başlatır.
  Future<void> signInWithGoogle();

  /// Doğrulama e-postasını yeniden gönderir.
  Future<void> resendVerificationEmail({required String email});

  /// 6 haneli doğrulama kodunu (OTP) kontrol ederek oturumu etkinleştirir.
  Future<AuthUser> verifyEmailOtp({
    required String email,
    required String token,
  });

  /// Güncel oturumu sunucudan yenileyerek e-posta doğrulamasını kontrol eder.
  Future<AuthUser?> refreshCurrentUser();

  /// Şifre sıfırlama e-postası gönderir.
  Future<void> sendPasswordResetEmail({required String email});

  /// Belirtilen kullanıcının `profiles` kaydını getirir; yoksa `null`.
  Future<UserProfile?> fetchProfile(String userId);

  /// Kullanıcı adının başka bir hesap tarafından kullanılıp kullanılmadığını denetler.
  Future<bool> isUsernameAvailable({
    required String username,
    required String currentUserId,
  });

  /// Profil bilgilerini (ve varsa avatar görselini) güvenli şekilde kaydeder.
  Future<UserProfile> upsertProfile(ProfileUpsertRequest request);

  /// Mevcut oturumu kapatır.
  Future<void> signOut();
}
