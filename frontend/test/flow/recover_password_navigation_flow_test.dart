/* Nome: Felipe Sousa de Almeida | RA: 22018160 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/mescla_invest_app.dart';

void main() {
  testWidgets('Fluxo: Home -> Login -> Recuperar Senha -> Volta Login', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MesclaInvestApp());

    expect(find.text('Continuar'), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('Esqueceu a senha?'), findsOneWidget);

    await tester.tap(find.text('Esqueceu a senha?'));
    await tester.pumpAndSettle();

    expect(find.text('Recuperar Senha'), findsOneWidget);
    expect(find.text('Enviar Instruções'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
  });
}
