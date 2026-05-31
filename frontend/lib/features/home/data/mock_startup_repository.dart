// Autoria: Felipe Sousa - RA: 22018160

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../presentation/models/startup_data.dart';

class StartupRepository {
  StartupRepository({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<List<StartupData>> fetchStartups({
    bool useMockFallback = true,
    String? functionUrlOverride,
  }) async {
    final functionUrl = (functionUrlOverride ?? AppConfig.startupsFunctionUrl)
        .trim();
    if (functionUrl.isEmpty) {
      return useMockFallback ? _mockStartups : const <StartupData>[];
    }

    try {
      final response = await _dio.get(functionUrl);
      final body = _decodeBody(response.data);
      final startups = _extractStartups(body);

      return startups.isEmpty && useMockFallback ? _mockStartups : startups;
    } on DioException {
      return useMockFallback ? _mockStartups : const <StartupData>[];
    } catch (_) {
      return useMockFallback ? _mockStartups : const <StartupData>[];
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

  List<StartupData> _extractStartups(Map<String, dynamic> body) {
    final dynamic items = body['items'];
    if (items is List) {
      return items
          .whereType<Map>()
          .map((item) => StartupData.fromApi(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    }

    final dynamic startups = body['startups'];
    if (startups is! List) {
      return const <StartupData>[];
    }

    return startups
        .whereType<Map>()
        .map((item) => _mapLegacyStartup(Map<String, dynamic>.from(item)))
        .map(StartupData.fromApi)
        .toList(growable: false);
  }

  Map<String, dynamic> _mapLegacyStartup(Map<String, dynamic> source) {
    final totalTokens = _readInt(source['tokens_emitidos']);
    final raisedCapitalValue = _readDouble(source['capital_aportado']);
    final tokenPrice = totalTokens > 0 ? raisedCapitalValue / totalTokens : 0.0;
    final stage = _normalizeStage(source['estagio'] as String?);

    return <String, dynamic>{
      'id':
          source['id']?.toString() ??
          source['id_startup']?.toString() ??
          source['name']?.toString(),
      'name': source['nome_startup'] ?? source['name'] ?? 'Startup sem nome',
      'description': source['descricao'] ?? source['description'] ?? '',
      'stage': stage,
      'tokenPrice': tokenPrice,
      'tokenValue': _formatCurrency(tokenPrice),
      'variation': source['variation'] ?? '+0.00%',
      'imageUrl': source['imageUrl'] ?? '',
      'sector': source['setor'] ?? source['sector'] ?? 'Nao informado',
      'totalTokens': totalTokens,
      'raisedCapital': _formatCurrency(raisedCapitalValue),
      'executiveSummary':
          source['descricao'] ?? source['executiveSummary'] ?? '',
      'founders': source['socios'] ?? source['founders'] ?? '',
      'ownershipStructure':
          source['participacao_societaria'] ??
          source['ownershipStructure'] ??
          '',
      'mentorsCouncil':
          source['mentores_conselho'] ?? source['mentorsCouncil'] ?? '',
      'demoVideoUrl': source['video_demo'] ?? source['demoVideoUrl'] ?? '',
      'publicQaItems': source['perguntas_publicas'] ?? source['publicQaItems'],
    };
  }

  int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }

  String _normalizeStage(String? stage) {
    switch ((stage ?? '').toLowerCase()) {
      case 'operacao':
      case 'operação':
        return 'Operacao';
      case 'expansao':
      case 'expansão':
        return 'Expansao';
      default:
        return 'Nova';
    }
  }

  String _formatCurrency(double value) {
    final fixed = value.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $fixed';
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
    founders: 'Ana Silva, Roberto Costa',
    ownershipStructure: 'Ana Silva: 60%; Roberto Costa: 40%',
    mentorsCouncil: 'Dr. Marcos Neves',
    demoVideoUrl:
        'https://firebasestorage.googleapis.com/v0/b/pi3-mescla-invest.firebasestorage.app/o/Video%20Ecoloop.mp4?alt=media&token=0cd4b2e2-e175-4a61-800f-2c85396784d0',
    publicQaItems: [
      PublicQaItem(
        question: 'Como sera usado o capital captado?',
        answer: 'Expansao de produto e contratacao do time comercial.',
      ),
      PublicQaItem(
        question: 'Ja existe tracao validada?',
        answer: 'Sim, temos clientes pagantes e crescimento recorrente.',
      ),
    ],
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
    founders: 'Carla Mendes, Bruno Ribeiro',
    ownershipStructure: 'Carla Mendes: 55%; Bruno Ribeiro: 45%',
    mentorsCouncil: 'Paula Freitas, Eduardo Lima',
    demoVideoUrl:
        'https://firebasestorage.googleapis.com/v0/b/pi3-mescla-invest.firebasestorage.app/o/Video%20EduVibe.mp4?alt=media&token=83d55191-bd69-4376-9b4a-3f09bceef92f',
    publicQaItems: [
      PublicQaItem(
        question: 'Qual e o mercado-alvo inicial?',
        answer: 'Residencias unifamiliares em capitais do Sudeste.',
      ),
    ],
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
    founders: 'Marina Rocha, Lucas Prado',
    ownershipStructure: 'Marina Rocha: 70%; Lucas Prado: 30%',
    mentorsCouncil: 'Dra. Helena Castro',
    demoVideoUrl:
        'https://firebasestorage.googleapis.com/v0/b/pi3-mescla-invest.firebasestorage.app/o/Video%20VitalTrack.mp4?alt=media&token=9a05323a-7e64-4f43-9460-72b754888df7',
    publicQaItems: [
      PublicQaItem(
        question: 'Como funciona a validacao clinica?',
        answer: 'Parcerias com clinicas para testes supervisionados.',
      ),
    ],
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
    founders: 'Fernanda Pires, Tiago Alves',
    ownershipStructure: 'Fernanda Pires: 50%; Tiago Alves: 50%',
    mentorsCouncil: 'Renata Silva',
    demoVideoUrl:
        'https://firebasestorage.googleapis.com/v0/b/pi3-mescla-invest.firebasestorage.app/o/Video%20AgroSense.mp4?alt=media&token=466ba0ee-bfc2-4579-b602-033d14fae243',
    publicQaItems: [
      PublicQaItem(
        question: 'Qual e o diferencial frente aos concorrentes?',
        answer: 'Personalizacao automatica por trilha e por equipe.',
      ),
    ],
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
    founders: 'Juliana Costa, Pedro Rocha',
    ownershipStructure: 'Juliana Costa: 65%; Pedro Rocha: 35%',
    mentorsCouncil: 'Andre Nogueira',
    demoVideoUrl:
        'https://firebasestorage.googleapis.com/v0/b/pi3-mescla-invest.firebasestorage.app/o/Video%20SafePay.mp4?alt=media&token=0b92b6f4-8584-486c-8094-8a085eaf3233',
    publicQaItems: [
      PublicQaItem(
        question: 'Como a solucao gera receita?',
        answer: 'Assinatura B2B por lote de produtores e distribuidores.',
      ),
    ],
  ),
];
