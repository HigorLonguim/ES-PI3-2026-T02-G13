// Autoria: Felipe Sousa - RA: 22018160

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/auth_api_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRequestOptions());
  });

  group('AuthApiService', () {
    late Dio dio;
    late AuthApiService service;

    setUp(() {
      dio = _MockDio();
      service = AuthApiService(dio: dio);
    });

    test('realiza login com sucesso', () async {
      when(() => dio.post('/users/login', data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/users/login'),
          statusCode: 200,
          data: {
            'mensagem': 'Login realizado',
            'usuario': {'id': 1, 'nome': 'Teste', 'email': 'teste@mescla.com'},
          },
        ),
      );

      final result = await service.login(
        email: 'teste@mescla.com',
        senha: '123456',
      );

      expect(result.success, true);
      expect(result.message, 'Login realizado');
      expect(result.usuario?['email'], 'teste@mescla.com');
    });

    test('retorna erro de cadastro quando API responde 400', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/users/register'),
        statusCode: 400,
        data: {'erro': 'Email ja cadastrado'},
      );

      when(
        () => dio.post('/users/register', data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/register'),
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );

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
      when(() => dio.post('/users/login', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/login'),
          type: DioExceptionType.connectionError,
          error: Exception('network error'),
        ),
      );

      final result = await service.login(
        email: 'teste@mescla.com',
        senha: '123456',
      );

      expect(result.success, false);
      expect(result.message, 'Falha de conexao com o servidor.');
    });

    test('realiza solicitacao de recuperacao de senha com sucesso', () async {
      when(
        () => dio.post('/users/recover-password', data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/users/recover-password'),
          statusCode: 200,
          data: {
            'mensagem':
                'Se o e-mail estiver cadastrado, enviaremos as instrucoes de recuperacao.',
          },
        ),
      );

      final result = await service.recoverPassword(email: 'teste@mescla.com');

      expect(result.success, true);
      expect(
        result.message,
        'Se o e-mail estiver cadastrado, enviaremos as instrucoes de recuperacao.',
      );
    });
  });
}
