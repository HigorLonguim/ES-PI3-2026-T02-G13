// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/auth_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AuthApiService', () {
    test('realiza login com sucesso', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/users/login');

        return http.Response(
          '{"mensagem":"Login realizado","usuario":{"id":1,"nome":"Teste","email":"teste@mescla.com"}}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = AuthApiService(client: client);
      final result = await service.login(
        email: 'teste@mescla.com',
        senha: '123456',
      );

      expect(result.success, true);
      expect(result.message, 'Login realizado');
      expect(result.usuario?['email'], 'teste@mescla.com');
    });

    test('retorna erro de cadastro quando API responde 400', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/users/register');

        return http.Response(
          '{"erro":"Email ja cadastrado"}',
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = AuthApiService(client: client);
      final result = await service.register(
        nome: 'Teste',
        email: 'teste@mescla.com',
        senha: '123456',
      );

      expect(result.success, false);
      expect(result.message, 'Email ja cadastrado');
      expect(result.usuario, isNull);
    });

    test('retorna falha de conexao quando ocorre excecao', () async {
      final client = MockClient((_) async {
        throw Exception('network error');
      });

      final service = AuthApiService(client: client);
      final result = await service.login(
        email: 'teste@mescla.com',
        senha: '123456',
      );

      expect(result.success, false);
      expect(result.message, 'Falha de conexao com o servidor.');
    });

    test('realiza solicitacao de recuperacao de senha com sucesso', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/users/recover-password');

        return http.Response(
          '{"mensagem":"Se o e-mail estiver cadastrado, enviaremos as instrucoes de recuperacao."}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = AuthApiService(client: client);
      final result = await service.recoverPassword(email: 'teste@mescla.com');

      expect(result.success, true);
      expect(
        result.message,
        'Se o e-mail estiver cadastrado, enviaremos as instrucoes de recuperacao.',
      );
    });
  });
}
