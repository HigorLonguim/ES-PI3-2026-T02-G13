import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionStorage {
  static const String _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (_) {
      // Fallback when plugin registration is unavailable.
    }
  }

  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (_) {
      // Fallback when plugin registration is unavailable.
    }
  }
}
