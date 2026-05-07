/* Nome: Felipe Sousa de Almeida | RA: 22018160 */

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/auth_api_service.dart';
import 'package:frontend/features/auth/presentation/signup_page.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _FakeRequestOptions extends Fake implements RequestOptions {}

const _registerFunctionUrl =
    'https://us-central1-pi3-mescla-invest.cloudfunctions.net/registerUser';

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRequestOptions());
  });

  testWidgets('Fluxo: Cadastro -> envia todos os campos e volta apos sucesso', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final dio = _MockDio();
    when(
      () => dio.post(
        _registerFunctionUrl,
        data: {
          'nome': 'Felipe Sousa',
          'email': 'felipe@mescla.com',
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

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SignUpPage(
                          authApiService: AuthApiService(
                            dio: dio,
                            registerFunctionUrl: _registerFunctionUrl,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Abrir cadastro'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Abrir cadastro'));
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'Felipe Sousa');
    await tester.enterText(textFields.at(1), 'felipe@mescla.com');
    await tester.enterText(textFields.at(2), '12345678909');
    await tester.enterText(textFields.at(3), '11987654321');
    await tester.enterText(textFields.at(4), '123456');
    await tester.enterText(textFields.at(5), '123456');

    await tester.tap(find.text('Criar Conta').last);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Abrir cadastro'), findsOneWidget);
    verify(
      () => dio.post(
        _registerFunctionUrl,
        data: {
          'nome': 'Felipe Sousa',
          'email': 'felipe@mescla.com',
          'cpf': '12345678909',
          'telefone': '11987654321',
          'senha': '123456',
        },
      ),
    ).called(1);
  });
}
