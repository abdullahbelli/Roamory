import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Alt katmanlardan gelen teknik istisnaları güvenli [AppException] türlerine çevirir.
///
/// Postgrest, Auth veya Storage hatalarındaki veritabanı ayrıntıları kullanıcıya
/// sızdırılmaz; yalnızca geliştirici debug günlüğüne yazılır.
abstract final class ErrorMapper {
  /// Verilen [error] nesnesini uygun [AppException] alt sınıfına dönüştürür.
  static AppException map(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }

    // Gizli olmayan hata özeti yalnızca debug modunda konsola yazılır.
    debugPrint('[ErrorMapper] Yakalanan hata (${error.runtimeType})');

    if (error is SocketException || error is TimeoutException) {
      return NetworkAppException(
        code: error.runtimeType.toString(),
        debugMessage: error.toString(),
      );
    }

    if (error is AuthException) {
      final status = error.statusCode;
      final lowerMsg = error.message.toLowerCase();
      final lowerCode = (error.code ?? '').toLowerCase();

      // 1. E-posta henüz doğrulanmamışsa A06 ekranına yönlendirebilmek için özel kod döneriz.
      if (lowerCode == 'email_not_confirmed' ||
          lowerMsg.contains('email not confirmed')) {
        return ValidationAppException(
          code: 'email_not_confirmed',
          debugMessage: error.message,
        );
      }

      // 2. OTP doğrulama kodu geçersiz veya süresi dolmuşsa.
      if (lowerCode == 'otp_expired' ||
          lowerCode == 'otp_disabled' ||
          lowerMsg.contains('token has expired') ||
          lowerMsg.contains('invalid otp')) {
        return ValidationAppException(
          code: 'otp_invalid',
          debugMessage: error.message,
        );
      }

      // 3. Yanlış e-posta veya şifre.
      if (lowerCode == 'invalid_credentials' ||
          lowerMsg.contains('invalid login credentials')) {
        return ValidationAppException(
          code: 'invalid_credentials',
          debugMessage: error.message,
        );
      }

      // 4. E-posta adresi zaten kayıtlıysa.
      if (lowerCode == 'user_already_exists' ||
          lowerCode == 'email_exists' ||
          lowerMsg.contains('already registered') ||
          lowerMsg.contains('already been registered')) {
        return ValidationAppException(
          code: 'email_already_in_use',
          debugMessage: error.message,
        );
      }

      // 5. Supabase yerleşik SMTP saatlik e-posta gönderim hız sınırı (429).
      if (status == '429' ||
          lowerCode.contains('rate_limit') ||
          lowerMsg.contains('rate limit')) {
        return ValidationAppException(
          code: 'rate_limit_exceeded',
          debugMessage: error.message,
        );
      }

      if (status == '401' || status == '403') {
        return UnauthorizedAppException(
          code: status,
          debugMessage: error.message,
        );
      }
      return ValidationAppException(code: status, debugMessage: error.message);
    }

    if (error is PostgrestException) {
      // Token, şifre veya kişisel veri içermeyen güvenli PostgREST hata özetini
      // yalnızca debug konsoluna yazıyoruz (hangi tablo/kodda hata çıktığını izlemek için).
      debugPrint(
        '[ErrorMapper] PostgrestException(code: ${error.code}, message: ${error.message}, hint: ${error.hint})',
      );

      final lowerMsg = error.message.toLowerCase();
      // PostgreSQL tablo düzeyi GRANT eksikliği (`permission denied for table ...`)
      // ile satır düzeyi RLS ihlalini (`new row violates row-level security policy`)
      // birbirinden ayırıyoruz ki kullanıcı oturumu açıkken yanıltıcı mesaj gösterilmesin.
      if (error.code == '42501' &&
          lowerMsg.contains('permission denied for table')) {
        return UnauthorizedAppException(
          code: 'db_table_permission_denied',
          debugMessage: error.message,
        );
      }
      if (error.code == '42501' || error.code == 'PGRST301') {
        return UnauthorizedAppException(
          code: error.code,
          debugMessage: error.message,
        );
      }
      if (error.code == 'PGRST116') {
        return NotFoundAppException(
          code: error.code,
          debugMessage: error.message,
        );
      }
      if (error.code == '23505') {
        return ValidationAppException(
          code: 'duplicate_record',
          debugMessage: error.message,
        );
      }
      if (error.code == '23503' || error.code == '23514') {
        // `trip_checklist_items_category_check` ihlalini genel mesaj yerine
        // kontrol listesi kategorisine özel anlaşılır koda dönüştürüyoruz.
        final msgLower = error.message.toLowerCase();
        if (error.code == '23514' &&
            msgLower.contains('trip_checklist_items_category_check')) {
          return ValidationAppException(
            code: 'checklist_invalid_category',
            debugMessage: error.message,
          );
        }
        return ValidationAppException(
          code: error.code,
          debugMessage: error.message,
        );
      }
      return UnknownAppException(code: error.code, debugMessage: error.message);
    }

    if (error is StorageException) {
      if (error.statusCode == '401' || error.statusCode == '403') {
        return UnauthorizedAppException(
          code: error.statusCode,
          debugMessage: error.message,
        );
      }
      if (error.statusCode == '404') {
        return NotFoundAppException(
          code: error.statusCode,
          debugMessage: error.message,
        );
      }
      return UnknownAppException(
        code: error.statusCode,
        debugMessage: error.message,
      );
    }

    return UnknownAppException(debugMessage: error.toString());
  }
}
