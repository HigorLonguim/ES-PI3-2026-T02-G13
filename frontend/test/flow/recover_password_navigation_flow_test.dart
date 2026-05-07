/* Nome: Felipe Sousa de Almeida | RA: 22018160 */

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/auth_api_service.dart';
import 'package:frontend/features/auth/presentation/recover_password_page.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRequestOptions());
  });

  testWidgets('Fluxo: Recuperar senha -> sucesso com endpoint valido', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final dio = _MockDio();
    when(
      () => dio.post(
        '/users/recover-password',
        data: {'email': 'felipe@mescla.com'},
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/users/recover-password'),
        statusCode: 200,
        data: {
          'mensagem':
              'Se o e-mail estiver cadastrado, enviaremos as instrucoes.',
        },
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RecoverPasswordPage(authApiService: AuthApiService(dio: dio)),
      ),
    );

    await tester.enterText(find.byType(TextField), 'felipe@mescla.com');
    await tester.tap(find.textContaining('Enviar'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail Enviado!'), findsOneWidget);
    expect(find.text('Voltar ao login'), findsOneWidget);
    await tester.tap(find.text('Voltar ao login'));
    await tester.pumpAndSettle();
    expect(find.text('Bem-vindo de volta'), findsOneWidget);
  });

  testWidgets('Fluxo: Recuperar senha -> sucesso com modo mock habilitado', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: RecoverPasswordPage(useMockRecoverPasswordFlow: true),
      ),
    );

    await tester.enterText(find.byType(TextField), 'felipe@mescla.com');
    await tester.tap(find.textContaining('Enviar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('E-mail Enviado!'), findsOneWidget);
    expect(find.text('Voltar ao login'), findsOneWidget);
    await tester.tap(find.text('Voltar ao login'));
    await tester.pumpAndSettle();
    expect(find.text('Bem-vindo de volta'), findsOneWidget);
  });
}
