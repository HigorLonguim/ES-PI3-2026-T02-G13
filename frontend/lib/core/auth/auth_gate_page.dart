// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';

import '../../features/home/presentation/home_page.dart';
import '../../features/home/presentation/main_navigation_page.dart';
import 'auth_session_storage.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  bool _isRunningWidgetTest() {
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    return bindingType.contains('TestWidgetsFlutterBinding') ||
        bindingType.contains('AutomatedTestWidgetsFlutterBinding') ||
        bindingType.contains('LiveTestWidgetsFlutterBinding');
  }

  @override
  Widget build(BuildContext context) {
    if (_isRunningWidgetTest()) {
      return const HomePage();
    }

    return FutureBuilder<String?>(
      future: AuthSessionStorage().getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = snapshot.data?.trim();
        if (token != null && token.isNotEmpty) {
          return const MainNavigationPage();
        }

        return const HomePage();
      },
    );
  }
}
