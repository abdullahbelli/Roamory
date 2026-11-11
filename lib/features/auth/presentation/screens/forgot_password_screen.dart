import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/features/auth/domain/usecases/auth_validators.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/auth/presentation/widgets/auth_feedback_banner.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Stitch referansı: A05 — Şifremi Unuttum (Forgot Password).
///
/// Kullanıcının kayıtlı e-posta adresine şifre sıfırlama bağlantısı gönderir,
/// geri sayımla yeniden gönderimi kontrol eder ve SMTP limitlerini şeffaf bildirir.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  /// Şifre sıfırlama ekranı oluşturur.
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  Timer? _cooldownTimer;
  int _secondsRemaining = 0;
  String? _sentToEmail;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _secondsRemaining = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final email = _emailController.text.trim();
    final ok = await ref
        .read(authActionProvider.notifier)
        .sendPasswordResetEmail(email);
    if (!mounted || !ok) {
      return;
    }
    setState(() => _sentToEmail = email);
    _startCooldown();
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
                // Üst çubuk: Geri + GÜVENLİ SIFIRLAMA rozeti (A05).
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
                            Icons.shield_outlined,
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.forgotBadge,
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
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
                if (_sentToEmail != null) ...[
                  AuthFeedbackBanner(
                    isInfo: true,
                    isError: false,
                    title: l10n.forgotSentBannerTitle,
                    message: l10n.forgotSentBannerBody(_sentToEmail!),
                    onClose: () => setState(() => _sentToEmail = null),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (actionState.error != null) ...[
                  AuthFeedbackBanner(
                    message: actionState.error!.localizedMessage(l10n),
                    onClose: () =>
                        ref.read(authActionProvider.notifier).clearFeedback(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.forgotHeadline, style: textTheme.displayLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.forgotDescription,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: colors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: l10n.loginEmailLabel,
                        hintText: l10n.loginEmailHint,
                        controller: _emailController,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        suffixIcon: IconButton(
                          onPressed: () => _emailController.clear(),
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: colors.textSecondary,
                          ),
                        ),
                        validator: (value) {
                          if (!AuthValidators.isValidEmail(value ?? '')) {
                            return l10n.validationEmailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.forgotEmailHelper,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PrimaryButton(
                        label: l10n.forgotSubmit,
                        icon: Icons.send_outlined,
                        isLoading: actionState.isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Tekrar gönder geri sayım kutusu (A05).
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm + 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 18,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            l10n.forgotDidNotReceive,
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed:
                            (_secondsRemaining == 0 && !actionState.isLoading)
                            ? _submit
                            : null,
                        child: Text(
                          _secondsRemaining > 0
                              ? l10n.forgotResendCooldown(_secondsRemaining)
                              : l10n.forgotResend,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // SMTP kotası şeffaflık notu (features/database.md).
                Text(
                  l10n.forgotSmtpNotice,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(l10n.forgotBackToLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
