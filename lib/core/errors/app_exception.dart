import 'package:roamory/app/l10n/app_localizations.dart';

/// Roamory domain ve data katmanlarında kullanılan temel hata türü.
///
/// Teknik Supabase/HTTP detaylarını UI'dan gizleyip kullanıcıya güvenli ve
/// yerelleştirilmiş hata mesajı göstermek için kullanılır.
sealed class AppException implements Exception {
  /// İsteğe bağlı hata kodu ve teknik debug açıklamasıyla hata üretir.
  const AppException({this.code, this.debugMessage});

  /// Hata kaynağını ayırt etmek için kullanılan teknik olmayan kısa kod.
  final String? code;

  /// Yalnızca debug logları için tutulan teknik açıklama; UI'da gösterilmez.
  final String? debugMessage;

  /// Kullanıcıya gösterilecek yerelleştirilmiş hata mesajını döndürür.
  String localizedMessage(AppLocalizations l10n);

  @override
  String toString() => '$runtimeType(code: $code)';
}

/// İnternet bağlantısı olmadığında veya zaman aşımında fırlatılır.
final class NetworkAppException extends AppException {
  /// Ağ hatası örneği oluşturur.
  const NetworkAppException({super.code, super.debugMessage});

  @override
  String localizedMessage(AppLocalizations l10n) => l10n.errorNetworkMessage;
}

/// Oturum geçersizse veya RLS yetki kontrolü reddederse fırlatılır.
final class UnauthorizedAppException extends AppException {
  /// Yetkisiz erişim hatası örneği oluşturur.
  const UnauthorizedAppException({super.code, super.debugMessage});

  @override
  String localizedMessage(AppLocalizations l10n) =>
      l10n.errorUnauthorizedMessage;
}

/// İstenen kayıt veritabanında bulunamadığında fırlatılır.
final class NotFoundAppException extends AppException {
  /// Kayıt bulunamadı hatası örneği oluşturur.
  const NotFoundAppException({super.code, super.debugMessage});

  @override
  String localizedMessage(AppLocalizations l10n) => l10n.errorNotFoundMessage;
}

/// Domain veya form doğrulama kuralları ihlal edildiğinde fırlatılır.
final class ValidationAppException extends AppException {
  /// Doğrulama hatası örneği oluşturur.
  const ValidationAppException({super.code, super.debugMessage});

  @override
  String localizedMessage(AppLocalizations l10n) => l10n.errorValidationMessage;
}

/// Supabase bağlantı bilgileri derleme ortamında eksikse fırlatılır.
final class SupabaseNotConfiguredException extends AppException {
  /// Yapılandırma eksikliği hatası örneği oluşturur.
  const SupabaseNotConfiguredException()
    : super(code: 'supabase_not_configured');

  @override
  String localizedMessage(AppLocalizations l10n) =>
      l10n.errorSupabaseNotConfigured;
}

/// Beklenmeyen sunucu veya bilinmeyen uygulama hatalarını temsil eder.
final class UnknownAppException extends AppException {
  /// Genel hata örneği oluşturur.
  const UnknownAppException({super.code, super.debugMessage});

  @override
  String localizedMessage(AppLocalizations l10n) => l10n.errorGenericMessage;
}
