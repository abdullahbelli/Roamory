import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/community/presentation/providers/community_controller.dart';
import 'package:roamory/features/profile/presentation/providers/profile_settings_controller.dart';
import 'package:roamory/features/trips/presentation/providers/trips_controller.dart';
import 'package:roamory/features/visits/presentation/providers/visits_controller.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_network_image.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Roamory Profilim Ekranı (`F01` — Stitch `3af660ab26094fc4bae9e492c4094846`).
///
/// Kullanıcının görünen adını, `@username` kimliğini, biyografisini, gerçek
/// Dijital Pasaport sayaçlarını (Ülke, Şehir, Ziyaret, Rotalar) ve sekmeli
/// içeriklerini (`Gönderilerim`, `Özel Günlüğüm`, `Rotalarım`, `Kaydedilenler`)
/// gösterir. Profili Düzenle (`F02`), Bildirimler (`F03`) ve Ayarlar (`F04`)
/// ekranlarına geçiş sağlar.
class MyProfileScreen extends ConsumerStatefulWidget {
  /// Profilim ekranı oluşturur.
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final authState = ref.watch(authControllerProvider);
    final visitsState = ref.watch(visitsControllerProvider);
    final tripsState = ref.watch(tripsControllerProvider);
    final communityState = ref.watch(communityControllerProvider);
    final notifState = ref.watch(profileSettingsControllerProvider);

    final profile = authState.profile;
    final userId = authState.user?.id ?? '';
    final fullName =
        profile?.fullName ?? authState.user?.fullName ?? l10n.myProfileTitle;
    final username = profile?.username ?? 'gezgin';
    final avatarUrl = profile?.avatarUrl?.trim();

    final myPosts = communityState.feedPosts
        .where((p) => p.userId == userId)
        .toList();

    return RoamoryScaffold(
      appBar: AppBar(
        title: Text(l10n.myProfileTitle),
        actions: [
          Stack(
            children: [
              IconButton(
                tooltip: l10n.notificationsTitle,
                onPressed: () => context.push(AppRoutes.notifications),
                icon: const Icon(Icons.notifications_outlined),
              ),
              if (notifState.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.md,
          AppSpacing.pageMargin,
          AppSpacing.bottomNavHeight + AppSpacing.xl * 2,
        ),
        children: [
          // Profil başlık kartı.
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: colors.primaryContainer,
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? ClipOval(
                          child: AppNetworkImage(
                            imageUrl: avatarUrl,
                            width: 76,
                            height: 76,
                            borderRadius: 38,
                            placeholderIcon: Icons.person_outline_rounded,
                          ),
                        )
                      : Icon(
                          Icons.person_outline_rounded,
                          size: 38,
                          color: colors.primary,
                        ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(fullName, style: textTheme.headlineSmall),
                Text(
                  '@$username',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (profile?.bio != null &&
                    profile!.bio!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    profile.bio!,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _ProfileMetric(
                        label: l10n.homePassportCountries,
                        value: visitsState.uniqueCountriesCount.toString(),
                      ),
                    ),
                    Expanded(
                      child: _ProfileMetric(
                        label: l10n.homePassportCities,
                        value: visitsState.uniqueCitiesCount.toString(),
                      ),
                    ),
                    Expanded(
                      child: _ProfileMetric(
                        label: l10n.homePassportVisits,
                        value: visitsState.visits.length.toString(),
                      ),
                    ),
                    Expanded(
                      child: _ProfileMetric(
                        label: l10n.tripsTitle,
                        value: tripsState.trips.length.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: l10n.myProfileEditButton,
                        icon: Icons.edit_outlined,
                        outlined: true,
                        onPressed: () => context.push(AppRoutes.profileEdit),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: PrimaryButton(
                        label: l10n.myProfilePassportButton,
                        icon: Icons.map_outlined,
                        onPressed: () => context.go(AppRoutes.map),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Sekme seçiciler: Gönderilerim, Özel Günlüğüm, Rotalarım, Kaydedilenler.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.myProfileTabPosts),
                  selected: _selectedTab == 0,
                  onSelected: (_) => setState(() => _selectedTab = 0),
                ),
                const SizedBox(width: AppSpacing.xs),
                ChoiceChip(
                  label: Text(l10n.myProfileTabJournal),
                  selected: _selectedTab == 1,
                  onSelected: (_) => setState(() => _selectedTab = 1),
                ),
                const SizedBox(width: AppSpacing.xs),
                ChoiceChip(
                  label: Text(l10n.myProfileTabTrips),
                  selected: _selectedTab == 2,
                  onSelected: (_) => setState(() => _selectedTab = 2),
                ),
                const SizedBox(width: AppSpacing.xs),
                ChoiceChip(
                  label: Text(l10n.myProfileTabSaved),
                  selected: _selectedTab == 3,
                  onSelected: (_) => setState(() => _selectedTab = 3),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (_selectedTab == 0) ...[
            if (myPosts.isEmpty)
              Text(
                l10n.communityEmptyExplore,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              )
            else
              ...myPosts.map(
                (p) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(p.title ?? p.caption),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.postDetailsPath(p.id)),
                ),
              ),
          ] else if (_selectedTab == 1) ...[
            if (visitsState.visits.isEmpty)
              Text(
                l10n.visitsEmptyMessage,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              )
            else
              ...visitsState.visits.map(
                (v) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.lock_outline_rounded,
                    color: colors.primary,
                  ),
                  title: Text(
                    v.title ?? v.place?.name ?? l10n.visitDetailsTitle,
                  ),
                  subtitle: Text(l10n.commonPrivateBadge),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.visitDetailsPath(v.id)),
                ),
              ),
          ] else if (_selectedTab == 2) ...[
            if (tripsState.trips.isEmpty)
              Text(
                l10n.tripsEmptyMessage,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              )
            else
              ...tripsState.trips.map(
                (t) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.luggage_outlined, color: colors.primary),
                  title: Text(t.title),
                  subtitle: Text(t.destinationLabel),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.tripDetailsPath(t.id)),
                ),
              ),
          ] else ...[
            if (communityState.savedPosts.isEmpty)
              Text(
                l10n.emptyDefaultMessage,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              )
            else
              ...communityState.savedPosts.map(
                (s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.bookmark_rounded, color: colors.accent),
                  title: Text(s.title ?? s.caption),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.postDetailsPath(s.id)),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = RoamoryColors.of(context);
    return Column(
      children: [
        Text(value, style: textTheme.titleLarge),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelSmall?.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

/// Roamory Profili Düzenle Ekranı (`F02` — Stitch `b8b80041477d48ecbec6aa8d8820454c`).
///
/// Kullanıcının görünen adını, benzersiz kullanıcı adını, biyografisini, yaşadığı
/// şehir/ülkeyi, herkese açık profil tercihini ve `avatars` Storage fotoğrafını
/// (`<= 5 MB`) günceller. Kaydedilmemiş değişikliklerde `S04` onay sayfasını açar.
class EditProfileScreen extends ConsumerStatefulWidget {
  /// Profil düzenleme ekranı oluşturur.
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;

  bool _isPublic = true;
  Uint8List? _avatarBytes;
  String? _avatarExt;
  String? _validationError;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authControllerProvider).profile;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _usernameController = TextEditingController(text: profile?.username ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _cityController = TextEditingController(text: profile?.homeCity ?? '');
    _countryController = TextEditingController(
      text: profile?.homeCountry ?? '',
    );
    _isPublic = profile?.isPublic ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final l10n = AppLocalizations.of(context);
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) {
      return;
    }
    final bytes = await file.readAsBytes();
    if (bytes.lengthInBytes > 5 * 1024 * 1024) {
      setState(() => _validationError = l10n.profileSetupAvatarSizeError);
      return;
    }
    setState(() {
      _avatarBytes = bytes;
      _avatarExt = file.name.split('.').last.toLowerCase();
      _isDirty = true;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final lang =
        ref.read(authControllerProvider).profile?.preferredLanguage ?? 'tr';

    final ok = await ref
        .read(profileSettingsControllerProvider.notifier)
        .saveProfile(
          fullName: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          preferredLanguage: lang,
          bio: _bioController.text.trim(),
          homeCity: _cityController.text.trim(),
          homeCountry: _countryController.text.trim(),
          isPublic: _isPublic,
          avatarBytes: _avatarBytes,
          avatarFileExtension: _avatarExt,
        );

    if (!mounted) {
      return;
    }
    if (ok) {
      _isDirty = false;
      context.pop();
    } else {
      final err = ref.read(profileSettingsControllerProvider).error;
      setState(
        () => _validationError =
            err?.localizedMessage(l10n) ?? l10n.errorValidationMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(profileSettingsControllerProvider);

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        final discard = await showAppConfirmSheet(
          context: context,
          title: l10n.confirmUnsavedTitle,
          message: l10n.confirmUnsavedMessage,
          confirmLabel: l10n.confirmDiscardAction,
          cancelLabel: l10n.confirmKeepEditingAction,
          isDestructive: true,
        );
        if (discard && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: RoamoryScaffold(
        appBar: AppBar(title: Text(l10n.editProfileTitle)),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: [
            if (_validationError != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  _validationError!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onErrorContainer,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Center(
              child: TextButton.icon(
                onPressed: _pickAvatar,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(l10n.profileSetupAddPhoto),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.profileSetupDisplayNameLabel,
              controller: _nameController,
              onChanged: (_) => _isDirty = true,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.profileSetupUsernameLabel,
              controller: _usernameController,
              onChanged: (_) => _isDirty = true,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.profileSetupBioLabel,
              controller: _bioController,
              maxLines: 3,
              onChanged: (_) => _isDirty = true,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: l10n.editProfileHomeCityLabel,
                    controller: _cityController,
                    onChanged: (_) => _isDirty = true,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppTextField(
                    label: l10n.editProfileHomeCountryLabel,
                    controller: _countryController,
                    onChanged: (_) => _isDirty = true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.editProfilePublicToggleTitle),
              subtitle: Text(l10n.editProfilePublicToggleSubtitle),
              value: _isPublic,
              onChanged: (v) => setState(() {
                _isPublic = v;
                _isDirty = true;
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: l10n.commonSave,
              isLoading: state.isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
