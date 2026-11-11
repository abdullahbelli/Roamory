import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
import 'package:roamory/features/auth/presentation/widgets/language_toggle_pill.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Stitch referansı: A02 — Karşılama Turu (Onboarding).
///
/// Yalnızca ilk açılışta 3 adımlı tanıtım kartlarını sunar; kullanıcı
/// `Atla` veya son adımda `Başla` butonuna bastığında tercihi kalıcı olarak
/// kaydedip giriş ekranına yönlendirir.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Karşılama turu ekranı oluşturur.
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding({required String targetRoute}) async {
    await ref.read(appPreferencesProvider.notifier).completeOnboarding();
    if (!mounted) {
      return;
    }
    context.go(targetRoute);
  }

  Future<void> _handlePrimaryAction() async {
    if (_currentPage < 2) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await _finishOnboarding(targetRoute: AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final steps = [
      _OnboardingStepData(
        tag: l10n.onboardingTagExplore,
        title: l10n.onboardingStep1Title,
        body: l10n.onboardingStep1Body,
        cardTitle: l10n.onboardingStep1CardTitle,
        cardSubtitle: l10n.onboardingStep1CardSubtitle,
        icon: Icons.landscape_rounded,
      ),
      _OnboardingStepData(
        tag: l10n.onboardingTagMemories,
        title: l10n.onboardingStep2Title,
        body: l10n.onboardingStep2Body,
        cardTitle: l10n.onboardingStep2CardTitle,
        cardSubtitle: l10n.onboardingStep2CardSubtitle,
        icon: Icons.auto_stories_rounded,
      ),
      _OnboardingStepData(
        tag: l10n.onboardingTagRoutes,
        title: l10n.onboardingStep3Title,
        body: l10n.onboardingStep3Body,
        cardTitle: l10n.onboardingStep3CardTitle,
        cardSubtitle: l10n.onboardingStep3CardSubtitle,
        icon: Icons.route_rounded,
      ),
    ];

    final currentStep = steps[_currentPage];

    return RoamoryScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Üst çubuk: TR/EN dil değiştirici + Atla (A02).
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                AppSpacing.sm,
                AppSpacing.pageMargin,
                AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const LanguageTogglePill(),
                  TextButton(
                    onPressed: () =>
                        _finishOnboarding(targetRoute: AppRoutes.login),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.onboardingSkip,
                          style: textTheme.labelLarge?.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: colors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 3 adımlı kaydırılabilir kart alanı.
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: steps.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return SingleChildScrollView(
                    padding: AppSpacing.horizontalPagePadding,
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.xs),
                        _OnboardingHeroCard(
                          step: step,
                          colors: colors,
                          textTheme: textTheme,
                          appTitle: l10n.appTitle,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // 3 durum rozeti (Keşfet, Anılar, Rotalar).
                        Wrap(
                          spacing: AppSpacing.sm,
                          alignment: WrapAlignment.center,
                          children: List.generate(steps.length, (chipIndex) {
                            final isCurrent = chipIndex == _currentPage;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? colors.primary
                                    : colors.surfaceVariant,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              child: Text(
                                steps[chipIndex].tag,
                                style: textTheme.labelMedium?.copyWith(
                                  color: isCurrent
                                      ? colors.onPrimary
                                      : colors.textSecondary,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          step.body,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Alt ilerleme noktaları + Devam Et/Başla CTA + Giriş Yap linki.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                AppSpacing.sm,
                AppSpacing.pageMargin,
                AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(steps.length, (index) {
                      final active = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 22 : 7,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active ? colors.primary : colors.outline,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusPill,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: _currentPage < 2
                        ? l10n.onboardingContinue
                        : l10n.onboardingStart,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _handlePrimaryAction,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        currentStep.tag.isNotEmpty
                            ? l10n.onboardingAlreadyHaveAccount
                            : '',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            _finishOnboarding(targetRoute: AppRoutes.login),
                        child: Text(
                          l10n.onboardingSignInLink,
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
          ],
        ),
      ),
    );
  }
}

class _OnboardingHeroCard extends StatelessWidget {
  const _OnboardingHeroCard({
    required this.step,
    required this.colors,
    required this.textTheme,
    required this.appTitle,
  });

  final _OnboardingStepData step;
  final RoamoryColors colors;
  final TextTheme textTheme;
  final String appTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg + 4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: 0.78),
            colors.textPrimary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.floatingShadow,
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _HeroBadge(
                icon: Icons.explore_outlined,
                label: step.tag.toUpperCase(),
                colors: colors,
                textTheme: textTheme,
              ),
              _HeroBadge(
                icon: Icons.menu_book_outlined,
                label: appTitle,
                colors: colors,
                textTheme: textTheme,
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: Icon(
              step.icon,
              size: 84,
              color: colors.onPrimary.withValues(alpha: 0.28),
            ),
          ),
          const Spacer(),
          // Alt buzlu özet kartı (A02 PNG tasarımıyla uyumlu).
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(step.icon, color: colors.primary, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.cardSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.accentContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.north_east_rounded,
                    size: 16,
                    color: colors.onAccentContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.icon,
    required this.label,
    required this.colors,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final RoamoryColors colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStepData {
  const _OnboardingStepData({
    required this.tag,
    required this.title,
    required this.body,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.icon,
  });

  final String tag;
  final String title;
  final String body;
  final String cardTitle;
  final String cardSubtitle;
  final IconData icon;
}
