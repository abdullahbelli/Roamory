import 'package:flutter/foundation.dart';

/// Bildirim türünü (`notifications.type`) sınıflandırır.
enum NotificationKind {
  /// Yeni takipçi bildirimi.
  follow('follow'),

  /// Gönderi beğenisi bildirimi.
  like('like'),

  /// Gönderi yorumu bildirimi.
  comment('comment'),

  /// Sistem veya güvenlik bildirimi.
  system('system');

  const NotificationKind(this.dbValue);

  /// Veritabanı değeri.
  final String dbValue;

  /// Veritabanındaki `type` değerini [NotificationKind] enum'una çevirir.
  static NotificationKind fromDb(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'follow' => NotificationKind.follow,
      'like' => NotificationKind.like,
      'comment' => NotificationKind.comment,
      _ => NotificationKind.system,
    };
  }
}

/// `public.notifications` tablosuna karşılık gelen bildirim domain varlığı.
///
/// `database.md` kuralına göre bildirimler istemciden doğrudan `INSERT` edilmez;
/// yalnızca kullanıcının kendi bildirimleri okunur ve `is_read` alanı güncellenir.
@immutable
class NotificationEntity {
  /// Bildirim varlığı oluşturur.
  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.actorUserId,
    this.targetPostId,
  });

  /// Bildirim kimliği (`notifications.id`).
  final String id;

  /// Alıcı kullanıcı kimliği (`auth.uid()`).
  final String userId;

  /// Bildirim türü (`follow`, `like`, `comment`, `system`).
  final NotificationKind kind;

  /// Bildirim başlığı.
  final String title;

  /// Bildirim açıklama metni.
  final String body;

  /// Oluşturulma zamanı.
  final DateTime createdAt;

  /// Okunma durumu (`is_read`).
  final bool isRead;

  /// Etkileşimi yapan gezginin kullanıcı kimliği (varsa).
  final String? actorUserId;

  /// İlgili gönderi kimliği (varsa).
  final String? targetPostId;

  /// Okunma durumunu güncelleyerek yeni örnek döndürür.
  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      userId: userId,
      kind: kind,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      actorUserId: actorUserId,
      targetPostId: targetPostId,
    );
  }
}
