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
      if (status == '401' || status == '403') {
        return UnauthorizedAppException(
          code: status,
          debugMessage: error.message,
        );
      }
      return ValidationAppException(code: status, debugMessage: error.message);
    }

    if (error is PostgrestException) {
      // RLS ihlali (42501) veya yetkisiz durum kodlarını ayırıyoruz.
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
