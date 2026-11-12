import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
import 'package:roamory/core/utils/app_date_formatter.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/community/presentation/providers/community_controller.dart';
import 'package:roamory/features/notifications/domain/entities/notification_entity.dart';
import 'package:roamory/features/profile/presentation/providers/profile_settings_controller.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Bildirimler Ekranı (`F03` — Stitch `c16d655f10c841cebae33bf68ca7d6f0`).
///
/// Kullanıcının `notifications` tablosundaki gerçek bildirimlerini listeler,
/// türe göre filtreleme ve `Tümünü Okundu Say` (`is_read = true`) işlemlerini sunar.
class NotificationsScreen extends ConsumerWidget {
  /// Bildirimler ekranı oluşturur.
  const NotificationsScreen({super.key});

  IconData _iconForKind(NotificationKind kind) {
    return switch (kind) {
      NotificationKind.follow => Icons.person_add_alt_1_outlined,
      NotificationKind.like => Icons.favorite_outline_rounded,
      NotificationKind.comment => Icons.chat_bubble_outline_rounded,
      NotificationKind.system => Icons.notifications_outlined,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(profileSettingsControllerProvider);
    final notifier = ref.read(profileSettingsControllerProvider.notifier);
    final items = state.filteredNotifications;

    return RoamoryScaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () async {
                await notifier.markAllRead();
                if (context.mounted) {
                  final err = ref.read(profileSettingsControllerProvider).error;
                  if (err != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err.localizedMessage(l10n))),
                    );
                  }
                }
              },
              child: Text(l10n.notificationsMarkAllRead),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageMargin,
              vertical: AppSpacing.xs,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text(l10n.notificationsFilterAll),
                    selected: state.selectedFilter == NotificationFilter.all,
                    onSelected: (_) =>
                        notifier.setFilter(NotificationFilter.all),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ChoiceChip(
                    label: Text(l10n.notificationsFilterFollows),
                    selected:
                        state.selectedFilter == NotificationFilter.follows,
                    onSelected: (_) =>
                        notifier.setFilter(NotificationFilter.follows),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ChoiceChip(
                    label: Text(l10n.notificationsFilterInteractions),
                    selected:
                        state.selectedFilter == NotificationFilter.interactions,
                    onSelected: (_) =>
                        notifier.setFilter(NotificationFilter.interactions),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ChoiceChip(
                    label: Text(l10n.notificationsFilterSystem),
                    selected: state.selectedFilter == NotificationFilter.system,
                    onSelected: (_) =>
                        notifier.setFilter(NotificationFilter.system),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const LoadingSkeleton(
                    itemCount: 3,
                    showMediaPlaceholder: false,
                  )
                : items.isEmpty
                ? RefreshIndicator(
                    onRefresh: notifier.loadNotifications,
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: EmptyState(
                            icon: Icons.notifications_none_rounded,
                            title: l10n.notificationsEmptyTitle,
                            message: l10n.notificationsEmptyMessage,
                          ),
                        ),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: notifier.loadNotifications,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.pageMargin),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final n = items[index];
                        final postId = n.targetPostId?.trim();
                        final actorId = n.actorUserId?.trim();
                        return ListTile(
                          tileColor: n.isRead
                              ? null
                              : colors.primaryContainer.withValues(alpha: 0.28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: n.isRead
                                ? colors.surfaceVariant
                                : colors.primaryContainer,
                            child: Icon(
                              _iconForKind(n.kind),
                              color: n.isRead
                                  ? colors.textSecondary
                                  : colors.primary,
                            ),
                          ),
                          title: Text(
                            n.title,
                            style: n.isRead
                                ? textTheme.bodyMedium
                                : textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                          ),
                          subtitle: Text(
                            '${n.body} • ${AppDateFormatter.format(context, n.createdAt)}',
                          ),
                          trailing: n.isRead
                              ? null
                              : Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                          onTap: () async {
                            // Canlı DB'de authenticated rolünün yalnızca `is_read` güncelleme
                            // izni vardır; zaten okunmuş bildirimi tekrar UPDATE etmeyiz.
                            if (!n.isRead) {
                              await notifier.markRead(n.id);
                            }
                            if (!context.mounted) return;
                            if (postId != null && postId.isNotEmpty) {
                              await context.push(
                                AppRoutes.postDetailsPath(postId),
                              );
                            } else if (actorId != null && actorId.isNotEmpty) {
                              await context.push(
                                AppRoutes.travelerProfilePath(actorId),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Roamory Ayarlar Ekranı (`F04` — Stitch `1dfa9b5fcc0142b68b2e07fb62c0942f`).
///
/// TR/EN dil geçişini, Açık/Koyu/Sistem tema tercihini, engellenen kullanıcıları
/// (`user_blocks`), OpenStreetMap lisans atfını, Hesap & Güvenlik (`F05`) bağlantısını
/// ve onaylı oturum kapatma işlemini yönetir.
class SettingsScreen extends ConsumerWidget {
  /// Ayarlar ekranı oluşturur.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final prefs = ref.watch(appPreferencesProvider);
    final prefsNotifier = ref.read(appPreferencesProvider.notifier);
    final communityState = ref.watch(communityControllerProvider);
    final currentLang =
        prefs.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return RoamoryScaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          // Görünüm ve Dil.
          Text(l10n.settingsPreferencesSection, style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settingsLanguageLabel, style: textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    ChoiceChip(
                      label: const Text('Türkçe'),
                      selected: currentLang == 'tr',
                      onSelected: (_) =>
                          prefsNotifier.setLocale(const Locale('tr')),
                    ),
                    ChoiceChip(
                      label: const Text('English'),
                      selected: currentLang == 'en',
                      onSelected: (_) =>
                          prefsNotifier.setLocale(const Locale('en')),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.settingsThemeLabel, style: textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.themeSystem),
                      selected: prefs.themeMode == ThemeMode.system,
                      onSelected: (_) =>
                          prefsNotifier.setThemeMode(ThemeMode.system),
                    ),
                    ChoiceChip(
                      label: Text(l10n.themeLight),
                      selected: prefs.themeMode == ThemeMode.light,
                      onSelected: (_) =>
                          prefsNotifier.setThemeMode(ThemeMode.light),
                    ),
                    ChoiceChip(
                      label: Text(l10n.themeDark),
                      selected: prefs.themeMode == ThemeMode.dark,
                      onSelected: (_) =>
                          prefsNotifier.setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Hesap ve Güvenlik (F05 bağlantısı).
          Text(l10n.settingsAccountSection, style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            tileColor: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              side: BorderSide(color: colors.outline),
            ),
            leading: Icon(Icons.security_outlined, color: colors.primary),
            title: Text(l10n.accountSecurityTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.accountSecurity),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Engellenen Gezginler.
          Text(l10n.settingsBlockedUsersTitle, style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          if (communityState.blockedUsers.isEmpty)
            Text(
              l10n.settingsBlockedUsersEmpty,
              style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            )
          else
            ...communityState.blockedUsers.map((blocked) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(blocked.fullName),
                subtitle: Text('@${blocked.username}'),
                trailing: TextButton(
                  onPressed: () async {
                    final notifier = ref.read(
                      communityControllerProvider.notifier,
                    );
                    await notifier.unblockUser(blocked.id);
                    await notifier.loadFeed();
                  },
                  child: Text(l10n.communityUnblockUserAction),
                ),
              );
            }),
          const SizedBox(height: AppSpacing.lg),

          // Hakkında & OpenStreetMap Lisansı.
          Text(l10n.settingsAboutSection, style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.settingsOsmAttribution,
            style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Oturumu Kapat.
          SecondaryButton(
            label: l10n.authSignOut,
            icon: Icons.logout_rounded,
            outlined: true,
            onPressed: () async {
              final confirmed = await showAppConfirmSheet(
                context: context,
                title: l10n.authSignOutConfirmTitle,
                message: l10n.authSignOutConfirmMessage,
                confirmLabel: l10n.authSignOut,
                isDestructive: true,
              );
              if (confirmed) {
                await ref.read(authActionProvider.notifier).signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Roamory Hesap ve Güvenlik Ekranı (`F05` — Stitch `528fa05dc8ad4793aed27d80c42570d2`).
///
/// Kayıtlı e-posta bilgisini gösterir, şifre güncelleme (`updatePassword`),
/// oturum kapatma ve iki aşamalı onaylı hesap/veri silme akışını sunar.
class AccountSecurityScreen extends ConsumerStatefulWidget {
  /// Hesap ve güvenlik ekranı oluşturur.
  const AccountSecurityScreen({super.key});

  @override
  ConsumerState<AccountSecurityScreen> createState() =>
      _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends ConsumerState<AccountSecurityScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _feedback;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final l10n = AppLocalizations.of(context);
    if (_passwordController.text != _confirmController.text) {
      setState(() => _feedback = l10n.validationPasswordMismatch);
      return;
    }
    final ok = await ref
        .read(profileSettingsControllerProvider.notifier)
        .updatePassword(_passwordController.text);
    if (!mounted) {
      return;
    }
    setState(() {
      _feedback = ok
          ? l10n.accountSecurityPasswordUpdated
          : l10n.validationPasswordWeak;
    });
    if (ok) {
      _passwordController.clear();
      _confirmController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);
    final state = ref.watch(profileSettingsControllerProvider);

    return RoamoryScaffold(
      appBar: AppBar(title: Text(l10n.accountSecurityTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.accountSecurityEmailLabel,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authState.user?.email ?? 'gezgin@roamory.com',
                  style: textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.accountSecurityChangePasswordTitle,
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_feedback != null) ...[
            Text(
              _feedback!,
              style: textTheme.bodySmall?.copyWith(color: colors.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          AppTextField(
            label: l10n.accountSecurityNewPasswordLabel,
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: l10n.accountSecurityConfirmPasswordLabel,
            controller: _confirmController,
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: l10n.accountSecurityUpdatePasswordButton,
            isLoading: state.isSaving,
            onPressed: _updatePassword,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: colors.errorContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.accountSecurityDeleteTitle,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.accountSecurityDeleteSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onErrorContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SecondaryButton(
                  label: l10n.accountSecurityDeleteButton,
                  outlined: true,
                  onPressed: () async {
                    final confirmed = await showAppConfirmSheet(
                      context: context,
                      title: l10n.accountSecurityDeleteConfirmTitle,
                      message: l10n.accountSecurityDeleteConfirmMessage,
                      confirmLabel: l10n.commonDelete,
                      isDestructive: true,
                    );
                    if (confirmed) {
                      await ref
                          .read(profileSettingsControllerProvider.notifier)
                          .deleteAccountData();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
