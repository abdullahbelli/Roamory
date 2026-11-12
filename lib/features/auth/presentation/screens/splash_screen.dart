import 'package:flutter/material.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Stitch referansı: A01 — Açılış Ekranı (Splash).
///
/// Uygulama açıldığında mevcut oturum ve karşılama turu kontrolü sürerken
/// markanın editoryal doğa-günlük kimliğini gösterir.
class SplashScreen extends StatelessWidget {
  /// Açılış ekranı oluşturur.
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return RoamoryScaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.horizontalPagePadding,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Üst saha günlüğü rozeti (A01).
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  border: Border.all(color: colors.outline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.explore_outlined,
                      size: 16,
                      color: colors.accent,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Dar ekranlarda (320px) taşmayı önlemek için metni esnek sarıyoruz.
                    Flexible(
                      child: Text(
                        l10n.splashBadge,
                        textAlign: TextAlign.center,
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Merkez marka ikonu ve başlık grubu.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: colors.outline),
                      boxShadow: [
                        BoxShadow(
                          color: colors.floatingShadow,
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    // Marka logosu assets/images/roamory_logo.png olarak sunulur;
                    // yükleme hatasında zarif pusula ikonuna düşer.
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Image.asset(
                        'assets/images/roamory_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.explore_rounded,
                          size: 52,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.background, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.appTitle,
                style: textTheme.displayLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.splashTagline,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.splashSubtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const Spacer(),
              // Oturum kontrolü göstergesi (sonsuz animasyon yerine sade gösterge).
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.near_me_outlined, size: 16, color: colors.accent),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      l10n.splashCheckingSession,
                      textAlign: TextAlign.center,
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
