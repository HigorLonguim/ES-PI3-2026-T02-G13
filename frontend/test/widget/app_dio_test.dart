// Autoria: Felipe Sousa - RA: 22018160

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/auth/auth_session_storage.dart';
import 'package:frontend/core/network/app_dio.dart';

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

class _RequestHandlerSpy extends RequestInterceptorHandler {
  RequestOptions? nextOptions;

  @override
  void next(RequestOptions requestOptions) {
    nextOptions = requestOptions;
  }
}

class _ErrorHandlerSpy extends ErrorInterceptorHandler {
  DioException? nextError;

  @override
  void next(DioException error) {
    nextError = error;
  }
}

void main() {
  group('JwtAuthInterceptor', () {
    test('adiciona token no header Authorization', () async {
      final storage = AuthSessionStorage(
        backend: _InMemoryAuthStorageBackend(),
      );
      await storage.saveToken('token-123');

      final interceptor = JwtAuthInterceptor(storage);
      final handler = _RequestHandlerSpy();
      final options = RequestOptions(path: '/wallet');

      await interceptor.onRequest(options, handler);

      expect(handler.nextOptions?.headers['Authorization'], 'Bearer token-123');
    });

    test('dispara handler de nao autorizado quando recebe 401', () async {
      final storage = AuthSessionStorage(
        backend: _InMemoryAuthStorageBackend(),
      );
      var unauthorizedCalled = false;
      final interceptor = JwtAuthInterceptor(
        storage,
        onUnauthorized: () async {
          unauthorizedCalled = true;
        },
      );
      final handler = _ErrorHandlerSpy();
      final error = DioException(
        requestOptions: RequestOptions(path: '/wallet'),
        response: Response(
          requestOptions: RequestOptions(path: '/wallet'),
          statusCode: 401,
        ),
      );

      await interceptor.onError(error, handler);

      expect(unauthorizedCalled, isTrue);
      expect(handler.nextError, same(error));
    });
  });
}
