import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
import 'package:roamory/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:roamory/features/auth/domain/repositories/auth_repository.dart';
import 'package:roamory/features/auth/domain/usecases/auth_validators.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/auth/presentation/widgets/auth_feedback_banner.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_network_image.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Stitch referansı: A07 — Profil Kurulumu (Profile Setup).
///
/// Kullanıcının görünen adını, benzersiz kullanıcı adını, biyografisini,
/// fotoğrafını ve dil tercihini tamamlamasını sağlar. Kurulum bitmeden
/// ana uygulamaya geçişe izin verilmez.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  /// Profil kurulum ekranı oluşturur.
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  final Set<String> _selectedInterests = {'nature', 'camping', 'culture'};
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarExt;
  String? _localWarning;
  bool? _isUsernameAvailable;
  bool _checkingUsername = false;

  @override
  void initState() {
    super.initState();
    final session = ref.read(authControllerProvider);
    final initialName =
        session.profile?.fullName ?? session.user?.fullName ?? '';
    final initialUsername = session.profile?.username ?? '';
    final initialBio = session.profile?.bio ?? '';
    _fullNameController.text = initialName;
    _usernameController.text = initialUsername;
    _bioController.text = initialBio;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final l10n = AppLocalizations.of(context);
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) {
      return;
    }

    final bytes = await picked.readAsBytes();
    if (!mounted) {
      return;
    }
    if (bytes.lengthInBytes > SupabaseAuthDatasource.maxAvatarBytes) {
      setState(() => _localWarning = l10n.profileSetupAvatarSizeError);
      return;
    }

    final dotIndex = picked.name.lastIndexOf('.');
    final ext = dotIndex != -1
        ? picked.name.substring(dotIndex + 1).toLowerCase()
        : 'jpg';

    setState(() {
      _selectedAvatarBytes = bytes;
      _selectedAvatarExt = ext;
      _localWarning = null;
    });
  }

  Future<void> _checkUsername(String raw) async {
    final normalized = AuthValidators.normalizeUsername(raw);
    if (!AuthValidators.isValidUsername(normalized)) {
      setState(() {
        _isUsernameAvailable = null;
        _checkingUsername = false;
      });
      return;
    }

    setState(() => _checkingUsername = true);
    try {
      final available = await ref
          .read(authControllerProvider.notifier)
          .isUsernameAvailable(normalized);
      if (!mounted) {
        return;
      }
      setState(() {
        _isUsernameAvailable = available;
        _checkingUsername = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _checkingUsername = false);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _localWarning = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final session = ref.read(authControllerProvider);
    final userId = session.user?.id;
    if (userId == null) {
      return;
    }

    final username = AuthValidators.normalizeUsername(_usernameController.text);
    final available = await ref
        .read(authControllerProvider.notifier)
        .isUsernameAvailable(username);
    if (!mounted) {
      return;
    }
    if (!available) {
      setState(() {
        _isUsernameAvailable = false;
        _localWarning = AppLocalizations.of(context).profileSetupUsernameTaken;
      });
      return;
    }

    final preferredLang =
        ref.read(appPreferencesProvider).locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    await ref
        .read(authActionProvider.notifier)
        .completeProfileSetup(
          ProfileUpsertRequest(
            userId: userId,
            fullName: _fullNameController.text.trim(),
            username: username,
            preferredLanguage: preferredLang == 'en' ? 'en' : 'tr',
            bio: _bioController.text.trim(),
            avatarBytes: _selectedAvatarBytes,
            avatarFileExtension: _selectedAvatarExt,
          ),
        );
  }

  Future<void> _handleSignOut() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmSheet(
      context: context,
      title: l10n.authSignOutConfirmTitle,
      message: l10n.authSignOutConfirmMessage,
      confirmLabel: l10n.authSignOut,
      isDestructive: true,
    );
    if (confirmed && mounted) {
      await ref.read(authActionProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final sessionState = ref.watch(authControllerProvider);
    final actionState = ref.watch(authActionProvider);
    final currentLang =
        ref.watch(appPreferencesProvider).locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    final interests = [
      ('nature', Icons.forest_outlined, l10n.interestNature),
      ('camping', Icons.cabin_outlined, l10n.interestCamping),
      ('history', Icons.account_balance_outlined, l10n.interestHistory),
      ('culture', Icons.theater_comedy_outlined, l10n.interestCulture),
      ('food', Icons.restaurant_outlined, l10n.interestFood),
      ('coast', Icons.waves_rounded, l10n.interestCoast),
      ('adventure', Icons.hiking_rounded, l10n.interestAdventure),
      ('city', Icons.location_city_outlined, l10n.interestCity),
    ];

    return RoamoryScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Üst adım başlığı ve çıkış/atlama kontrolü (A07).
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                AppSpacing.sm,
                AppSpacing.pageMargin,
                AppSpacing.xs,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: colors.primary,
                        child: Text(
                          '2',
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.profileSetupHeader,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelLarge,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _localWarning = l10n.profileSetupRequiredBeforeApp;
                          });
                        },
                        child: Text(
                          l10n.profileSetupSkip,
                          style: textTheme.labelMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: actionState.isLoading
                            ? null
                            : _handleSignOut,
                        icon: Icon(
                          Icons.logout_rounded,
                          size: 20,
                          color: colors.textSecondary,
                        ),
                        tooltip: l10n.authSignOut,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageMargin,
                  AppSpacing.md,
                  AppSpacing.pageMargin,
                  AppSpacing.xl,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_outlined,
                            size: 16,
                            color: colors.accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.profileSetupBadge,
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.profileSetupHeadline,
                        style: textTheme.displayLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.profileSetupDescription,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (actionState.error != null) ...[
                        AuthFeedbackBanner(
                          message: actionState.error!.localizedMessage(l10n),
                          onClose: () => ref
                              .read(authActionProvider.notifier)
                              .clearFeedback(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ] else if (_localWarning != null) ...[
                        AuthFeedbackBanner(
                          isInfo: true,
                          isError: false,
                          message: _localWarning!,
                          onClose: () => setState(() => _localWarning = null),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      // Avatar seçici (A07).
                      Center(
                        child: Column(
                          children: [
                            InkWell(
                              onTap: _pickAvatar,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colors.primaryContainer,
                                      border: Border.all(
                                        color: colors.primary,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: _selectedAvatarBytes != null
                                          ? Image.memory(
                                              _selectedAvatarBytes!,
                                              fit: BoxFit.cover,
                                            )
                                          : (sessionState.profile?.avatarUrl !=
                                                    null
                                                ? AppNetworkImage(
                                                    imageUrl: sessionState
                                                        .profile
                                                        ?.avatarUrl,
                                                    width: 100,
                                                    height: 100,
                                                    borderRadius: 50,
                                                  )
                                                : Icon(
                                                    Icons
                                                        .person_outline_rounded,
                                                    size: 42,
                                                    color: colors.primary,
                                                  )),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: colors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colors.background,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.add_rounded,
                                        size: 18,
                                        color: colors.onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextButton(
                              onPressed: _pickAvatar,
                              child: Text(
                                l10n.profileSetupAddPhoto,
                                style: textTheme.labelLarge?.copyWith(
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.profileSetupDisplayNameLabel,
                        hintText: l10n.profileSetupDisplayNameHint,
                        controller: _fullNameController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (!AuthValidators.isValidFullName(value ?? '')) {
                            return l10n.validationFullNameInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Kullanıcı adı alanı ve uygunluk durumu rozeti.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.profileSetupUsernameLabel,
                            style: textTheme.labelLarge,
                          ),
                          if (_checkingUsername)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else if (_isUsernameAvailable == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              child: Text(
                                l10n.profileSetupUsernameAvailable,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else if (_isUsernameAvailable == false)
                            Text(
                              l10n.profileSetupUsernameTaken,
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.error,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs + 2),
                      TextFormField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        onChanged: _checkUsername,
                        decoration: InputDecoration(
                          hintText: l10n.profileSetupUsernameHint,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 14, right: 8),
                            child: Text(
                              '@',
                              style: textTheme.titleMedium?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                        ),
                        validator: (value) {
                          if (!AuthValidators.isValidUsername(value ?? '')) {
                            return l10n.profileSetupUsernameInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.profileSetupBioLabel,
                            style: textTheme.labelLarge,
                          ),
                          Text(
                            '${_bioController.text.length} / 160',
                            style: textTheme.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs + 2),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        maxLength: 160,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: l10n.profileSetupBioHint,
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // İlgi alanları seçimi (A07 görsel akışı; backend bağı T03'te doğrulanacak).
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              l10n.profileSetupInterestsTitle,
                              style: textTheme.headlineSmall,
                            ),
                          ),
                          Text(
                            l10n.profileSetupInterestsHint,
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.profileSetupInterestsSubtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: interests.map((item) {
                          final (id, icon, label) = item;
                          final selected = _selectedInterests.contains(id);
                          return FilterChip(
                            selected: selected,
                            showCheckmark: false,
                            avatar: Icon(
                              icon,
                              size: 16,
                              color: selected
                                  ? colors.onPrimary
                                  : colors.textSecondary,
                            ),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  label,
                                  style: textTheme.labelMedium?.copyWith(
                                    color: selected
                                        ? colors.onPrimary
                                        : colors.textPrimary,
                                  ),
                                ),
                                if (selected) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: colors.onPrimary,
                                  ),
                                ],
                              ],
                            ),
                            selectedColor: colors.primary,
                            backgroundColor: colors.surface,
                            onSelected: (isOn) {
                              setState(() {
                                if (isOn) {
                                  _selectedInterests.add(id);
                                } else {
                                  _selectedInterests.remove(id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.profileSetupLanguageTitle,
                        style: textTheme.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          border: Border.all(color: colors.outline),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _LanguageCardChoice(
                                label: l10n.profileSetupLanguageTr,
                                selected: currentLang != 'en',
                                colors: colors,
                                textTheme: textTheme,
                                onTap: () => ref
                                    .read(appPreferencesProvider.notifier)
                                    .setLocale(const Locale('tr')),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _LanguageCardChoice(
                                label: l10n.profileSetupLanguageEn,
                                selected: currentLang == 'en',
                                colors: colors,
                                textTheme: textTheme,
                                onTap: () => ref
                                    .read(appPreferencesProvider.notifier)
                                    .setLocale(const Locale('en')),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: l10n.profileSetupSubmit,
                        icon: Icons.arrow_forward_rounded,
                        isLoading: actionState.isLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.profileSetupFooterTerms,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageCardChoice extends StatelessWidget {
  const _LanguageCardChoice({
    required this.label,
    required this.selected,
    required this.colors,
    required this.textTheme,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final RoamoryColors colors;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
          border: selected ? Border.all(color: colors.outline) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelMedium?.copyWith(
            color: selected ? colors.textPrimary : colors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
