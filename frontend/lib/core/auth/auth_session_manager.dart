// Autoria: Felipe Sousa - RA: 22018160

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../features/auth/presentation/login_page.dart';
import '../navigation/app_route.dart';
import 'auth_session_storage.dart';

class AuthSessionManager {
  AuthSessionManager._();

  static final AuthSessionManager instance = AuthSessionManager._();

  final AuthSessionStorage _sessionStorage = AuthSessionStorage();
  Timer? _expirationTimer;
  bool _isLoggingOut = false;

  Future<void> startSessionMonitoring({String? token}) async {
    _expirationTimer?.cancel();

    final resolvedToken = token ?? await _sessionStorage.getToken();
    if (resolvedToken == null || resolvedToken.trim().isEmpty) {
      return;
    }

    if (_sessionStorage.isTokenExpired(resolvedToken)) {
      await logoutAndRedirect();
      return;
    }

    final expirationUtc = _sessionStorage.getTokenExpiration(resolvedToken);
    if (expirationUtc == null) {
      await logoutAndRedirect();
      return;
    }

    final nowUtc = DateTime.now().toUtc();
    final timeUntilExpiration = expirationUtc.difference(nowUtc);
    _expirationTimer = Timer(timeUntilExpiration, () async {
      await logoutAndRedirect();
    });
  }

  void stopSessionMonitoring() {
    _expirationTimer?.cancel();
    _expirationTimer = null;
  }

  Future<void> logoutAndRedirect() async {
    if (_isLoggingOut) {
      return;
    }
    _isLoggingOut = true;
    stopSessionMonitoring();
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseAuth.instance.signOut();
      }
      await _sessionStorage.clearToken();

      final navigatorState = AppRoute.navigatorKey.currentState;
      if (navigatorState == null) {
        return;
      }

      navigatorState.pushAndRemoveUntil(
        AppRoute(const LoginPage()),
        (route) => false,
      );
    } finally {
      _isLoggingOut = false;
    }
  }
}
