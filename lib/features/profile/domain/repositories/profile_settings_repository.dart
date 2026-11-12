import 'dart:typed_data';

import 'package:roamory/features/auth/domain/entities/user_profile.dart';
import 'package:roamory/features/notifications/domain/entities/notification_entity.dart';

/// Bildirimler, profil düzenleme ve hesap güvenliği işlemleri için domain sözleşmesi.
abstract interface class ProfileAndSettingsRepository {
  /// Kullanıcının bildirimlerini (`notifications`) en yeniden eskiye getirir.
  Future<List<NotificationEntity>> fetchNotifications(String userId);

  /// Tek bir bildirimi okundu (`is_read = true`) olarak işaretler.
  Future<void> markNotificationRead({
    required String notificationId,
    required String userId,
  });

  /// Kullanıcının tüm okunmamış bildirimlerini okundu olarak işaretler.
  Future<void> markAllNotificationsRead(String userId);

  /// Kullanıcının profilini (`profiles`) ve varsa yeni avatarını günceller.
  Future<UserProfile> updateExtendedProfile({
    required String userId,
    required String fullName,
    required String username,
    required String preferredLanguage,
    String? bio,
    String? homeCity,
    String? homeCountry,
    bool isPublic = true,
    Uint8List? avatarBytes,
    String? avatarFileExtension,
  });

  /// Kullanıcının parolasını Supabase Auth üzerinden günceller (`F05`).
  Future<void> updatePassword(String newPassword);

  /// Kullanıcının kişisel verilerini temizleyip oturumunu sonlandırarak hesap silme
  /// sürecini güvenli biçimde tamamlar (`F05`).
  Future<void> deleteUserAccountData(String userId);
}
