// Autoria: Felipe Sousa - RA: 22018160

import '../presentation/models/startup_data.dart';

class MockStartupRepository {
  Future<List<StartupData>> fetchStartups() async {
    return const [
      StartupData(
        name: 'TechFlow',
        description: 'Plataforma de automação para e-commerce',
        stage: 'Expansão',
        tokenValue: 'R\$ 125.50',
        variation: '+12.50%',
        imageUrl:
            'https://www.figma.com/api/mcp/asset/6ab3a4a1-55c3-40a1-854b-82fda3a66a82',
      ),
      StartupData(
        name: 'GreenEnergy',
        description: 'Soluções em energia solar residencial',
        stage: 'Operação',
        tokenValue: 'R\$ 85.30',
        variation: '+5.20%',
        imageUrl:
            'https://www.figma.com/api/mcp/asset/398eb24d-fe8f-4800-bfbf-4f45c5664cf5',
      ),
      StartupData(
        name: 'HealthAI',
        description: 'Diagnóstico médico assistido por IA',
        stage: 'Nova',
        tokenValue: 'R\$ 50.00',
        variation: '-2.30%',
        imageUrl:
            'https://www.figma.com/api/mcp/asset/da02914f-fcbe-44ad-ad89-4d1b9070b0c8',
      ),
      StartupData(
        name: 'EduTech Pro',
        description: 'Ensino online personalizado para empresas',
        stage: 'Operação',
        tokenValue: 'R\$ 95.75',
        variation: '+8.10%',
        imageUrl:
            'https://www.figma.com/api/mcp/asset/5bb39f20-9628-4caf-b3de-f2e3ea1c1a7f',
      ),
      StartupData(
        name: 'FoodChain',
        description: 'Rastreabilidade blockchain para alimentos',
        stage: 'Nova',
        tokenValue: 'R\$ 42.80',
        variation: '+15.70%',
        imageUrl:
            'https://www.figma.com/api/mcp/asset/15655d0b-dfa4-4a5f-a7fe-7c9c1157e7ed',
      ),
    ];
  }
}
