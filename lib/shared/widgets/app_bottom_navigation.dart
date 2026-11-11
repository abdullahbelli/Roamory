import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_spacing.dart';

/// Roamory'nin sabit 5 ana sekmesini temsil eden yüzen alt navigasyon çubuğu.
///
/// `design.md` ve Stitch `B01` referansına göre tam hap (pill) formunda,
/// buzlu cam (frosted) arka planlı ve aktif sekme altında mikro nokta
/// göstergelidir. 6. sekme eklenmez; `Seyahatlerim` iç rota olarak açılır.
class AppBottomNavigation extends StatelessWidget {
  /// Seçili sekme indeksine göre [AppBottomNavigation] oluşturur.
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  /// Etkin sekme indeksi (`0..4`).
  final int currentIndex;

  /// Kullanıcı sekmelerden birine dokunduğunda yeni indeksi döndürür.
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = RoamoryColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    // 5 sabit destinasyon listesi yerelleştirilmiş etiketlerle kurulur.
    final items = <_NavItem>[
      _NavItem(
        label: l10n.navHome,
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
      ),
      _NavItem(
        label: l10n.navExplore,
        icon: Icons.travel_explore_outlined,
        activeIcon: Icons.travel_explore,
      ),
      _NavItem(
        label: l10n.navMap,
        icon: Icons.location_on_outlined,
        activeIcon: Icons.location_on,
      ),
      _NavItem(
        label: l10n.navCommunity,
        icon: Icons.groups_outlined,
        activeIcon: Icons.groups,
      ),
      _NavItem(
        label: l10n.navProfile,
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
      ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          0,
          AppSpacing.pageMargin,
          AppSpacing.bottomNavOffset,
        ),
        child: Container(
          height: AppSpacing.bottomNavHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            boxShadow: [
              BoxShadow(
                color: colors.floatingShadow,
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.navBarSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.7),
                  ),
                ),
                child: Row(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = index == currentIndex;
                    final fgColor = isSelected
                        ? colors.primary
                        : colors.textSecondary;

                    return Expanded(
                      child: Semantics(
                        selected: isSelected,
                        button: true,
                        label: item.label,
                        child: InkWell(
                          onTap: () => onDestinationSelected(index),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusPill,
                          ),
                          child: SizedBox(
                            height: AppSpacing.bottomNavHeight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  size: 22,
                                  color: fgColor,
                                ),
                                const SizedBox(height: 2),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: Text(
                                    item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: fgColor,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                // Aktif sekme göstergesi: 4px dairesel nokta (Stitch B01).
                                const SizedBox(height: 3),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: isSelected ? 4 : 0,
                                  height: isSelected ? 4 : 0,
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
