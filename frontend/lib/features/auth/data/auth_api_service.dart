// Autoria: Felipe Sousa - RA: 22018160

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
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
      fallbackSuccessMessage: 'Usuário cadastrado',
    );
  }

  Future<AuthResult> _post({
    required String endpoint,
    required Map<String, dynamic> payload,
    required Set<int> successStatusCodes,
    required String fallbackSuccessMessage,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      final body = _decodeBody(response.body);
      final message =
          _readString(body, 'mensagem') ??
          _readString(body, 'erro') ??
          (successStatusCodes.contains(response.statusCode)
              ? fallbackSuccessMessage
              : 'Não foi possível concluir a operação.');

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
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Falha de conexão com o servidor.',
      );
    }
  }

  Map<String, dynamic> _decodeBody(String rawBody) {
    if (rawBody.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(rawBody);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  String? _readString(Map<String, dynamic> source, String key) {
    final value = source[key];
    return value is String ? value : null;
  }

  Map<String, dynamic>? _readMap(Map<String, dynamic> source, String key) {
    final value = source[key];
    return value is Map<String, dynamic> ? value : null;
  }

  void dispose() {
    _client.close();
  }
}
