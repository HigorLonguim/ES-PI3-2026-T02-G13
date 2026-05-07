// Autoria: Felipe Sousa - RA: 22018160

import 'package:dio/dio.dart';

import '../auth/auth_session_storage.dart';

class JwtAuthInterceptor extends Interceptor {
  JwtAuthInterceptor(this._sessionStorage);

  final AuthSessionStorage _sessionStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _sessionStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}

Dio createAppDio({
  required String baseUrl,
  required AuthSessionStorage sessionStorage,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(JwtAuthInterceptor(sessionStorage));
  return dio;
}
