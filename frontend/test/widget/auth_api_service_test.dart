// Autoria: Felipe Sousa - RA: 22018160

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/auth_api_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _FakeRequestOptions extends Fake implements RequestOptions {}

const _registerFunctionUrl =
    'https://us-central1-pi3-mescla-invest.cloudfunctions.net/registerUser';

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRequestOptions());
  });

  group('AuthApiService', () {
    late Dio dio;
    late AuthApiService service;

    setUp(() {
      dio = _MockDio();
      service = AuthApiService(
        dio: dio,
        registerFunctionUrl: _registerFunctionUrl,
      );
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

    test('realiza cadastro via Cloud Function com sucesso', () async {
      when(
        () => dio.post(
          _registerFunctionUrl,
          data: {
            'nome': 'Teste',
            'email': 'teste@mescla.com',
            'cpf': '12345678909',
            'telefone': '11987654321',
            'senha': '123456',
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: _registerFunctionUrl),
          statusCode: 200,
          data: {'message': 'Usuario criado com sucesso', 'uid': 'uid-123'},
        ),
      );

      final result = await service.register(
        nome: 'Teste',
        email: 'teste@mescla.com',
        cpf: '12345678909',
        telefone: '11987654321',
        senha: '123456',
      );

      expect(result.success, true);
      expect(result.message, 'Usuario criado com sucesso');
      expect(result.usuario, isNull);
      expect(result.token, isNull);
    });

    test('retorna erro quando a URL da function nao foi configurada', () async {
      final serviceWithoutRegisterUrl = AuthApiService(
        dio: dio,
        registerFunctionUrl: '',
      );

      final result = await serviceWithoutRegisterUrl.register(
        nome: 'Teste',
        email: 'teste@mescla.com',
        cpf: '12345678909',
        telefone: '11987654321',
        senha: '123456',
      );

      expect(result.success, false);
      expect(
        result.message,
        'Cadastro indisponivel. Configure REGISTER_FUNCTION_URL.',
      );
      verifyNever(() => dio.post(any(), data: any(named: 'data')));
    });

    test('retorna erro de CPF invalido no cadastro', () async {
      final response = Response(
        requestOptions: RequestOptions(path: _registerFunctionUrl),
        statusCode: 400,
        data: 'CPF invalido',
      );

      when(
        () => dio.post(
          _registerFunctionUrl,
          data: {
            'nome': 'Teste',
            'email': 'teste@mescla.com',
            'cpf': '12345678900',
            'telefone': '11987654321',
            'senha': '123456',
          },
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: _registerFunctionUrl),
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await service.register(
        nome: 'Teste',
        email: 'teste@mescla.com',
        cpf: '12345678900',
        telefone: '11987654321',
        senha: '123456',
      );

      expect(result.success, false);
      expect(result.message, 'CPF invalido');
      expect(result.usuario, isNull);
    });

    test('retorna erro quando faltam dados obrigatorios no cadastro', () async {
      final response = Response(
        requestOptions: RequestOptions(path: _registerFunctionUrl),
        statusCode: 400,
        data: 'Dados obrigatorios faltando',
      );

      when(
        () => dio.post(
          _registerFunctionUrl,
          data: {
            'nome': 'Teste',
            'email': 'teste@mescla.com',
            'cpf': '',
            'telefone': '11987654321',
            'senha': '123456',
          },
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: _registerFunctionUrl),
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await service.register(
        nome: 'Teste',
        email: 'teste@mescla.com',
        cpf: '',
        telefone: '11987654321',
        senha: '123456',
      );

      expect(result.success, false);
      expect(result.message, 'Dados obrigatorios faltando');
    });

    test('retorna falha de conexao quando ocorre excecao no login', () async {
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

    test(
      'retorna falha de conexao quando o cadastro nao alcanca a function',
      () async {
        when(
          () => dio.post(
            _registerFunctionUrl,
            data: {
              'nome': 'Teste',
              'email': 'teste@mescla.com',
              'cpf': '12345678909',
              'telefone': '11987654321',
              'senha': '123456',
            },
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: _registerFunctionUrl),
            type: DioExceptionType.connectionError,
            error: Exception('network error'),
          ),
        );

        final result = await service.register(
          nome: 'Teste',
          email: 'teste@mescla.com',
          cpf: '12345678909',
          telefone: '11987654321',
          senha: '123456',
        );

        expect(result.success, false);
        expect(result.message, 'Falha de conexao com o servidor.');
      },
    );
  });
}
