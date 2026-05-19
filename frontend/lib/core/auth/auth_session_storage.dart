// Autoria: Felipe Sousa - RA: 22018160
// Nome: Higor Vedovello Longuim RA: 23000291

import 'dart:convert';

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
      if (value != null) return value;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> delete({required String key}) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (_) {}
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
  static const String _userCpfKey = 'auth_user_cpf';
  static const String _userTelefoneKey = 'auth_user_telefone';

  final AuthStorageBackend _backend;

  Future<void> saveToken(String token) =>
      _backend.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _backend.read(key: _tokenKey);

  DateTime? getTokenExpiration(String token) {
    final segments = token.split('.');
    if (segments.length != 3) {
      return null;
    }

    try {
      final normalizedPayload = base64Url.normalize(segments[1]);
      final payloadBytes = base64Url.decode(normalizedPayload);
      final payloadJson = utf8.decode(payloadBytes);
      final payload = jsonDecode(payloadJson);
      if (payload is! Map<String, dynamic>) {
        return null;
      }

      final expValue = payload['exp'];
      final expSeconds = expValue is int
          ? expValue
          : int.tryParse(expValue?.toString() ?? '');
      if (expSeconds == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(
        expSeconds * 1000,
        isUtc: true,
      );
    } catch (_) {
      return null;
    }
  }

  bool isTokenExpired(
    String token, {
    DateTime? nowUtc,
    Duration clockSkew = const Duration(seconds: 30),
  }) {
    final expirationUtc = getTokenExpiration(token);
    if (expirationUtc == null) {
      return true;
    }

    final currentTimeUtc = (nowUtc ?? DateTime.now().toUtc());
    final safeExpirationUtc = expirationUtc.subtract(clockSkew);
    return !currentTimeUtc.isBefore(safeExpirationUtc);
  }

  Future<void> saveUserProfile({
    required String nome,
    required String email,
    String? userId,
    String? cpf,
    String? telefone,
  }) async {
    await _backend.write(key: _userNameKey, value: nome);
    await _backend.write(key: _userEmailKey, value: email);
    if (userId != null && userId.trim().isNotEmpty) {
      await _backend.write(key: _userIdKey, value: userId.trim());
    }
    if (cpf != null && cpf.trim().isNotEmpty) {
      await _backend.write(key: _userCpfKey, value: cpf.trim());
    }
    if (telefone != null && telefone.trim().isNotEmpty) {
      await _backend.write(key: _userTelefoneKey, value: telefone.trim());
    }
  }

  Future<String?> getUserName() => _backend.read(key: _userNameKey);
  Future<String?> getUserEmail() => _backend.read(key: _userEmailKey);
  Future<String?> getUserId() => _backend.read(key: _userIdKey);
  Future<String?> getUserCpf() => _backend.read(key: _userCpfKey);
  Future<String?> getUserTelefone() => _backend.read(key: _userTelefoneKey);

  Future<void> saveUserId(String userId) =>
      _backend.write(key: _userIdKey, value: userId);

  Future<void> clearToken() async {
    await _backend.delete(key: _tokenKey);
    await _backend.delete(key: _userNameKey);
    await _backend.delete(key: _userEmailKey);
    await _backend.delete(key: _userIdKey);
    await _backend.delete(key: _userCpfKey);
    await _backend.delete(key: _userTelefoneKey);
  }
}
