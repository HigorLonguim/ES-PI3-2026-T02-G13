// Autoria: Felipe Sousa - RA: 22018160

class StartupData {
  const StartupData({
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
  });

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

  factory StartupData.fromApi(Map<String, dynamic> source) {
    final name = _readString(source, 'name') ?? 'Startup sem nome';
    final description =
        _readString(source, 'description') ?? 'Sem descricao disponivel.';
    final stage = _normalizeStage(_readString(source, 'stage'));
    final tokenPrice = _readDouble(source, 'tokenPrice');

    return StartupData(
      name: name,
      description: description,
      stage: stage,
      tokenValue:
          _readString(source, 'tokenValue') ?? _formatCurrency(tokenPrice),
      tokenPrice: tokenPrice,
      variation: _readString(source, 'variation') ?? '+0.00%',
      imageUrl: _readString(source, 'imageUrl') ?? '',
      sector: _readString(source, 'sector') ?? 'Nao informado',
      totalTokens: _readInt(source, 'totalTokens'),
      raisedCapital: _readString(source, 'raisedCapital') ?? _formatCurrency(0),
      executiveSummary: _readString(source, 'executiveSummary') ?? description,
      founders: _readString(source, 'founders') ?? '',
      ownershipStructure: _readString(source, 'ownershipStructure') ?? '',
      mentorsCouncil: _readString(source, 'mentorsCouncil') ?? '',
      demoVideoUrl: _readString(source, 'demoVideoUrl') ?? '',
    );
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
}
