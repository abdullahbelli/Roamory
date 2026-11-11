import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/auth/domain/usecases/auth_validators.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/auth/presentation/widgets/auth_feedback_banner.dart';
import 'package:roamory/features/auth/presentation/widgets/language_toggle_pill.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Stitch referansı: A03 — Giriş Yap (Login).
///
/// E-posta/şifre girişi, Google OAuth tetikleme, şifre görünürlüğü,
/// şifre sıfırlama bağlantısı ve kayıt ekranına geçiş akışlarını sunar.
class LoginScreen extends ConsumerStatefulWidget {
  /// Giriş ekranı oluşturur.
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref
        .read(authActionProvider.notifier)
        .signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    await ref.read(authActionProvider.notifier).signInWithGoogle();
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
                // Üst çubuk: Geri + Roamory logosu + TR/EN dil anahtarı (A03).
                Row(
                  children: [
                    if (context.canPop())
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: l10n.commonBack,
                      )
                    else
                      const SizedBox(width: 12),
                    Icon(
                      Icons.explore_rounded,
                      color: colors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      l10n.appTitle,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const LanguageTogglePill(),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Başlık kartı (A03).
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: colors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
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
                              size: 14,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.loginBadge,
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(l10n.loginHeadline, style: textTheme.displayLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.loginSubheadline,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
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
                // Google OAuth butonu (A03).
                SizedBox(
                  height: AppSpacing.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: actionState.isLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: colors.surface,
                    ),
                    icon: Icon(
                      Icons.g_mobiledata_rounded,
                      size: 28,
                      color: colors.primary,
                    ),
                    label: Text(l10n.loginGoogleButton),
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
                        l10n.loginOrDivider,
                        style: textTheme.labelMedium,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l10n.loginEmailLabel,
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
                  label: l10n.loginPasswordLabel,
                  hintText: l10n.loginPasswordHint,
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _submit(),
                  suffixIcon: IconButton(
                    key: const Key('login_password_visibility_toggle'),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: colors.textSecondary,
                    ),
                  ),
                  validator: (value) {
                    if ((value ?? '').isEmpty) {
                      return l10n.errorValidationMessage;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                // Beni hatırla + Şifremi unuttum satırı.
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? true);
                      },
                      activeColor: colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l10n.loginRememberMe,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: actionState.isLoading
                          ? null
                          : () {
                              ref
                                  .read(authActionProvider.notifier)
                                  .clearFeedback();
                              context.push(AppRoutes.forgotPassword);
                            },
                      child: Text(
                        l10n.loginForgotPassword,
                        style: textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: actionState.isLoading
                      ? l10n.loginSubmitting
                      : l10n.loginSubmit,
                  icon: Icons.arrow_forward_rounded,
                  isLoading: actionState.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Dijital pasaport bilgi kartı (sahte sayısal metrik içermez).
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: colors.outline),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.accentContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_activity_outlined,
                          color: colors.onAccentContainer,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.loginInfoTitle,
                              style: textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.loginInfoSubtitle,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.loginNoAccount,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: actionState.isLoading
                          ? null
                          : () {
                              ref
                                  .read(authActionProvider.notifier)
                                  .clearFeedback();
                              context.push(AppRoutes.register);
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.loginCreateAccountLink,
                            style: textTheme.labelLarge?.copyWith(
                              color: colors.primary,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                        ],
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
