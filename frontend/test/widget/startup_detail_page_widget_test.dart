// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/home/presentation/models/startup_data.dart';
import 'package:frontend/features/home/presentation/startup_detail_page.dart';

void main() {
  testWidgets('exibe perguntas e respostas publicas na tela detalhada', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    const startup = StartupData(
      name: 'EcoLoop',
      description: 'Logistica reversa',
      stage: 'Operacao',
      tokenValue: 'R\$ 1,50',
      tokenPrice: 1.5,
      variation: '+0.00%',
      imageUrl: '',
      sector: 'Cleantech',
      totalTokens: 100000,
      raisedCapital: 'R\$ 150.000,00',
      executiveSummary: 'Resumo executivo',
      founders: 'Ana Silva; Roberto Costa',
      ownershipStructure: 'Ana Silva: 60%; Roberto Costa: 40%',
      mentorsCouncil: 'Dr. Marcos Neves',
      demoVideoUrl: 'https://youtu.be/ecoloop',
      publicQaItems: [
        PublicQaItem(
          question: 'Qual o principal uso do capital?',
          answer: 'Escalar operacao e produto.',
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(home: StartupDetailPage(startup: startup)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Perguntas (1)'), findsOneWidget);
    await tester.ensureVisible(find.text('Perguntas (1)'));
    await tester.tap(find.text('Perguntas (1)'));
    await tester.pumpAndSettle();

    expect(find.text('P: Qual o principal uso do capital?'), findsOneWidget);
    expect(find.text('R: Escalar operacao e produto.'), findsOneWidget);
  });
}
