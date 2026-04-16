// Autoria: Felipe Sousa - RA: 22018160

import 'dart:convert';

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
  factory AuthApiService({
    Dio? dio,
    AuthSessionStorage? sessionStorage,
    String? registerFunctionUrl,
  }) {
    final resolvedSessionStorage = sessionStorage ?? AuthSessionStorage();
    final resolvedBaseUrl = _resolveBaseUrl();
    final resolvedRegisterFunctionUrl = _resolveRegisterFunctionUrl(
      registerFunctionUrl,
    );
    if (kDebugMode) {
      debugPrint('[AuthApiService] Base URL resolvida: $resolvedBaseUrl');
      debugPrint(
        '[AuthApiService] URL da function de cadastro: '
        '$resolvedRegisterFunctionUrl',
      );
    }
    final resolvedDio =
        dio ??
        createAppDio(
          baseUrl: resolvedBaseUrl,
          sessionStorage: resolvedSessionStorage,
        );

    return AuthApiService._(
      dio: resolvedDio,
      ownsDio: dio == null,
      registerFunctionUrl: resolvedRegisterFunctionUrl,
    );
  }

  AuthApiService._({
    required Dio dio,
    required bool ownsDio,
    required String registerFunctionUrl,
  }) : _dio = dio,
       _ownsDio = ownsDio,
       _registerFunctionUrl = registerFunctionUrl;

  final Dio _dio;
  final bool _ownsDio;
  final String _registerFunctionUrl;

  static String _resolveBaseUrl() {
    final configuredApiUrl = AppConfig.apiUrl.trim();
    if (configuredApiUrl.isNotEmpty) {
      return _normalizeApiUrl(configuredApiUrl);
    }

    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://localhost:8080';
  }

  static String _normalizeApiUrl(String rawApiUrl) {
    if (rawApiUrl.startsWith('http://') || rawApiUrl.startsWith('https://')) {
      return rawApiUrl;
    }

    return 'http://$rawApiUrl';
  }

  static String _resolveRegisterFunctionUrl(String? overrideUrl) {
    final configuredUrl = (overrideUrl ?? AppConfig.registerFunctionUrl).trim();
    if (configuredUrl.isEmpty) {
      return '';
    }

    if (configuredUrl.startsWith('http://') ||
        configuredUrl.startsWith('https://')) {
      return configuredUrl;
    }

    return 'https://$configuredUrl';
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
    required String cpf,
    required String telefone,
    required String senha,
  }) {
    if (_registerFunctionUrl.isEmpty) {
      return Future.value(
        const AuthResult(
          success: false,
          message: 'Cadastro indisponivel. Configure REGISTER_FUNCTION_URL.',
        ),
      );
    }

    return _post(
      endpoint: _registerFunctionUrl,
      payload: {
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'telefone': telefone,
        'senha': senha,
      },
      successStatusCodes: {200},
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
          _readString(body, 'message') ??
          _readString(body, 'mensagem') ??
          _readString(body, 'erro') ??
          _readString(body, 'error') ??
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
          _readString(body, 'message') ??
          _readString(body, 'mensagem') ??
          _readString(body, 'erro') ??
          _readString(body, 'error') ??
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

    if (rawBody is String) {
      final trimmedBody = rawBody.trim();
      if (trimmedBody.isEmpty) {
        return <String, dynamic>{};
      }

      try {
        final decoded = jsonDecode(trimmedBody);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return <String, dynamic>{'message': trimmedBody};
      }
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
