import 'dart:async';

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
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Stitch referansı: A06 — E-posta Doğrulama (Email Verification).
///
/// Kayıt sonrası kullanıcının 6 haneli OTP kodunu girmesini veya e-posta
/// bağlantısını onayladıktan sonra oturumu yenileyerek devam etmesini sağlar.
class EmailVerificationScreen extends ConsumerStatefulWidget {
  /// E-posta doğrulama ekranı oluşturur.
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final _otpController = TextEditingController();
  Timer? _resendTimer;
  int _cooldownSeconds = 0;
  String? _otpValidationError;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _resendTimer?.cancel();
    setState(() => _cooldownSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  Future<void> _verifyOrCheck(String email) async {
    FocusScope.of(context).unfocus();
    final code = _otpController.text.trim();

    if (code.isNotEmpty) {
      if (!AuthValidators.isValidOtpCode(code)) {
        setState(
          () =>
              _otpValidationError = AppLocalizations.of(context)
                  .validationOtpInvalid,
        );
        return;
      }
      setState(() => _otpValidationError = null);
      await ref
          .read(authActionProvider.notifier)
          .verifyEmailOtp(email: email, token: code);
      return;
    }

    setState(() => _otpValidationError = null);
    await ref.read(authActionProvider.notifier).checkEmailVerification();
  }

  Future<void> _resend(String email) async {
    if (email.isEmpty) {
      return;
    }
    final ok = await ref
        .read(authActionProvider.notifier)
        .resendVerificationEmail(email);
    if (mounted && ok) {
      _startCooldown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final sessionState = ref.watch(authControllerProvider);
    final actionState = ref.watch(authActionProvider);
    final email =
        sessionState.pendingVerificationEmail ?? sessionState.user?.email ?? '';

    return RoamoryScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMargin,
            AppSpacing.sm,
            AppSpacing.pageMargin,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst adım rozeti ve geri butonu (A06).
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      ref
                          .read(authControllerProvider.notifier)
                          .resetPendingVerification();
                      context.go(AppRoutes.login);
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: l10n.commonBack,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.verifyStepBadge,
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.textPrimary,
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
              const SizedBox(height: AppSpacing.lg),
              // Zarf illüstrasyon dairesi (A06).
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        size: 42,
                        color: colors.primary,
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: colors.accentContainer,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.background,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.verified_outlined,
                          size: 18,
                          color: colors.onAccentContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.verifyHeadline,
                textAlign: TextAlign.center,
                style: textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.verifyDescription,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (actionState.error != null) ...[
                AuthFeedbackBanner(
                  message: actionState.error!.localizedMessage(l10n),
                  onClose: () =>
                      ref.read(authActionProvider.notifier).clearFeedback(),
                ),
                const SizedBox(height: AppSpacing.md),
              ] else if (actionState.infoMessage == 'not_verified_yet') ...[
                AuthFeedbackBanner(
                  isInfo: true,
                  isError: false,
                  message: l10n.verifyNotConfirmedYet,
                  onClose: () =>
                      ref.read(authActionProvider.notifier).clearFeedback(),
                ),
                const SizedBox(height: AppSpacing.md),
              ] else if (actionState.success ==
                  AuthActionSuccess.verificationResent) ...[
                AuthFeedbackBanner(
                  isError: false,
                  message: l10n.verifyResentSuccess,
                  onClose: () =>
                      ref.read(authActionProvider.notifier).clearFeedback(),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              // Gönderilen e-posta adresi kartı (A06).
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: colors.outline),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.alternate_email_rounded,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.verifySentAddressLabel,
                            style: textTheme.labelSmall,
                          ),
                          Text(
                            email.isEmpty ? l10n.loginEmailHint : email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ref
                            .read(authControllerProvider.notifier)
                            .resetPendingVerification();
                        context.go(AppRoutes.register);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(l10n.verifyChangeEmail),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.verifyCodeLabel, style: textTheme.labelLarge),
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.verifyEncryptedBadge,
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: l10n.verifyCodeLabel,
                hintText: '• • • • • •',
                controller: _otpController,
                errorText: _otpValidationError,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.pin_outlined,
                onFieldSubmitted: (_) => _verifyOrCheck(email),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: l10n.verifyCheckButton,
                icon: Icons.arrow_forward_rounded,
                isLoading: actionState.isLoading,
                onPressed: () => _verifyOrCheck(email),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.verifyNoCodePrompt,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: (_cooldownSeconds == 0 && !actionState.isLoading)
                        ? () => _resend(email)
                        : null,
                    child: Text(
                      _cooldownSeconds > 0
                          ? '${l10n.verifyResendButton} (0:${_cooldownSeconds.toString().padLeft(2, '0')})'
                          : l10n.verifyResendButton,
                    ),
                  ),
                ],
              ),
              Text(
                l10n.verifySpamHint,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton.icon(
                onPressed: () {
                  ref
                      .read(authControllerProvider.notifier)
                      .resetPendingVerification();
                  context.go(AppRoutes.login);
                },
                icon: const Icon(Icons.chevron_left_rounded),
                label: Text(l10n.verifyBackToLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
