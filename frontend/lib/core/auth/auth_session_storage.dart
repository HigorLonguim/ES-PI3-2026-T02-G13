// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthStorageBackend {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
}

class CompositeAuthStorageBackend implements AuthStorageBackend {
  CompositeAuthStorageBackend({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return;
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }

  @override
  Future<String?> read({required String key}) async {
    try {
      final value = await _secureStorage.read(key: key);
      if (value != null) {
        return value;
      }
    } catch (_) {
      // Fall back to SharedPreferences when secure storage is unavailable.
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> delete({required String key}) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (_) {
      // Fall back to SharedPreferences when secure storage is unavailable.
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}

class AuthSessionStorage {
  AuthSessionStorage({AuthStorageBackend? backend})
    : _backend = backend ?? CompositeAuthStorageBackend();

  static const String _tokenKey = 'auth_token';
  static const String _userNameKey = 'auth_user_name';
  static const String _userEmailKey = 'auth_user_email';
  static const String _userIdKey = 'auth_user_id';

  final AuthStorageBackend _backend;

  Future<void> saveToken(String token) {
    return _backend.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() {
    return _backend.read(key: _tokenKey);
  }

  Future<void> saveUserProfile({
    required String nome,
    required String email,
    String? userId,
  }) async {
    await _backend.write(key: _userNameKey, value: nome);
    await _backend.write(key: _userEmailKey, value: email);
    if (userId != null && userId.trim().isNotEmpty) {
      await _backend.write(key: _userIdKey, value: userId.trim());
    }
  }

  Future<String?> getUserName() {
    return _backend.read(key: _userNameKey);
  }

  Future<String?> getUserEmail() {
    return _backend.read(key: _userEmailKey);
  }

  Future<void> saveUserId(String userId) {
    return _backend.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() {
    return _backend.read(key: _userIdKey);
  }

  Future<void> clearToken() async {
    await _backend.delete(key: _tokenKey);
    await _backend.delete(key: _userNameKey);
    await _backend.delete(key: _userEmailKey);
    await _backend.delete(key: _userIdKey);
  }
}
