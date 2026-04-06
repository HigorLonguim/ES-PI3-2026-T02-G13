// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';
import 'package:frontend/features/profile/presentation/profile_page.dart';

import '../../../core/theme/mescla_colors.dart';
import '../../../core/widgets/mescla_bottom_navigation_bar.dart';
import 'startup_page.dart';
import 'wallet_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({this.initialIndex = 0, super.key});

  final int initialIndex;

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      StartupPage(
        onProfileTap: () => setState(() => _currentIndex = 3),
      ),
      WalletPage(
        onExploreStartups: () => setState(() => _currentIndex = 0),
      ),
      const _NavigationPlaceholder(label: 'Dashboard'),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: MesclaColors.background,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: MesclaBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _NavigationPlaceholder extends StatelessWidget {
  const _NavigationPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MesclaColors.background,
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: MesclaColors.textSecondary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
