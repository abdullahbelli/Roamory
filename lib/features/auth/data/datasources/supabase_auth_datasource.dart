import 'dart:typed_data';

import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/features/auth/data/models/user_profile_model.dart';
import 'package:roamory/features/auth/domain/entities/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Supabase Auth, `profiles` tablosu ve `avatars` Storage işlemlerini yürütür.
///
/// Tüm teknik Supabase SDK çağrıları yalnızca bu sınıfta toplanır; böylece
/// repository ve UI katmanları SDK ayrıntılarından bağımsız kalır.
class SupabaseAuthDatasource {
  /// İsteğe bağlı başlatılmış [sb.SupabaseClient] ile veri kaynağı oluşturur.
  const SupabaseAuthDatasource(this._client);

  /// Mobil OAuth ve e-posta yönlendirmeleri için izinli derin bağlantı adresi.
  static const String authRedirectUrl = 'io.roamory.app://login-callback/';

  /// `database.md` kuralına göre `avatars` bucket maksimum dosya boyutu (5 MB).
  static const int maxAvatarBytes = 5 * 1024 * 1024;

  static const Set<String> _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  final sb.SupabaseClient? _client;

  sb.SupabaseClient get _requireClient {
    final client = _client;
    if (client == null) {
      // --dart-define eksikse sahte başarı yerine açık yapılandırma hatası fırlatılır.
      throw const SupabaseNotConfiguredException();
    }
    return client;
  }

  /// Mevcut Supabase oturumundaki kullanıcıyı domain varlığına eşler.
  AuthUser? getCurrentUser() {
    final client = _client;
    if (client == null) {
      return null;
    }
    final user = client.auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  /// Supabase oturum akışını domain [AuthUser] akışına dönüştürür.
  Stream<AuthUser?> watchAuthChanges() {
    final client = _client;
    if (client == null) {
      return Stream<AuthUser?>.value(null);
    }
    return client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user ?? client.auth.currentUser;
      return user == null ? null : _mapUser(user);
    });
  }

  /// E-posta ve parola ile oturum açar.
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _requireClient.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const UnknownAppException(code: 'auth_null_user');
    }
    return _mapUser(user);
  }

  /// Yeni kullanıcı kaydı oluşturur; onay bekleniyorsa `null` dönebilir.
  Future<AuthUser?> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _requireClient.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: authRedirectUrl,
      data: {'full_name': fullName.trim()},
    );
    final user = response.user;
    // Supabase e-posta doğrulama açıkken session null döner; A06'ya geçiş buna göre yapılır.
    if (user == null || response.session == null) {
      return null;
    }
    return _mapUser(user);
  }

  /// Google OAuth akışını harici tarayıcı ve deep-link dönüşüyle başlatır.
  Future<void> signInWithGoogle() async {
    final launched = await _requireClient.auth.signInWithOAuth(
      sb.OAuthProvider.google,
      redirectTo: authRedirectUrl,
    );
    if (!launched) {
      throw const UnknownAppException(code: 'oauth_launch_failed');
    }
  }

  /// Kayıt doğrulama e-postasını yeniden gönderir.
  Future<void> resendVerificationEmail({required String email}) async {
    await _requireClient.auth.resend(
      type: sb.OtpType.signup,
      email: email.trim(),
      emailRedirectTo: authRedirectUrl,
    );
  }

  /// Kullanıcının girdiği 6 haneli doğrulama kodunu Supabase üzerinden onaylar.
  Future<AuthUser> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final response = await _requireClient.auth.verifyOTP(
      email: email.trim(),
      token: token.trim(),
      type: sb.OtpType.signup,
    );
    final user = response.user;
    if (user == null) {
      throw const UnauthorizedAppException(code: 'otp_invalid');
    }
    return _mapUser(user);
  }

  /// Oturumu yenileyerek e-posta doğrulama bilgisinin güncellenip güncellenmediğini kontrol eder.
  Future<AuthUser?> refreshCurrentUser() async {
    final client = _requireClient;
    if (client.auth.currentSession != null) {
      final response = await client.auth.refreshSession();
      final user = response.user ?? client.auth.currentUser;
      return user == null ? null : _mapUser(user);
    }
    final user = client.auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  /// Tek kullanımlık şifre sıfırlama bağlantısı gönderir.
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _requireClient.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: authRedirectUrl,
    );
  }

  /// `public.profiles` tablosundan kullanıcının profil kaydını okur.
  Future<UserProfileModel?> fetchProfile(String userId) async {
    final data = await _requireClient
        .from('profiles')
        .select('id, username, full_name, avatar_url, bio, preferred_language')
        .eq('id', userId)
        .maybeSingle();
    if (data == null) {
      return null;
    }
    return UserProfileModel.fromJson(data);
  }

  /// Seçilen kullanıcı adının başka bir hesaba ait olup olmadığını kontrol eder.
  Future<bool> isUsernameAvailable({
    required String username,
    required String currentUserId,
  }) async {
    final data = await _requireClient
        .from('profiles')
        .select('id')
        .eq('username', username)
        .neq('id', currentUserId)
        .maybeSingle();
    return data == null;
  }

  /// Avatar dosyasını `avatars` public bucket'ına `userUUID/dosya` yoluyla yükler.
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String extension,
  }) async {
    final normalizedExt = extension.trim().toLowerCase();
    if (!_allowedExtensions.contains(normalizedExt)) {
      throw const ValidationAppException(code: 'invalid_avatar_format');
    }
    if (bytes.lengthInBytes > maxAvatarBytes) {
      throw const ValidationAppException(code: 'avatar_too_large');
    }

    final mimeType = switch (normalizedExt) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    final path =
        '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$normalizedExt';

    await _requireClient.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: sb.FileOptions(contentType: mimeType, upsert: true),
        );

    return _requireClient.storage.from('avatars').getPublicUrl(path);
  }

  /// Profil kaydını `auth.users` trigger'ı ile yarış durumuna girmeyecek şekilde upsert eder.
  Future<UserProfileModel> upsertProfile(UserProfileModel model) async {
    final response = await _requireClient
        .from('profiles')
        .upsert(model.toUpsertJson(), onConflict: 'id')
        .select('id, username, full_name, avatar_url, bio, preferred_language')
        .single();
    return UserProfileModel.fromJson(response);
  }

  /// Aktif Supabase oturumunu kapatır.
  Future<void> signOut() async {
    await _requireClient.auth.signOut();
  }

  AuthUser _mapUser(sb.User user) {
    final metadata = user.userMetadata;
    final fullName = metadata?['full_name'] as String?;
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      emailVerified: user.emailConfirmedAt != null,
      fullName: fullName,
    );
  }
}
