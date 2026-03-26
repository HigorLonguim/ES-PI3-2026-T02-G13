// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';

import '../theme/mescla_colors.dart';

class MesclaBottomNavigationBar extends StatelessWidget {
  const MesclaBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = <_NavBarItemData>[
      _NavBarItemData(
        label: 'Início',
        activeIcon: Icons.home_rounded,
        inactiveIcon: Icons.home_outlined,
      ),
      _NavBarItemData(
        label: 'Carteira',
        activeIcon: Icons.account_balance_wallet_rounded,
        inactiveIcon: Icons.account_balance_wallet_outlined,
      ),
      _NavBarItemData(
        label: 'Dashboard',
        activeIcon: Icons.show_chart_rounded,
        inactiveIcon: Icons.show_chart_rounded,
      ),
      _NavBarItemData(
        label: 'Perfil',
        activeIcon: Icons.person_rounded,
        inactiveIcon: Icons.person_outline_rounded,
      ),
    ];

    return Container(
      height: 85,
      padding: const EdgeInsets.fromLTRB(24, 13, 24, 8),
      decoration: const BoxDecoration(
        color: MesclaColors.surface,
        border: Border(top: BorderSide(color: MesclaColors.border, width: 1.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final isActive = index == currentIndex;
          final item = items[index];

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isActive
                          ? MesclaColors.navActiveSurface
                          : Colors.transparent,
                    ),
                    child: Icon(
                      isActive ? item.activeIcon : item.inactiveIcon,
                      size: 24,
                      color: isActive
                          ? MesclaColors.navActive
                          : MesclaColors.navInactive,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? MesclaColors.navActive
                          : MesclaColors.navInactive,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavBarItemData {
  const _NavBarItemData({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });

  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
}
