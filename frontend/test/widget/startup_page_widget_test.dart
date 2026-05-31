// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/auth/auth_session_storage.dart';
import 'package:frontend/features/home/data/mock_startup_repository.dart';
import 'package:frontend/features/home/presentation/models/startup_data.dart';
import 'package:frontend/features/home/presentation/startup_page.dart';

class _FakeStartupRepository extends StartupRepository {
  _FakeStartupRepository(this._startups);

  final List<StartupData> _startups;

  @override
  Future<List<StartupData>> fetchStartups({
    bool useMockFallback = true,
    String? functionUrlOverride,
  }) async {
    return _startups;
  }
}

class _InMemoryAuthStorageBackend implements AuthStorageBackend {
  _InMemoryAuthStorageBackend(this.values);

  final Map<String, String> values;

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<String?> read({required String key}) async {
    return values[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}

void main() {
  testWidgets('renderiza catalogo e aplica filtro por estagio', (tester) async {
    final repository = _FakeStartupRepository([
      const StartupData(
        name: 'NovaOne',
        description: 'Startup em fase nova',
        stage: 'Nova',
        tokenValue: 'R\$ 1,00',
        tokenPrice: 1,
        variation: '+0.00%',
        imageUrl: '',
        sector: 'Tech',
        totalTokens: 100,
        raisedCapital: 'R\$ 100,00',
        executiveSummary: 'Resumo',
        founders: 'A',
        ownershipStructure: '100%',
        mentorsCouncil: 'Mentor',
        demoVideoUrl: '',
      ),
      const StartupData(
        name: 'OperaNow',
        description: 'Startup em operacao',
        stage: 'Operacao',
        tokenValue: 'R\$ 2,00',
        tokenPrice: 2,
        variation: '+0.00%',
        imageUrl: '',
        sector: 'Health',
        totalTokens: 200,
        raisedCapital: 'R\$ 400,00',
        executiveSummary: 'Resumo',
        founders: 'B',
        ownershipStructure: '100%',
        mentorsCouncil: 'Mentor',
        demoVideoUrl: '',
      ),
    ]);

    final storage = AuthSessionStorage(
      backend: _InMemoryAuthStorageBackend({'auth_user_name': 'Felipe Sousa'}),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: StartupPage(
          startupRepository: repository,
          authSessionStorage: storage,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('NovaOne'), findsOneWidget);
    expect(find.text('OperaNow'), findsOneWidget);

    await tester.tap(find.text('Novas'));
    await tester.pumpAndSettle();

    expect(find.text('NovaOne'), findsOneWidget);
    expect(find.text('OperaNow'), findsNothing);
  });
}
