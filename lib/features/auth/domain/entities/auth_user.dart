import 'package:flutter/foundation.dart';

/// Kimliği doğrulanmış kullanıcıyı temsil eden bağımsız domain varlığı.
///
/// Supabase SDK bağımlılığı içermez; `data` katmanındaki dönüşümlerle doldurulur.
@immutable
class AuthUser {
  /// [AuthUser] örneği oluşturur.
  const AuthUser({
    required this.id,
    required this.email,
    required this.emailVerified,
    this.fullName,
  });

  /// Kullanıcının benzersiz kimliği (`auth.users.id`).
  final String id;

  /// Kullanıcının e-posta adresi.
  final String email;

  /// E-posta doğrulamasının tamamlanıp tamamlanmadığı.
  final bool emailVerified;

  /// Kayıt veya OAuth sırasında sağlanan ad soyad bilgisi.
  final String? fullName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          emailVerified == other.emailVerified &&
          fullName == other.fullName;

  @override
  int get hashCode => Object.hash(id, email, emailVerified, fullName);
}
