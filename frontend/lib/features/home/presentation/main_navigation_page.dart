// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/presentation/dashboard_page.dart';
import 'package:frontend/features/profile/presentation/profile_page.dart';
import 'package:frontend/features/trading_desk/presentation/trading_desk_page.dart';

import '../../../core/theme/mescla_colors.dart';
import '../data/portfolio_store.dart';
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
    PortfolioStore.instance.hydrate();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      StartupPage(onProfileTap: () => setState(() => _currentIndex = 4)),
      WalletPage(onExploreStartups: () => setState(() => _currentIndex = 0)),
      const TradingDeskPage(),
      const DashboardPage(),
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
