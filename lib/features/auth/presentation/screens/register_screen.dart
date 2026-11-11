import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/auth/domain/entities/auth_status.dart';
import 'package:roamory/features/auth/domain/repositories/auth_repository.dart';
import 'package:roamory/features/auth/domain/usecases/auth_validators.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/auth/presentation/widgets/auth_feedback_banner.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Stitch referansı: A04 — Kayıt Ol (Register).
///
/// Ad soyad, e-posta, güçlü parola, parola tekrarı ve kullanım koşulları
/// onayını doğrulayarak yeni Supabase kullanıcı kaydı başlatır.
class RegisterScreen extends ConsumerStatefulWidget {
  /// Kayıt ekranı oluşturur.
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final isFormValid = _formKey.currentState?.validate() ?? false;
    setState(() => _showTermsError = !_acceptedTerms);

    if (!isFormValid || !_acceptedTerms) {
      return;
    }

    final status = await ref
        .read(authActionProvider.notifier)
        .signUpWithEmail(
          SignUpRequest(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );

    if (!mounted || status == null) {
      return;
    }

    if (status == AuthFlowStatus.needsEmailVerification) {
      context.go(AppRoutes.emailVerification);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final actionState = ref.watch(authActionProvider);

    return RoamoryScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMargin,
            AppSpacing.sm,
            AppSpacing.pageMargin,
            AppSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Üst çubuk: Geri + Roamory rozet (A04).
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: l10n.commonBack,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.explore_outlined,
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.appTitle,
                            style: textTheme.labelLarge?.copyWith(
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.accentContainer,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 14,
                          color: colors.onAccentContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.registerBadge,
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onAccentContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.registerHeadline, style: textTheme.displayLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.registerSubheadline,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (actionState.error != null) ...[
                  AuthFeedbackBanner(
                    message: actionState.error!.localizedMessage(l10n),
                    onClose: () =>
                        ref.read(authActionProvider.notifier).clearFeedback(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                // Kayıt form kartı (A04).
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: colors.outline),
                    boxShadow: [
                      BoxShadow(
                        color: colors.cardShadow,
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: l10n.registerFullNameLabel,
                        hintText: l10n.registerFullNameHint,
                        controller: _fullNameController,
                        prefixIcon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        validator: (value) {
                          if (!AuthValidators.isValidFullName(value ?? '')) {
                            return l10n.validationFullNameInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.registerEmailLabel,
                        hintText: l10n.loginEmailHint,
                        controller: _emailController,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: (value) {
                          if (!AuthValidators.isValidEmail(value ?? '')) {
                            return l10n.validationEmailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.registerPasswordLabel,
                        hintText: l10n.loginPasswordHint,
                        controller: _passwordController,
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        suffixIcon: IconButton(
                          key: const Key('register_password_visibility_toggle'),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: colors.textSecondary,
                          ),
                        ),
                        validator: (value) {
                          if (!AuthValidators.isValidPassword(value ?? '')) {
                            return l10n.validationPasswordWeak;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 15,
                            color: colors.accent,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.registerPasswordRule,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: l10n.registerConfirmPasswordLabel,
                        hintText: l10n.loginPasswordHint,
                        controller: _confirmPasswordController,
                        prefixIcon: Icons.lock_reset_rounded,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        suffixIcon: IconButton(
                          key: const Key('register_confirm_visibility_toggle'),
                          onPressed: () {
                            setState(() => _obscureConfirm = !_obscureConfirm);
                          },
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: colors.textSecondary,
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return l10n.validationPasswordMismatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _acceptedTerms = !_acceptedTerms;
                            if (_acceptedTerms) {
                              _showTermsError = false;
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              key: const Key('register_terms_checkbox'),
                              value: _acceptedTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptedTerms = value ?? false;
                                  if (_acceptedTerms) {
                                    _showTermsError = false;
                                  }
                                });
                              },
                              activeColor: colors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  l10n.registerTermsText,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_showTermsError) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.validationTermsRequired,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      PrimaryButton(
                        label: actionState.isLoading
                            ? l10n.registerSubmitting
                            : l10n.registerSubmit,
                        icon: Icons.arrow_forward_rounded,
                        isLoading: actionState.isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        l10n.registerOrDivider,
                        style: textTheme.labelMedium,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: AppSpacing.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: actionState.isLoading
                        ? null
                        : () => ref
                              .read(authActionProvider.notifier)
                              .signInWithGoogle(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: colors.surface,
                    ),
                    icon: Icon(
                      Icons.g_mobiledata_rounded,
                      size: 28,
                      color: colors.primary,
                    ),
                    label: Text(l10n.registerGoogleButton),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 16,
                          color: colors.accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.registerSecurityNote,
                          style: textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.registerHasAccount,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        l10n.registerSignInLink,
                        style: textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
