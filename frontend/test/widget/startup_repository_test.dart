// Autoria: Felipe Sousa - RA: 22018160

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/home/data/mock_startup_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRequestOptions());
  });

  test('retorna mock quando URL remota nao esta configurada', () async {
    final repository = StartupRepository();

    final startups = await repository.fetchStartups(useMockFallback: true);

    expect(startups, isNotEmpty);
  });

  test(
    'retorna lista vazia quando URL remota nao esta configurada sem fallback',
    () async {
      final repository = StartupRepository();

      final startups = await repository.fetchStartups(useMockFallback: false);

      expect(startups, isEmpty);
    },
  );

  test('mapeia contrato legado vindo em `startups`', () async {
    final dio = _MockDio();
    const endpoint = 'https://example.com/startups';
    when(() => dio.get(endpoint)).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: endpoint),
        statusCode: 200,
        data: {
          'startups': [
            {
              'id_startup': 1,
              'nome_startup': 'EcoLoop',
              'descricao': 'Logistica reversa',
              'estagio': 'Operacao',
              'setor': 'Cleantech',
              'capital_aportado': 150000,
              'tokens_emitidos': 100000,
              'socios': 'Ana Silva; Roberto Costa',
              'participacao_societaria': '60%; 40%',
              'mentores_conselho': 'Dr. Marcos Neves',
              'video_demo': 'https://youtu.be/ecoloop',
              'perguntas_publicas': [
                {
                  'question': 'Como o capital sera usado?',
                  'answer': 'Expansao operacional.',
                },
              ],
            },
          ],
        },
      ),
    );

    final repository = StartupRepository(dio: dio);
    final startups = await repository.fetchStartups(
      useMockFallback: false,
      functionUrlOverride: endpoint,
    );

    expect(startups.length, 1);
    expect(startups.first.name, 'EcoLoop');
    expect(startups.first.stage, 'Operacao');
    expect(startups.first.totalTokens, 100000);
    expect(startups.first.publicQaItems.length, 1);
    expect(
      startups.first.publicQaItems.first.question,
      'Como o capital sera usado?',
    );
  });
}
