/* Nome: Felipe Sousa de Almeida | RA: 22018160 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app/mescla_invest_app.dart';

void main() {
  testWidgets('Deve exibir tela inicial com botão Continuar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MesclaInvestApp());

    expect(find.text('MesclaInvest'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
  });
}
