// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/home/presentation/models/startup_data.dart';

void main() {
  group('StartupData.fromApi', () {
    test('mapeia campos de detalhe vindos da function', () {
      final startup = StartupData.fromApi({
        'name': 'EcoLoop',
        'description': 'Startup de reciclagem inteligente',
        'stage': 'Nova',
        'tokenValue': 'R\$ 1.50',
        'tokenPrice': 1.5,
        'variation': '+8.50%',
        'imageUrl': 'https://img.example/startup.png',
        'sector': 'Cleantech',
        'totalTokens': 100000,
        'raisedCapital': 'R\$ 0.1M',
        'executiveSummary': 'Resumo real da startup',
        'founders': 'Ana Silva, Roberto Costa',
        'ownershipStructure': 'Ana Silva: 60%; Roberto Costa: 40%',
        'mentorsCouncil': 'Dr. Marcos Neves',
        'demoVideoUrl': 'https://demo.example/video',
        'publicQaItems': [
          {
            'question': 'Como a startup monetiza?',
            'answer': 'Via assinaturas B2B.',
          },
          {
            'question': 'Ja possui clientes?',
            'answer': 'Sim, com contratos ativos.',
          },
        ],
      });

      expect(startup.name, 'EcoLoop');
      expect(startup.founders, 'Ana Silva, Roberto Costa');
      expect(startup.ownershipStructure, 'Ana Silva: 60%; Roberto Costa: 40%');
      expect(startup.mentorsCouncil, 'Dr. Marcos Neves');
      expect(startup.demoVideoUrl, 'https://demo.example/video');
      expect(startup.publicQaItems.length, 2);
      expect(startup.publicQaItems.first.question, 'Como a startup monetiza?');
      expect(startup.publicQaItems.first.answer, 'Via assinaturas B2B.');
    });

    test('aplica defaults dos novos campos quando ausentes', () {
      final startup = StartupData.fromApi({
        'name': 'Sem Dados',
        'description': 'Descricao',
      });

      expect(startup.founders, isEmpty);
      expect(startup.ownershipStructure, isEmpty);
      expect(startup.mentorsCouncil, isEmpty);
      expect(startup.demoVideoUrl, isEmpty);
      expect(startup.publicQaItems, isEmpty);
    });
  });
}
