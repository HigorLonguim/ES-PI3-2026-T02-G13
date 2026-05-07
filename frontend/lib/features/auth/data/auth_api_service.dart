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
    String? firebaseWebApiKey,
  }) {
    final resolvedSessionStorage = sessionStorage ?? AuthSessionStorage();
    final resolvedBaseUrl = _resolveBaseUrl();
    final resolvedRegisterFunctionUrl = _resolveFunctionUrl(
      registerFunctionUrl,
      AppConfig.registerFunctionUrl,
    );
    final resolvedFirebaseWebApiKey = _resolveFirebaseWebApiKey(
      firebaseWebApiKey,
    );
    if (kDebugMode) {
      debugPrint('[AuthApiService] Base URL resolvida: $resolvedBaseUrl');
      debugPrint(
        '[AuthApiService] URL da function de cadastro: '
        '$resolvedRegisterFunctionUrl',
      );
      debugPrint(
        '[AuthApiService] Firebase Web API Key configurada: '
        '${resolvedFirebaseWebApiKey.isNotEmpty}',
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
      firebaseWebApiKey: resolvedFirebaseWebApiKey,
    );
  }

  AuthApiService._({
    required Dio dio,
    required bool ownsDio,
    required String registerFunctionUrl,
    required String firebaseWebApiKey,
  }) : _dio = dio,
       _ownsDio = ownsDio,
       _registerFunctionUrl = registerFunctionUrl,
       _firebaseWebApiKey = firebaseWebApiKey;

  final Dio _dio;
  final bool _ownsDio;
  final String _registerFunctionUrl;
  final String _firebaseWebApiKey;

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

  static String _resolveFunctionUrl(String? overrideUrl, String configuredUrl) {
    final resolvedUrl = (overrideUrl ?? configuredUrl).trim();
    if (resolvedUrl.isEmpty) {
      return '';
    }

    if (resolvedUrl.startsWith('http://') ||
        resolvedUrl.startsWith('https://')) {
      return resolvedUrl;
    }

    return 'https://$resolvedUrl';
  }

  static String _resolveFirebaseWebApiKey(String? overrideKey) {
    return (overrideKey ?? AppConfig.firebaseWebApiKey).trim();
  }

  bool get _shouldUseFirebaseAuthDirectly => _firebaseWebApiKey.isNotEmpty;

  Future<AuthResult> login({required String email, required String senha}) {
    final normalizedEmail = _normalizeEmail(email);
    if (_shouldUseFirebaseAuthDirectly) {
      return _post(
        endpoint:
            'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_firebaseWebApiKey',
        payload: {
          'email': normalizedEmail,
          'password': senha,
          'returnSecureToken': true,
        },
        successStatusCodes: {200},
        fallbackSuccessMessage: 'Login realizado',
      );
    }

    return _post(
      endpoint: '/users/login',
      payload: {'email': normalizedEmail, 'senha': senha},
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
    final normalizedEmail = _normalizeEmail(email);
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
        'email': normalizedEmail,
        'cpf': cpf,
        'telefone': telefone,
        'senha': senha,
      },
      successStatusCodes: {200},
      fallbackSuccessMessage: 'Usuario cadastrado',
    );
  }

  Future<AuthResult> recoverPassword({required String email}) {
    final normalizedEmail = _normalizeEmail(email);
    if (_shouldUseFirebaseAuthDirectly) {
      return _post(
        endpoint:
            'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$_firebaseWebApiKey',
        payload: {'requestType': 'PASSWORD_RESET', 'email': normalizedEmail},
        successStatusCodes: {200},
        fallbackSuccessMessage:
            'Se o e-mail estiver cadastrado, enviaremos as instrucoes de recuperacao.',
      );
    }

    return _post(
      endpoint: '/users/recover-password',
      payload: {'email': normalizedEmail},
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
          _readSuccessMessage(body) ??
          (successStatusCodes.contains(response.statusCode)
              ? fallbackSuccessMessage
              : 'Nao foi possivel concluir a operacao.');

      final usuario = _extractUsuario(body);
      return AuthResult(
        success: successStatusCodes.contains(response.statusCode),
        message: message,
        usuario: usuario,
        token: _extractToken(body, usuario),
      );
    } on DioException catch (error) {
      final body = _decodeBody(error.response?.data);
      final message =
          _readErrorMessage(body) ?? 'Falha de conexao com o servidor.';

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

  String? _readSuccessMessage(Map<String, dynamic> source) {
    return _readString(source, 'message') ??
        _readString(source, 'mensagem') ??
        _readString(source, 'error_description');
  }

  String? _readErrorMessage(Map<String, dynamic> source) {
    final nestedError = _readMap(source, 'error');
    final firebaseErrorCode =
        _readString(nestedError ?? const <String, dynamic>{}, 'message') ??
        _readString(source, 'error') ??
        _readString(source, 'erro') ??
        _readString(source, 'message');

    if (firebaseErrorCode == null || firebaseErrorCode.isEmpty) {
      return null;
    }

    return _mapFirebaseAuthError(firebaseErrorCode);
  }

  String _mapFirebaseAuthError(String errorCode) {
    switch (errorCode) {
      case 'INVALID_LOGIN_CREDENTIALS':
      case 'EMAIL_NOT_FOUND':
      case 'INVALID_PASSWORD':
        return 'Email ou senha invalidos.';
      case 'INVALID_EMAIL':
        return 'Email invalido.';
      case 'USER_DISABLED':
        return 'Usuario desativado.';
      case 'MISSING_EMAIL':
        return 'Email e obrigatorio.';
      default:
        return errorCode;
    }
  }

  String _normalizeEmail(String rawEmail) {
    return rawEmail.trim().replaceAll(RegExp(r'\s+'), '');
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

  Map<String, dynamic>? _extractUsuario(Map<String, dynamic> body) {
    final explicitUsuario = _readMap(body, 'usuario');
    if (explicitUsuario != null) {
      return explicitUsuario;
    }

    final email = _readString(body, 'email');
    final localId = _readString(body, 'localId');
    if (email == null && localId == null) {
      return null;
    }

    return <String, dynamic>{'id': localId, 'uid': localId, 'email': email};
  }

  String? _extractToken(
    Map<String, dynamic> body,
    Map<String, dynamic>? usuario,
  ) {
    return _readString(body, 'token') ??
        _readString(body, 'idToken') ??
        _readString(usuario ?? <String, dynamic>{}, 'token');
  }

  void dispose() {
    if (_ownsDio) {
      _dio.close();
    }
  }
}
