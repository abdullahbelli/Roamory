import 'package:flutter/material.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';

/// İçerik yüklenirken Stitch `S02` referansına uygun iskelet kartlar gösterir.
///
/// Sürekli tekrarlayan animasyonlar yerine hafif statik veya kontrollü yer tutucu
/// blokları kullanarak performans ve widget test kararlılığını korur.
class LoadingSkeleton extends StatelessWidget {
  /// İskelet yükleme listesi oluşturur.
  const LoadingSkeleton({
    super.key,
    this.itemCount = 3,
    this.showMediaPlaceholder = true,
  });

  /// Gösterilecek iskelet kart sayısı.
  final int itemCount;

  /// Kart içinde 16:9 görsel yer tutucu kutusu gösterilip gösterilmeyeceği.
  final bool showMediaPlaceholder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);

    return Semantics(
      label: l10n.commonLoading,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.md,
          AppSpacing.pageMargin,
          AppSpacing.bottomNavHeight + AppSpacing.xl,
        ),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          return Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SkeletonBox(
                      width: 36,
                      height: 36,
                      radius: AppSpacing.radiusPill,
                      color: colors.surfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBox(
                            width: 140,
                            height: 12,
                            color: colors.surfaceVariant,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          _SkeletonBox(
                            width: 90,
                            height: 10,
                            color: colors.surfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (showMediaPlaceholder) ...[
                  const SizedBox(height: AppSpacing.md),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _SkeletonBox(
                      width: double.infinity,
                      height: double.infinity,
                      radius: AppSpacing.radiusMd,
                      color: colors.surfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _SkeletonBox(
                  width: double.infinity,
                  height: 14,
                  color: colors.surfaceVariant,
                ),
                const SizedBox(height: AppSpacing.xs),
                _SkeletonBox(
                  width: 210,
                  height: 12,
                  color: colors.surfaceVariant,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.color,
    this.radius = AppSpacing.radiusSm,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Veri bulunamadığında Stitch `S01` referansına uygun boş durum gösterir.
///
/// Sahte içerik veya şişirilmiş sayaç üretmek yerine kullanıcıyı net bir aksiyona
/// yönlendirir.
class EmptyState extends StatelessWidget {
  /// Boş durum bileşeni oluşturur.
  const EmptyState({
    super.key,
    this.icon = Icons.explore_outlined,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  /// Merkezde gösterilecek ikon.
  final IconData icon;

  /// Başlık metni; verilmezse yerelleştirilmiş varsayılan başlık kullanılır.
  final String? title;

  /// Açıklama metni; verilmezse yerelleştirilmiş varsayılan mesaj kullanılır.
  final String? message;

  /// İsteğe bağlı çağrı butonu etiketi.
  final String? actionLabel;

  /// Çağrı butonu aksiyonu.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageMargin,
          vertical: AppSpacing.xl,
        ),
        child: Container(
          width: double.infinity,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: colors.primary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title ?? l10n.emptyDefaultTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message ?? l10n.emptyDefaultMessage,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Ağ veya sunucu hatasında Stitch `S03` referansına uygun hata ekranı gösterir.
///
/// Verilen [exception] nesnesini [AppLocalizations] aracılığıyla güvenli bir
/// kullanıcı mesajına çevirir ve varsa [onRetry] ile yeniden deneme sunar.
class ErrorState extends StatelessWidget {
  /// Hata durumu bileşeni oluşturur.
  const ErrorState({
    super.key,
    this.exception,
    this.title,
    this.message,
    this.onRetry,
  });

  /// Yerelleştirilmiş mesaj türetmek için domain hatası.
  final AppException? exception;

  /// Özel başlık; verilmezse hata türüne göre seçilir.
  final String? title;

  /// Özel açıklama; verilmezse [exception] veya genel hata mesajı gösterilir.
  final String? message;

  /// Tekrar dene aksiyonu.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final isNetwork = exception is NetworkAppException;
    final resolvedTitle =
        title ?? (isNetwork ? l10n.errorNetworkTitle : l10n.errorGenericTitle);
    final resolvedMessage =
        message ??
        exception?.localizedMessage(l10n) ??
        l10n.errorGenericMessage;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageMargin,
          vertical: AppSpacing.xl,
        ),
        child: Container(
          width: double.infinity,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNetwork ? Icons.wifi_off_rounded : Icons.error_outline,
                  size: 30,
                  color: colors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                resolvedTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                resolvedMessage,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: l10n.commonRetry,
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
