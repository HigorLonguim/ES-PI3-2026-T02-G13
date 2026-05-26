// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/navigation/app_route.dart';
import 'package:frontend/features/auth/presentation/login_page.dart';

void main() {
  testWidgets('Login exibe toast ao tentar entrar sem credenciais', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: AppRoute.navigatorKey,
        scaffoldMessengerKey: AppRoute.scaffoldMessengerKey,
        home: const LoginPage(),
      ),
    );

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Preencha email e senha.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Preencha email e senha.'), findsNothing);
  });
}
