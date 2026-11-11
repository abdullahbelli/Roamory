/// Kimlik doğrulama ve profil formları için saf domain doğrulama kuralları.
///
/// Hem UI anlık form kontrollerinde hem de testlerde aynı kuralların
/// tutarlı çalışması için tek merkezde toplanmıştır.
abstract final class AuthValidators {
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  static final RegExp _usernameRegex = RegExp(r'^[a-z0-9_]{3,24}$');
  static final RegExp _letterRegex = RegExp(r'[A-Za-z]');
  static final RegExp _digitRegex = RegExp(r'[0-9]');

  /// E-posta biçiminin geçerli olup olmadığını kontrol eder.
  static bool isValidEmail(String value) {
    return _emailRegex.hasMatch(value.trim());
  }

  /// Parolanın güvenlik kuralını (`>= 8 karakter`, en az 1 harf ve 1 rakam) doğrular.
  static bool isValidPassword(String value) {
    if (value.length < 8) {
      return false;
    }
    return _letterRegex.hasMatch(value) && _digitRegex.hasMatch(value);
  }

  /// Ad soyad alanının anlamlı bir uzunlukta olup olmadığını doğrular.
  static bool isValidFullName(String value) {
    return value.trim().length >= 2;
  }

  /// Kullanıcı adını normalize edip (`@` temizleme, küçük harf) biçimini doğrular.
  static String normalizeUsername(String value) {
    final trimmed = value.trim().toLowerCase();
    return trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
  }

  /// Kullanıcı adının 3-24 karakter, küçük harf, rakam veya alt çizgi olduğunu doğrular.
  static bool isValidUsername(String value) {
    return _usernameRegex.hasMatch(normalizeUsername(value));
  }

  /// 6 haneli doğrulama kodunun yalnızca rakamlardan oluştuğunu doğrular.
  static bool isValidOtpCode(String value) {
    return RegExp(r'^\d{6}$').hasMatch(value.trim());
  }
}
