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
        tokenPrice: 125.50,
        variation: '+12.50%',
        imageUrl: 'https://picsum.photos/seed/techflow/400/400',
        sector: 'Tecnologia',
        totalTokens: 1000000,
        raisedCapital: 'R\$ 5.0M',
        executiveSummary:
            'A TechFlow está revolucionando o mercado de e-commerce com tecnologia de ponta em automação de processos. Nossa plataforma permite que lojistas automatizem toda a jornada do cliente.',
      ),
      StartupData(
        name: 'GreenEnergy',
        description: 'Soluções em energia solar residencial',
        stage: 'Operação',
        tokenValue: 'R\$ 85.30',
        tokenPrice: 85.30,
        variation: '+5.20%',
        imageUrl: 'https://picsum.photos/seed/greenenergy/400/400',
        sector: 'Energia',
        totalTokens: 750000,
        raisedCapital: 'R\$ 3.8M',
        executiveSummary:
            'A GreenEnergy oferece soluções de energia solar residencial com foco em eficiência e sustentabilidade, conectando tecnologia e redução de custos para famílias.',
      ),
      StartupData(
        name: 'HealthAI',
        description: 'Diagnóstico médico assistido por IA',
        stage: 'Nova',
        tokenValue: 'R\$ 50.00',
        tokenPrice: 50.00,
        variation: '-2.30%',
        imageUrl: 'https://picsum.photos/seed/healthai/400/400',
        sector: 'Saúde',
        totalTokens: 500000,
        raisedCapital: 'R\$ 1.5M',
        executiveSummary:
            'A HealthAI desenvolve diagnóstico médico assistido por inteligência artificial, aumentando a precisão clínica e acelerando a triagem de pacientes.',
      ),
      StartupData(
        name: 'EduTech Pro',
        description: 'Ensino online personalizado para empresas',
        stage: 'Operação',
        tokenValue: 'R\$ 95.75',
        tokenPrice: 95.75,
        variation: '+8.10%',
        imageUrl: 'https://picsum.photos/seed/edutechpro/400/400',
        sector: 'Educação',
        totalTokens: 640000,
        raisedCapital: 'R\$ 2.7M',
        executiveSummary:
            'A EduTech Pro fornece trilhas de ensino corporativo personalizadas e analíticas de aprendizagem para melhorar a performance de equipes.',
      ),
      StartupData(
        name: 'FoodChain',
        description: 'Rastreabilidade blockchain para alimentos',
        stage: 'Nova',
        tokenValue: 'R\$ 42.80',
        tokenPrice: 42.80,
        variation: '+15.70%',
        imageUrl: 'https://picsum.photos/seed/foodchain/400/400',
        sector: 'Alimentos',
        totalTokens: 450000,
        raisedCapital: 'R\$ 1.1M',
        executiveSummary:
            'A FoodChain aplica blockchain para rastreabilidade de alimentos, aumentando transparência e segurança da cadeia de suprimentos.',
      ),
    ];
  }
}
