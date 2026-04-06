// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';

import '../../../core/navigation/app_route.dart';
import '../../../core/theme/mescla_colors.dart';
import 'models/startup_data.dart';
import 'token_transaction_page.dart';

class StartupDetailPage extends StatelessWidget {
  const StartupDetailPage({required this.startup, super.key});

  final StartupData startup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MesclaColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: MesclaGradients.headerFade),
              ),
            ),
            Column(
              children: [
                Container(
                  height: 73.2,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 1.2),
                  decoration: const BoxDecoration(
                    color: Color(0xCC1A1A2E),
                    border: Border(
                      bottom: BorderSide(color: MesclaColors.border, width: 1.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 39.992,
                        height: 39.992,
                        decoration: const BoxDecoration(
                          color: MesclaColors.surfaceStrong,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: MesclaColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StartupHeader(startup: startup),
                        const SizedBox(height: 16),
                        Container(
                          height: 226,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: MesclaColors.border, width: 1.2),
                            gradient: MesclaGradients.startupCard,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: _TokenChart(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _InfoStatCard(
                              width: 157.2,
                              title: 'Total de Tokens',
                              value: startup.totalTokens.toString().replaceAllMapped(
                                RegExp(r'\B(?=(\d{3})+(?!\d))'),
                                (_) => '.',
                              ),
                            ),
                            const SizedBox(width: 12),
                            _InfoStatCard(
                              width: 157.2,
                              title: 'Capital Captado',
                              value: startup.raisedCapital,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: MesclaGradients.purpleHorizontal,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: MesclaColors.purpleGlow,
                                      blurRadius: 15,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Sobre',
                                  style: TextStyle(
                                    color: MesclaColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: MesclaColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: MesclaColors.border,
                                    width: 1.2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Perguntas (0)',
                                  style: TextStyle(
                                    color: MesclaColors.textSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Sumário Executivo',
                          style: TextStyle(
                            color: MesclaColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          startup.executiveSummary,
                          style: const TextStyle(
                            color: MesclaColors.textSecondary,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Estrutura Societária',
                          style: TextStyle(
                            color: MesclaColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const _OwnershipCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: const BoxDecoration(
                  color: Color(0xCC1A1A2E),
                  border: Border(
                    top: BorderSide(color: MesclaColors.border, width: 1.2),
                  ),
                ),
                child: SizedBox(
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF00A63E), Color(0xFF009966)],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 201, 80, 0.2),
                          blurRadius: 15,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          AppRoute(
                            TokenTransactionPage(startup: startup, isSell: false),
                          ),
                        );
                      },
                      icon: const Icon(Icons.attach_money_rounded, color: Colors.white),
                      label: const Text(
                        'Comprar Tokens',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupHeader extends StatelessWidget {
  const _StartupHeader({required this.startup});

  final StartupData startup;

  @override
  Widget build(BuildContext context) {
    final stageStyle = _stageStyles[startup.stage] ?? _stageStyles['Nova']!;
    final isPositive = startup.variation.startsWith('+');

    return SizedBox(
      height: 116,
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            startup.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 80,
                color: MesclaColors.surfaceStrong,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.business_rounded,
                  color: MesclaColors.textSecondary,
                  size: 30,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      startup.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MesclaColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: stageStyle.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      startup.stage,
                      style: TextStyle(
                        color: stageStyle.foreground,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                startup.sector,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: MesclaColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Token',
                          style: TextStyle(
                            color: MesclaColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          startup.tokenValue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: MesclaColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? MesclaColors.successSoft
                          : MesclaColors.dangerSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPositive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 16,
                          color: isPositive
                              ? MesclaColors.success
                              : MesclaColors.danger,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          startup.variation,
                          style: TextStyle(
                            color: isPositive
                                ? MesclaColors.success
                                : MesclaColors.danger,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
    );
  }
}

class _TokenChart extends StatelessWidget {
  const _TokenChart();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: _TokenLinePainter(),
            child: Container(),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ChartLabel('10:00'),
            _ChartLabel('11:00'),
            _ChartLabel('12:00'),
            _ChartLabel('13:00'),
            _ChartLabel('14:00'),
            _ChartLabel('15:00'),
          ],
        ),
      ],
    );
  }
}

class _ChartLabel extends StatelessWidget {
  const _ChartLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFF6A6A7A), fontSize: 10),
    );
  }
}

class _TokenLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final areaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x6644D17A), Color(0x00242438)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = const Color(0xFF00E7AF)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final baseLine = Paint()
      ..color = const Color(0xFF4A4A5E)
      ..strokeWidth = 1.2;

    final points = [
      Offset(size.width * 0.02, size.height * 0.68),
      Offset(size.width * 0.17, size.height * 0.52),
      Offset(size.width * 0.3, size.height * 0.84),
      Offset(size.width * 0.48, size.height * 0.58),
      Offset(size.width * 0.66, size.height * 0.44),
      Offset(size.width * 0.83, size.height * 0.12),
      Offset(size.width * 0.98, size.height * 0.24),
    ];

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final control = Offset((previous.dx + current.dx) / 2, previous.dy);
      final control2 = Offset((previous.dx + current.dx) / 2, current.dy);
      linePath.cubicTo(control.dx, control.dy, control2.dx, control2.dy, current.dx, current.dy);
    }

    final areaPath = Path.from(linePath)
      ..lineTo(size.width, size.height * 0.88)
      ..lineTo(0, size.height * 0.88)
      ..close();

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(linePath, linePaint);
    canvas.drawLine(
      Offset(0, size.height * 0.88),
      Offset(size.width, size.height * 0.88),
      baseLine,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InfoStatCard extends StatelessWidget {
  const _InfoStatCard({
    required this.title,
    required this.value,
    this.width,
  });

  final String title;
  final String value;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 78.4),
      padding: const EdgeInsets.fromLTRB(17.2, 17.2, 17.2, 11.2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: MesclaColors.textTertiary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: MesclaColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnershipCard extends StatelessWidget {
  const _OwnershipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 192,
            width: double.infinity,
            child: CustomPaint(painter: _PieChartPainter()),
          ),
          const SizedBox(height: 12),
          _legendRow('Fundadores', '60%', const Color(0xFF6366F1)),
          const SizedBox(height: 8),
          _legendRow('Investidores', '25%', const Color(0xFF10B981)),
          const SizedBox(height: 8),
          _legendRow('Disponível', '15%', const Color(0xFF374151)),
        ],
      ),
    );
  }

  Widget _legendRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: MesclaColors.textSecondary, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: MesclaColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide * 0.45).clamp(62.0, 86.0);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final glowPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x335F5BFF), Color(0x00242438)],
        stops: [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 1.35),
      );
    canvas.drawCircle(center, radius * 1.35, glowPaint);

    const slices = [
      _Slice(0.60, Color(0xFF6366F1)),
      _Slice(0.25, Color(0xFF10B981)),
      _Slice(0.15, Color(0xFF374151)),
    ];

    var start = -1.57079632679;
    for (final slice in slices) {
      final sweep = 6.28318530718 * slice.fraction;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        rect,
        start,
        sweep,
        true,
        paint,
      );

      final separator = Paint()
        ..color = const Color(0xFF242438)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawArc(rect, start, sweep, true, separator);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Slice {
  const _Slice(this.fraction, this.color);

  final double fraction;
  final Color color;
}

class _StageStyle {
  const _StageStyle({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

const _stageStyles = <String, _StageStyle>{
  'Expansão': _StageStyle(
    background: MesclaColors.stageExpansionSoft,
    foreground: MesclaColors.stageExpansion,
  ),
  'Operação': _StageStyle(
    background: MesclaColors.successSoft,
    foreground: MesclaColors.success,
  ),
  'Nova': _StageStyle(
    background: MesclaColors.stageNewSoft,
    foreground: MesclaColors.stageNew,
  ),
};
