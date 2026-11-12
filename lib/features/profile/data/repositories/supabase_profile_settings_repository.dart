import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:roamory/features/auth/data/models/user_profile_model.dart';
import 'package:roamory/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:roamory/features/auth/domain/entities/user_profile.dart';
import 'package:roamory/features/auth/domain/usecases/auth_validators.dart';
import 'package:roamory/features/notifications/domain/entities/notification_entity.dart';
import 'package:roamory/features/profile/domain/repositories/profile_settings_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// [ProfileAndSettingsRepository] sözleşmesinin Supabase `notifications`,
/// `profiles`, `avatars` Storage ve Auth parola güncelleme implementasyonu.
class SupabaseProfileSettingsRepository
    implements ProfileAndSettingsRepository {
  /// Supabase istemcisi ve Auth veri kaynağıyla repository oluşturur.
  const SupabaseProfileSettingsRepository(this._client, this._authDatasource);

  final sb.SupabaseClient? _client;
  final SupabaseAuthDatasource _authDatasource;

  sb.SupabaseClient get _requireClient {
    final client = _client;
    if (client == null) {
      throw const SupabaseNotConfiguredException();
    }
    return client;
  }

  @override
  Future<List<NotificationEntity>> fetchNotifications(String userId) async {
    try {
      final rows = await _requireClient
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (rows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(mapNotificationRow)
          .toList();
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> markNotificationRead({
    required String notificationId,
    required String userId,
  }) async {
    try {
      await _requireClient
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> markAllNotificationsRead(String userId) async {
    try {
      await _requireClient
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
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
  }) async {
    try {
      if (!AuthValidators.isValidFullName(fullName)) {
        throw const ValidationAppException(code: 'invalid_full_name');
      }
      final normalizedUsername = AuthValidators.normalizeUsername(username);
      if (!AuthValidators.isValidUsername(normalizedUsername)) {
        throw const ValidationAppException(code: 'invalid_username');
      }

      String? avatarUrl;
      if (avatarBytes != null) {
        avatarUrl = await _authDatasource.uploadAvatar(
          userId: userId,
          bytes: avatarBytes,
          extension: avatarFileExtension ?? 'jpg',
        );
      }

      final payload = <String, dynamic>{
        'id': userId,
        'full_name': fullName.trim(),
        'username': normalizedUsername,
        'bio': bio?.trim().isEmpty ?? true ? null : bio!.trim(),
        'preferred_language': preferredLanguage,
        'avatar_url': ?avatarUrl,
      };

      final row = await _requireClient
          .from('profiles')
          .upsert(payload, onConflict: 'id')
          .select()
          .single();

      return UserProfileModel.fromJson(row).toEntity().copyWith(
        homeCity: homeCity?.trim(),
        homeCountry: homeCountry?.trim(),
        isPublic: isPublic,
      );
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      if (!AuthValidators.isValidPassword(newPassword)) {
        throw const ValidationAppException(code: 'weak_password');
      }
      await _requireClient.auth.updateUser(
        sb.UserAttributes(password: newPassword),
      );
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> deleteUserAccountData(String userId) async {
    try {
      final client = _requireClient;
      // Kullanıcının RLS yetkisi dahilindeki kişisel kayıtlarını temizliyoruz
      // ve oturumu kapatıyoruz (`auth.admin.deleteUser` istemcide çağrılamaz).
      await client.from('visits').delete().eq('user_id', userId);
      await client.from('trips').delete().eq('user_id', userId);
      await client.from('wishlist_items').delete().eq('user_id', userId);
      await client.from('posts').delete().eq('user_id', userId);
      await client.auth.signOut();
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  /// Supabase `notifications` satırını [NotificationEntity] varlığına dönüştürür.
  static NotificationEntity mapNotificationRow(Map<String, dynamic> row) {
    return NotificationEntity(
      id: (row['id'] ?? '').toString(),
      userId: (row['user_id'] ?? '').toString(),
      kind: NotificationKind.fromDb(row['type'] as String?),
      title: (row['title'] ?? '').toString(),
      body: (row['body'] ?? row['message'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((row['created_at'] ?? '').toString()) ??
          DateTime.now(),
      isRead: (row['is_read'] as bool?) ?? false,
      actorUserId: (row['actor_id'] ?? row['actor_user_id'])?.toString(),
      targetPostId: (row['post_id'] ?? row['target_post_id'])?.toString(),
    );
  }
}

/// Uygulama genelinde kullanılan [ProfileAndSettingsRepository] sağlayıcısı.
final profileSettingsRepositoryProvider =
    Provider<ProfileAndSettingsRepository>((ref) {
      final client = ref.watch(supabaseClientProvider);
      final authDs = ref.watch(supabaseAuthDatasourceProvider);
      return SupabaseProfileSettingsRepository(client, authDs);
    });
