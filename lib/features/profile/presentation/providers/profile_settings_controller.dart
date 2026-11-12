import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/notifications/domain/entities/notification_entity.dart';
import 'package:roamory/features/profile/data/repositories/supabase_profile_settings_repository.dart';

/// Bildirimler ekranı (`F03`) sekme filtreleri.
///
/// `interactions` filtresi hem beğeni (`like`) hem de yorum (`comment`)
/// bildirimlerini tek sekmede gösterir.
enum NotificationFilter { all, follows, interactions, system }

/// Bildirimler, profil düzenleme ve hesap güvenliği durumunu tutar.
@immutable
class ProfileSettingsState {
  /// Profil ve bildirim durumu oluşturur.
  const ProfileSettingsState({
    this.isLoading = false,
    this.isSaving = false,
    this.notifications = const [],
    this.selectedFilter = NotificationFilter.all,
    this.error,
  });

  /// Yüklenme durumu.
  final bool isLoading;

  /// Kayıt/güncelleme sürüyor mu.
  final bool isSaving;

  /// Kullanıcının bildirim listesi (`notifications`).
  final List<NotificationEntity> notifications;

  /// Seçili bildirim filtresi.
  final NotificationFilter selectedFilter;

  /// Varsa son işlem hatası.
  final AppException? error;

  /// Okunmamış bildirim sayısı.
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Seçili filtreye göre süzülmüş bildirim listesi.
  List<NotificationEntity> get filteredNotifications {
    return switch (selectedFilter) {
      NotificationFilter.all => notifications,
      NotificationFilter.follows =>
        notifications.where((n) => n.kind == NotificationKind.follow).toList(),
      NotificationFilter.interactions =>
        notifications
            .where(
              (n) =>
                  n.kind == NotificationKind.like ||
                  n.kind == NotificationKind.comment,
            )
            .toList(),
      NotificationFilter.system =>
        notifications.where((n) => n.kind == NotificationKind.system).toList(),
    };
  }

  /// Seçili alanları güncelleyerek kopya üretir.
  ProfileSettingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<NotificationEntity>? notifications,
    NotificationFilter? selectedFilter,
    AppException? error,
    bool clearError = false,
  }) {
    return ProfileSettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      notifications: notifications ?? this.notifications,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Bildirimleri, profil düzenlemeyi ve hesap güvenliğini yöneten Riverpod Notifier.
class ProfileSettingsController extends Notifier<ProfileSettingsState> {
  @override
  ProfileSettingsState build() {
    // Aktif kullanıcı değiştiğinde bildirimleri yeniden yüklüyoruz.
    ref.watch(authControllerProvider.select((s) => s.user?.id));
    Future.microtask(loadNotifications);
    return const ProfileSettingsState(isLoading: true);
  }

  String get _currentUserId => ref.read(authControllerProvider).user?.id ?? '';

  /// Kullanıcının bildirimlerini yükler (`F03`).
  Future<void> loadNotifications() async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      state = state.copyWith(isLoading: false, notifications: const []);
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await ref
          .read(profileSettingsRepositoryProvider)
          .fetchNotifications(userId);
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        notifications: list,
        clearError: true,
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: ErrorMapper.map(error, stackTrace),
      );
    }
  }

  /// Bildirim filtresini değiştirir (`F03`).
  void setFilter(NotificationFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// Tek bir bildirimi okundu olarak işaretler (`F03`).
  Future<void> markRead(String notificationId) async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      return;
    }
    try {
      await ref
          .read(profileSettingsRepositoryProvider)
          .markNotificationRead(notificationId: notificationId, userId: userId);
      if (!ref.mounted) return;
      state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
            .toList(),
        clearError: true,
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
    }
  }

  /// Tüm bildirimleri okundu olarak işaretler (`F03`).
  Future<void> markAllRead() async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      return;
    }
    try {
      await ref
          .read(profileSettingsRepositoryProvider)
          .markAllNotificationsRead(userId);
      if (!ref.mounted) return;
      state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList(),
        clearError: true,
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = state.copyWith(error: ErrorMapper.map(error, stackTrace));
    }
  }

  /// Profil bilgilerini ve varsa yeni avatar fotoğrafını kaydeder (`F02`).
  Future<bool> saveProfile({
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
    final userId = _currentUserId;
    if (userId.isEmpty) {
      return false;
    }
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final updated = await ref
          .read(profileSettingsRepositoryProvider)
          .updateExtendedProfile(
            userId: userId,
            fullName: fullName,
            username: username,
            preferredLanguage: preferredLanguage,
            bio: bio,
            homeCity: homeCity,
            homeCountry: homeCountry,
            isPublic: isPublic,
            avatarBytes: avatarBytes,
            avatarFileExtension: avatarFileExtension,
          );

      ref.read(authControllerProvider.notifier).updateCurrentProfile(updated);
      await ref
          .read(appPreferencesProvider.notifier)
          .setLocale(Locale(updated.preferredLanguage));

      state = state.copyWith(isSaving: false, clearError: true);
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isSaving: false,
        error: ErrorMapper.map(error, stackTrace),
      );
      return false;
    }
  }

  /// Kullanıcının şifresini günceller (`F05`).
  Future<bool> updatePassword(String newPassword) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await ref
          .read(profileSettingsRepositoryProvider)
          .updatePassword(newPassword);
      state = state.copyWith(isSaving: false, clearError: true);
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isSaving: false,
        error: ErrorMapper.map(error, stackTrace),
      );
      return false;
    }
  }

  /// Kullanıcının verilerini temizleyip oturumu kapatarak hesap silme işlemini yürütür (`F05`).
  Future<bool> deleteAccountData() async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      return false;
    }
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await ref
          .read(profileSettingsRepositoryProvider)
          .deleteUserAccountData(userId);
      await ref.read(authControllerProvider.notifier).signOut();
      state = state.copyWith(isSaving: false, clearError: true);
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isSaving: false,
        error: ErrorMapper.map(error, stackTrace),
      );
      return false;
    }
  }
}

/// Bildirimler ve profil ayarları sağlayıcısı.
final profileSettingsControllerProvider =
    NotifierProvider<ProfileSettingsController, ProfileSettingsState>(
      ProfileSettingsController.new,
    );
