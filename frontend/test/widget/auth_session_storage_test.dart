// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/auth/auth_session_storage.dart';

class _InMemoryAuthStorageBackend implements AuthStorageBackend {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _values[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }
}

void main() {
  group('AuthSessionStorage', () {
    test('salva e recupera token', () async {
      final storage = AuthSessionStorage(
        backend: _InMemoryAuthStorageBackend(),
      );

      await storage.saveToken('token-123');

      expect(await storage.getToken(), 'token-123');
    });

    test('salva e recupera perfil do usuario', () async {
      final storage = AuthSessionStorage(
        backend: _InMemoryAuthStorageBackend(),
      );

      await storage.saveUserProfile(nome: 'Felipe', email: 'felipe@mescla.dev');

      expect(await storage.getUserName(), 'Felipe');
      expect(await storage.getUserEmail(), 'felipe@mescla.dev');
    });

    test('limpa token e dados de perfil', () async {
      final storage = AuthSessionStorage(
        backend: _InMemoryAuthStorageBackend(),
      );

      await storage.saveToken('token-123');
      await storage.saveUserProfile(nome: 'Felipe', email: 'felipe@mescla.dev');

      await storage.clearToken();

      expect(await storage.getToken(), isNull);
      expect(await storage.getUserName(), isNull);
      expect(await storage.getUserEmail(), isNull);
    });
  });
}
