import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';

/// `A02` ve `A03` ekranlarının üst köşesinde yer alan `TR | EN` dil anahtarı.
///
/// Dokunulduğunda [appPreferencesProvider] üzerinden uygulama dilini anında
/// değiştirir ve seçimi yerel depolamaya kaydeder.
class LanguageTogglePill extends ConsumerWidget {
  /// Dil seçici hap widget'ı oluşturur.
  const LanguageTogglePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final preferred =
        ref.watch(appPreferencesProvider).locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final isTr = preferred != 'en';

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangOption(
            code: 'TR',
            selected: isTr,
            colors: colors,
            textTheme: textTheme,
            onTap: () => ref
                .read(appPreferencesProvider.notifier)
                .setLocale(const Locale('tr')),
          ),
          _LangOption(
            code: 'EN',
            selected: !isTr,
            colors: colors,
            textTheme: textTheme,
            onTap: () => ref
                .read(appPreferencesProvider.notifier)
                .setLocale(const Locale('en')),
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.code,
    required this.selected,
    required this.colors,
    required this.textTheme,
    required this.onTap,
  });

  final String code;
  final bool selected;
  final RoamoryColors colors;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: code,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Text(
            code,
            style: textTheme.labelMedium?.copyWith(
              color: selected ? colors.onPrimary : colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
