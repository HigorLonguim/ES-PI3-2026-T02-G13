// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';

import '../../../core/theme/mescla_colors.dart';
import '../../../core/widgets/mescla_bottom_navigation_bar.dart';
import 'profile_page.dart';
import 'startup_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const StartupPage(),
    const _NavigationPlaceholder(label: 'Carteira'),
    const _NavigationPlaceholder(label: 'Dashboard'),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MesclaColors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
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
