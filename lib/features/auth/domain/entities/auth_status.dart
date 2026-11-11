import 'package:flutter/foundation.dart';
import 'package:roamory/features/auth/domain/entities/auth_user.dart';
import 'package:roamory/features/auth/domain/entities/user_profile.dart';

/// Uygulamanın üst düzey kimlik doğrulama ve oturum aşamalarını tanımlar.
enum AuthFlowStatus {
  /// Başlangıç oturum kontrolü sürüyor (`A01`).
  initializing,

  /// Aktif oturum yok (`A02` veya `A03`).
  unauthenticated,

  /// Kullanıcı kayıtlı ancak e-posta doğrulaması bekleniyor (`A06`).
  needsEmailVerification,

  /// Oturum açık ancak profil kurulumu eksik (`A07`).
  needsProfileSetup,

  /// Kullanıcı tamamen doğrulanmış ve profili tamam (`B01` ana kabuk).
  authenticated,
}

/// Auth akışının anlık oturum, profil ve doğrulama durumunu tutar.
@immutable
class AuthSessionState {
  /// Yeni bir [AuthSessionState] örneği oluşturur.
  const AuthSessionState({
    required this.status,
    this.user,
    this.profile,
    this.pendingVerificationEmail,
  });

  /// Açılış yüklenme durumu.
  const AuthSessionState.initializing()
    : status = AuthFlowStatus.initializing,
      user = null,
      profile = null,
      pendingVerificationEmail = null;

  /// Oturumsuz durum.
  const AuthSessionState.unauthenticated()
    : status = AuthFlowStatus.unauthenticated,
      user = null,
      profile = null,
      pendingVerificationEmail = null;

  /// Akış durumu.
  final AuthFlowStatus status;

  /// Aktif oturum kullanıcısı; oturum kapalıysa `null`.
  final AuthUser? user;

  /// Kullanıcının veritabanı profili; henüz çekilmediyse veya oturum yoksa `null`.
  final UserProfile? profile;

  /// E-posta doğrulama ekranında (`A06`) gösterilecek bekleyen adres.
  final String? pendingVerificationEmail;

  /// Durum kopyası üretir.
  AuthSessionState copyWith({
    AuthFlowStatus? status,
    AuthUser? user,
    UserProfile? profile,
    String? pendingVerificationEmail,
  }) {
    return AuthSessionState(
      status: status ?? this.status,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      pendingVerificationEmail:
          pendingVerificationEmail ?? this.pendingVerificationEmail,
    );
  }
}
