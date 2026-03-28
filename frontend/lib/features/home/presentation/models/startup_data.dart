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
}
