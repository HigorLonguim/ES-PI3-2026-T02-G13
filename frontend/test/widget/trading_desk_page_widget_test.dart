// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/home/presentation/main_navigation_page.dart';

void main() {
  testWidgets('renderiza a tela de balcão com tabs do fluxo', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationPage(initialIndex: 2)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Balcão de Negociacão'), findsOneWidget);
    expect(find.text('Mercado'), findsOneWidget);
    expect(find.text('Minhas Ofertas'), findsOneWidget);
    expect(find.text('Ofertas ativas'), findsOneWidget);
  });
}
