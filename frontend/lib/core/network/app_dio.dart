// Autoria: Felipe Sousa - RA: 22018160

import 'package:dio/dio.dart';

import '../auth/auth_session_manager.dart';
import '../auth/auth_session_storage.dart';

class JwtAuthInterceptor extends Interceptor {
  JwtAuthInterceptor(
    this._sessionStorage, {
    Future<void> Function()? onUnauthorized,
  }) : _onUnauthorized = onUnauthorized;

  final AuthSessionStorage _sessionStorage;
  final Future<void> Function()? _onUnauthorized;

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

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final unauthorizedHandler =
          _onUnauthorized ??
          () => AuthSessionManager.instance.logoutAndRedirect();
      await unauthorizedHandler();
    }

    handler.next(err);
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
