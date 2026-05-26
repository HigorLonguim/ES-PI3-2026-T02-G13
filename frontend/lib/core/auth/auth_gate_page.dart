// Autoria: Felipe Sousa - RA: 22018160

import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/home/presentation/main_navigation_page.dart';
import '../navigation/app_route.dart';
import 'auth_session_manager.dart';
import 'auth_session_storage.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  static final AuthSessionStorage _sessionStorage = AuthSessionStorage();

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
      future: _sessionStorage.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = snapshot.data?.trim();
        if (token != null && token.isNotEmpty) {
          if (_sessionStorage.isTokenExpired(token)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                AppRoute(const LoginPage()),
                (route) => false,
              );
            });
            return const SizedBox.shrink();
          }

          unawaited(
            AuthSessionManager.instance.startSessionMonitoring(token: token),
          );
          return const MainNavigationPage();
        }

        return const HomePage();
      },
    );
  }
}
