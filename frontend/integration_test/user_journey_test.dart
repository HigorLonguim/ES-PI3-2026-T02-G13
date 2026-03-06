/* Nome: Felipe Sousa de Almeida | RA: 22018160 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Fluxo real MesclaInvest: Home -> Login -> Voltar Home', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    // runApp() — renderiza o MesclaInvest na tela fisica do dispositivo
    app.main();

    // Aguarda o app renderizar — tela Home visivel no dispositivo
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('MesclaInvest'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);

    // Toca em "Continuar" — navega para Login
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Bem-vindo de volta'), findsOneWidget);

    // Toca no botao voltar — retorna para Home
    await tester.tap(find.byIcon(Icons.chevron_left_rounded).first);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('MesclaInvest'), findsOneWidget);
  });

  testWidgets(
    'Fluxo real MesclaInvest: Home -> Login -> Cadastro com preenchimento',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      // runApp() — renderiza o MesclaInvest na tela fisica do dispositivo
      app.main();

      // Aguarda o app renderizar — tela Home visivel no dispositivo
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Toca em "Continuar" — navega para Login
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Bem-vindo de volta'), findsOneWidget);

      // Preenche e-mail e senha na tela de Login
      await tester.enterText(find.byType(TextField).first, 'felipe@email.com');
      await tester.enterText(find.byType(TextField).at(1), '12345678');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      // Toca em "Cadastre-se" — navega para tela de Cadastro
      await tester.ensureVisible(find.text('Cadastre-se'));
      await tester.tap(find.text('Cadastre-se'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Criar Conta'), findsWidgets);

      // Preenche todos os campos do formulario de cadastro
      await tester.enterText(
        find.byType(TextField).at(0),
        'Felipe Sousa de Almeida',
      );
      await tester.enterText(find.byType(TextField).at(1), 'felipe@email.com');
      await tester.enterText(find.byType(TextField).at(2), '123.456.789-00');
      await tester.enterText(find.byType(TextField).at(3), '(11) 99999-9999');
      await tester.enterText(find.byType(TextField).at(4), '12345678');
      await tester.enterText(find.byType(TextField).at(5), '12345678');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Rola a pagina de volta ao topo para revelar o botao voltar
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, 1000),
      );
      await tester.pumpAndSettle();

      // Toca no botao voltar — retorna para Login
      await tester.tap(find.byIcon(Icons.chevron_left_rounded).first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Bem-vindo de volta'), findsOneWidget);
    },
  );
}
