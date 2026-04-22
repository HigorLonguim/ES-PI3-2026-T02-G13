// Autoria: Felipe Sousa - RA: 22018160

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../presentation/models/startup_data.dart';

class StartupRepository {
  StartupRepository({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<List<StartupData>> fetchStartups() async {
    final functionUrl = AppConfig.startupsFunctionUrl.trim();
    if (functionUrl.isEmpty) {
      return _mockStartups;
    }

    try {
      final response = await _dio.get(functionUrl);
      final body = _decodeBody(response.data);
      final items = body['items'];
      if (items is! List) {
        return _mockStartups;
      }

      final startups = items
          .whereType<Map>()
          .map((item) => StartupData.fromApi(Map<String, dynamic>.from(item)))
          .toList(growable: false);

      if (startups.isEmpty) {
        return _mockStartups;
      }

      return startups;
    } on DioException {
      return _mockStartups;
    } catch (_) {
      return _mockStartups;
    }
  }

  Map<String, dynamic> _decodeBody(dynamic rawBody) {
    if (rawBody is Map<String, dynamic>) {
      return rawBody;
    }
    if (rawBody is Map) {
      return Map<String, dynamic>.from(rawBody);
    }
    if (rawBody is String) {
      final trimmedBody = rawBody.trim();
      if (trimmedBody.isEmpty) {
        return <String, dynamic>{};
      }
      try {
        final decoded = jsonDecode(trimmedBody);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    return <String, dynamic>{};
  }
}

const List<StartupData> _mockStartups = [
  StartupData(
    name: 'TechFlow',
    description: 'Plataforma de automacao para e-commerce',
    stage: 'Expansao',
    tokenValue: 'R\$ 125.50',
    tokenPrice: 125.50,
    variation: '+12.50%',
    imageUrl: 'https://picsum.photos/seed/techflow/400/400',
    sector: 'Tecnologia',
    totalTokens: 1000000,
    raisedCapital: 'R\$ 5.0M',
    executiveSummary:
        'A TechFlow esta revolucionando o mercado de e-commerce com tecnologia de ponta em automacao de processos. Nossa plataforma permite que lojistas automatizem toda a jornada do cliente.',
  ),
  StartupData(
    name: 'GreenEnergy',
    description: 'Solucoes em energia solar residencial',
    stage: 'Operacao',
    tokenValue: 'R\$ 85.30',
    tokenPrice: 85.30,
    variation: '+5.20%',
    imageUrl: 'https://picsum.photos/seed/greenenergy/400/400',
    sector: 'Energia',
    totalTokens: 750000,
    raisedCapital: 'R\$ 3.8M',
    executiveSummary:
        'A GreenEnergy oferece solucoes de energia solar residencial com foco em eficiencia e sustentabilidade, conectando tecnologia e reducao de custos para familias.',
  ),
  StartupData(
    name: 'HealthAI',
    description: 'Diagnostico medico assistido por IA',
    stage: 'Nova',
    tokenValue: 'R\$ 50.00',
    tokenPrice: 50.00,
    variation: '-2.30%',
    imageUrl: 'https://picsum.photos/seed/healthai/400/400',
    sector: 'Saude',
    totalTokens: 500000,
    raisedCapital: 'R\$ 1.5M',
    executiveSummary:
        'A HealthAI desenvolve diagnostico medico assistido por inteligencia artificial, aumentando a precisao clinica e acelerando a triagem de pacientes.',
  ),
  StartupData(
    name: 'EduTech Pro',
    description: 'Ensino online personalizado para empresas',
    stage: 'Operacao',
    tokenValue: 'R\$ 95.75',
    tokenPrice: 95.75,
    variation: '+8.10%',
    imageUrl: 'https://picsum.photos/seed/edutechpro/400/400',
    sector: 'Educacao',
    totalTokens: 640000,
    raisedCapital: 'R\$ 2.7M',
    executiveSummary:
        'A EduTech Pro fornece trilhas de ensino corporativo personalizadas e analiticas de aprendizagem para melhorar a performance de equipes.',
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
        'A FoodChain aplica blockchain para rastreabilidade de alimentos, aumentando transparencia e seguranca da cadeia de suprimentos.',
  ),
];
