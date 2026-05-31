// Autoria: Felipe Sousa - RA: 22018160

class StartupData {
  const StartupData({
    this.id = '',
    required this.name,
    required this.description,
    required this.stage,
    required this.tokenValue,
    required this.tokenPrice,
    required this.variation,
    required this.imageUrl,
    required this.sector,
    required this.totalTokens,
    required this.raisedCapital,
    required this.executiveSummary,
    required this.founders,
    required this.ownershipStructure,
    required this.mentorsCouncil,
    required this.demoVideoUrl,
    this.publicQaItems = const <PublicQaItem>[],
    this.tokenHistory = const <double>[],
  });

  final String id;
  final String name;
  final String description;
  final String stage;
  final String tokenValue;
  final double tokenPrice;
  final String variation;
  final String imageUrl;
  final String sector;
  final int totalTokens;
  final String raisedCapital;
  final String executiveSummary;
  final String founders;
  final String ownershipStructure;
  final String mentorsCouncil;
  final String demoVideoUrl;
  final List<PublicQaItem> publicQaItems;
  final List<double> tokenHistory;

  factory StartupData.fromApi(Map<String, dynamic> source) {
    final name = _readString(source, 'name') ?? 'Startup sem nome';
    final description =
        _readString(source, 'description') ?? 'Sem descricao disponivel.';
    final stage = _normalizeStage(_readString(source, 'stage'));
    final tokenPrice = _readDouble(source, 'tokenPrice');
    final tokenHistory = _readTokenHistory(source);
    final variationText = _resolveVariation(
      explicitVariation: _readString(source, 'variation'),
      tokenHistory: tokenHistory,
    );

    return StartupData(
      id: _readString(source, 'id') ?? _slugFromName(name),
      name: name,
      description: description,
      stage: stage,
      tokenValue: _formatCurrency(tokenPrice),
      tokenPrice: tokenPrice,
      variation: variationText,
      imageUrl: _readString(source, 'imageUrl') ?? '',
      sector: _readString(source, 'sector') ?? 'Nao informado',
      totalTokens: _readInt(source, 'totalTokens'),
      raisedCapital: _readString(source, 'raisedCapital') ?? _formatCurrency(0),
      executiveSummary: _readString(source, 'executiveSummary') ?? description,
      founders: _readString(source, 'founders') ?? '',
      ownershipStructure: _readString(source, 'ownershipStructure') ?? '',
      mentorsCouncil: _readString(source, 'mentorsCouncil') ?? '',
      demoVideoUrl: _readString(source, 'demoVideoUrl') ?? '',
      publicQaItems: _readPublicQaItems(source),
      tokenHistory: tokenHistory,
    );
  }

  static String _resolveVariation({
    required String? explicitVariation,
    required List<double> tokenHistory,
  }) {
    if (tokenHistory.length >= 2) {
      final previous = tokenHistory[tokenHistory.length - 2];
      final current = tokenHistory[tokenHistory.length - 1];
      if (previous > 0) {
        final percent = ((current - previous) / previous) * 100;
        final formatted = percent.toStringAsFixed(2);
        return percent >= 0 ? '+$formatted%' : '$formatted%';
      }
    }

    final value = explicitVariation?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return '+0.00%';
  }

  static List<double> _readTokenHistory(Map<String, dynamic> source) {
    final raw = source['tokenHistory'];
    if (raw is! List) {
      return const <double>[];
    }
    return raw
        .map((item) => item is num ? item.toDouble() : null)
        .whereType<double>()
        .where((item) => item > 0)
        .toList(growable: false);
  }

  static List<PublicQaItem> _readPublicQaItems(Map<String, dynamic> source) {
    final dynamic values =
        source['publicQaItems'] ??
        source['publicQuestions'] ??
        source['publicFaqs'];

    if (values is! List) {
      return const <PublicQaItem>[];
    }

    return values
        .whereType<Map>()
        .map((value) => Map<String, dynamic>.from(value))
        .map(PublicQaItem.fromApi)
        .where((item) => item.question.isNotEmpty || item.answer.isNotEmpty)
        .toList(growable: false);
  }

  static String? _readString(Map<String, dynamic> source, String key) {
    final value = source[key];
    return value is String ? value.trim() : null;
  }

  static double _readDouble(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  static int _readInt(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  static String _normalizeStage(String? stage) {
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

  static String _formatCurrency(double value) {
    final fixed = value.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $fixed';
  }

  static String _slugFromName(String value) {
    final slug = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'startup' : slug;
  }
}

class PublicQaItem {
  const PublicQaItem({required this.question, required this.answer});

  final String question;
  final String answer;

  factory PublicQaItem.fromApi(Map<String, dynamic> source) {
    final question = _readString(source, 'question') ?? '';
    final answer = _readString(source, 'answer') ?? '';

    return PublicQaItem(question: question, answer: answer);
  }

  static String? _readString(Map<String, dynamic> source, String key) {
    final value = source[key];
    return value is String ? value.trim() : null;
  }
}
