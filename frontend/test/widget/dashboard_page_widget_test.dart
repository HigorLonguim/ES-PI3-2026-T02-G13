// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/home/presentation/main_navigation_page.dart';

void main() {
  testWidgets('renderiza dashboard no fluxo principal', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationPage(initialIndex: 3)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Acompanhe sua performance'), findsOneWidget);
    expect(find.text('Valor Total do Portfólio'), findsOneWidget);
    expect(find.text('Histórico de Valorização'), findsOneWidget);
    expect(find.text('Estatísticas'), findsOneWidget);
  });
}
