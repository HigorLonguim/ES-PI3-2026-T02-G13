// Autoria: Felipe Sousa - RA: 22018160

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/auth/auth_session_storage.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/app_dio.dart';

class AuthResult {
  const AuthResult({
    required this.success,
    required this.message,
    this.usuario,
    this.token,
  });

  final bool success;
  final String message;
  final Map<String, dynamic>? usuario;
  final String? token;
}

class AuthApiService {
  factory AuthApiService({Dio? dio, AuthSessionStorage? sessionStorage}) {
    final resolvedSessionStorage = sessionStorage ?? AuthSessionStorage();
    final resolvedDio =
        dio ??
        createAppDio(
          baseUrl: _resolveBaseUrl(),
          sessionStorage: resolvedSessionStorage,
        );

    return AuthApiService._(dio: resolvedDio, ownsDio: dio == null);
  }

  AuthApiService._({required Dio dio, required bool ownsDio})
    : _dio = dio,
      _ownsDio = ownsDio;

  final Dio _dio;
  final bool _ownsDio;

  static String _resolveBaseUrl() {
    final configuredBaseUrl = AppConfig.authApiBaseUrl.trim();
    if (configuredBaseUrl.isNotEmpty) {
      return configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://${AppConfig.webHostName}:8080';
    }

    final deviceHostIp = AppConfig.deviceHostIp.trim();
    if (deviceHostIp.isNotEmpty) {
      return 'http://$deviceHostIp:8080';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://localhost:8080';
  }

  Future<AuthResult> login({required String email, required String senha}) {
    return _post(
      endpoint: '/users/login',
      payload: {'email': email, 'senha': senha},
      successStatusCodes: {200},
      fallbackSuccessMessage: 'Login realizado',
    );
  }

  Future<AuthResult> register({
    required String nome,
    required String email,
    required String senha,
  }) {
    return _post(
      endpoint: '/users/register',
      payload: {'nome': nome, 'email': email, 'senha': senha},
      successStatusCodes: {201},
      fallbackSuccessMessage: 'Usuario cadastrado',
    );
  }

  Future<AuthResult> recoverPassword({required String email}) {
    return _post(
      endpoint: '/users/recover-password',
      payload: {'email': email},
      successStatusCodes: {200, 202},
      fallbackSuccessMessage:
          'Se o e-mail estiver cadastrado, enviaremos as instrucoes de recuperacao.',
    );
  }

  Future<AuthResult> _post({
    required String endpoint,
    required Map<String, dynamic> payload,
    required Set<int> successStatusCodes,
    required String fallbackSuccessMessage,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: payload);
      final body = _decodeBody(response.data);
      final message =
          _readString(body, 'mensagem') ??
          _readString(body, 'erro') ??
          (successStatusCodes.contains(response.statusCode)
              ? fallbackSuccessMessage
              : 'Nao foi possivel concluir a operacao.');

      return AuthResult(
        success: successStatusCodes.contains(response.statusCode),
        message: message,
        usuario: _readMap(body, 'usuario'),
        token:
            _readString(body, 'token') ??
            _readString(
              _readMap(body, 'usuario') ?? <String, dynamic>{},
              'token',
            ),
      );
    } on DioException catch (error) {
      final body = _decodeBody(error.response?.data);
      final message =
          _readString(body, 'mensagem') ??
          _readString(body, 'erro') ??
          'Falha de conexao com o servidor.';

      return AuthResult(
        success: false,
        message: message,
        usuario: _readMap(body, 'usuario'),
      );
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Falha de conexao com o servidor.',
      );
    }
  }

  Map<String, dynamic> _decodeBody(dynamic rawBody) {
    if (rawBody is Map<String, dynamic>) {
      return rawBody;
    }

    if (rawBody is Map) {
      return Map<String, dynamic>.from(rawBody);
    }

    return <String, dynamic>{};
  }

  String? _readString(Map<String, dynamic> source, String key) {
    final value = source[key];
    return value is String ? value : null;
  }

  Map<String, dynamic>? _readMap(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  void dispose() {
    if (_ownsDio) {
      _dio.close();
    }
  }
}
