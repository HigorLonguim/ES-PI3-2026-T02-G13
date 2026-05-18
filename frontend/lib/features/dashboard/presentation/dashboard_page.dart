// Autoria: Felipe Sousa - RA: 22018160

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/home/data/portfolio_store.dart';
import 'package:frontend/features/home/presentation/models/money_formatters.dart';

import '../../../core/theme/mescla_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  _ChartRange _selectedRange = _ChartRange.oneMonth;
  bool _userSelectedRange = false;

  @override
  Widget build(BuildContext context) {
    final store = PortfolioStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final hasInvestments = store.hasHoldings;
        if (!_userSelectedRange && hasInvestments) {
          _selectedRange = _ChartRange.yearToDate;
        }

        final series = _buildSeries(
          range: _selectedRange,
          hasInvestments: hasInvestments,
        );

        return Scaffold(
          backgroundColor: MesclaColors.background,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: MesclaGradients.headerFade,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _DashboardHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PortfolioValueCard(store: store),
                            const SizedBox(height: 24),
                            _HistoryCard(
                              selectedRange: _selectedRange,
                              onRangeSelected: (range) {
                                setState(() {
                                  _selectedRange = range;
                                  _userSelectedRange = true;
                                });
                              },
                              series: series,
                            ),
                            const SizedBox(height: 24),
                            _StatsCard(store: store),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              color: MesclaColors.textPrimary,
              fontSize: 36 / 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Acompanhe sua performance',
            style: TextStyle(color: MesclaColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _PortfolioValueCard extends StatelessWidget {
  const _PortfolioValueCard({required this.store});

  final PortfolioStore store;

  @override
  Widget build(BuildContext context) {
    final total = store.totalCurrentValue;
    final variationAmount = store.totalCurrentValue - store.totalInvested;
    final isPositive = variationAmount >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Valor Total do Portfólio',
            style: TextStyle(color: MesclaColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            formatCurrency(total),
            style: const TextStyle(
              color: MesclaColors.textPrimary,
              fontSize: 36 / 1.05,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      size: 20,
                      color: isPositive
                          ? MesclaColors.success
                          : MesclaColors.danger,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatPercent(store.totalVariationPercent),
                      style: TextStyle(
                        color: isPositive
                            ? MesclaColors.success
                            : MesclaColors.danger,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _formatSignedCurrency(variationAmount),
                style: TextStyle(
                  color: isPositive
                      ? MesclaColors.success
                      : MesclaColors.danger,
                  fontSize: 30 / 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.selectedRange,
    required this.onRangeSelected,
    required this.series,
  });

  final _ChartRange selectedRange;
  final ValueChanged<_ChartRange> onRangeSelected;
  final _ChartSeries series;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Histórico de Valorização',
            style: TextStyle(
              color: MesclaColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _ChartRange.values
                    .map(
                      (range) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _RangeChip(
                          range: range,
                          selected: range == selectedRange,
                          onTap: () => onRangeSelected(range),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            width: double.infinity,
            child: CustomPaint(painter: _DashboardChartPainter(series: series)),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.range,
    required this.selected,
    required this.onTap,
  });

  final _ChartRange range;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 52),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: selected ? MesclaGradients.purpleHorizontal : null,
          color: selected ? null : MesclaColors.surface,
          border: selected
              ? null
              : Border.all(color: MesclaColors.border, width: 1.2),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: MesclaColors.purpleGlow,
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          range.label,
          style: TextStyle(
            color: selected
                ? MesclaColors.textPrimary
                : MesclaColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.store});

  final PortfolioStore store;

  @override
  Widget build(BuildContext context) {
    final profit = store.totalCurrentValue - store.totalInvested;
    final isPositive = profit >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estatísticas',
            style: TextStyle(
              color: MesclaColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _statsRow('Total Investido', formatCurrency(store.totalInvested)),
          const SizedBox(height: 16),
          _statsRow('Valor Atual', formatCurrency(store.totalCurrentValue)),
          const SizedBox(height: 16),
          _statsRow('Número de Startups', '${store.holdings.length}'),
          const SizedBox(height: 16),
          Container(height: 1.2, color: MesclaColors.border),
          const SizedBox(height: 12),
          _statsRow(
            'Lucro/Prejuízo',
            _formatSignedCurrency(profit),
            labelColor: MesclaColors.textPrimary,
            valueColor: isPositive ? MesclaColors.success : MesclaColors.danger,
            valueSize: 18,
            valueWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  Widget _statsRow(
    String label,
    String value, {
    Color labelColor = MesclaColors.textSecondary,
    Color valueColor = MesclaColors.textPrimary,
    double valueSize = 16,
    FontWeight valueWeight = FontWeight.w600,
  }) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 16)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: valueSize,
            fontWeight: valueWeight,
          ),
        ),
      ],
    );
  }
}

class _DashboardChartPainter extends CustomPainter {
  const _DashboardChartPainter({required this.series});

  final _ChartSeries series;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 64.0;
    const topPadding = 8.0;
    const bottomPadding = 8.0;
    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - topPadding - bottomPadding;
    final chartRect = Rect.fromLTWH(
      leftPadding,
      topPadding,
      chartWidth,
      chartHeight,
    );

    final minValue = series.min;
    final maxValue = series.max;
    final valueDiff = math.max(1.0, maxValue - minValue);

    final axisPaint = Paint()
      ..color = const Color(0xFF4A4A5E)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(chartRect.left, chartRect.top),
      Offset(chartRect.left, chartRect.bottom),
      axisPaint,
    );

    for (final tick in series.yTicks) {
      final ratio = (tick - minValue) / valueDiff;
      final y = chartRect.bottom - (ratio * chartRect.height);
      canvas.drawLine(
        Offset(chartRect.left - 5, y),
        Offset(chartRect.left, y),
        axisPaint,
      );
      _drawText(
        canvas: canvas,
        text: '${(tick / 1000).round()}k',
        offset: Offset(0, y - 8),
        color: MesclaColors.textTertiary,
        fontSize: 12,
      );
    }

    final points = <Offset>[];
    for (var i = 0; i < series.points.length; i++) {
      final x =
          chartRect.left + (i / (series.points.length - 1)) * chartRect.width;
      final normalizedY = (series.points[i] - minValue) / valueDiff;
      final y = chartRect.bottom - (normalizedY * chartRect.height);
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final controlX = (previous.dx + current.dx) / 2;
      linePath.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    final areaPath = Path.from(linePath)
      ..lineTo(chartRect.right, chartRect.bottom)
      ..lineTo(chartRect.left, chartRect.bottom)
      ..close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0x5525DFA6), const Color(0x00242438)],
      ).createShader(chartRect);

    final linePaint = Paint()
      ..color = const Color(0xFF00D9A3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _DashboardChartPainter oldDelegate) {
    return oldDelegate.series != series;
  }

  void _drawText({
    required Canvas canvas,
    required String text,
    required Offset offset,
    required Color color,
    required double fontSize,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, offset);
  }
}

enum _ChartRange {
  oneDay('1D'),
  oneWeek('1W'),
  oneMonth('1M'),
  sixMonths('6M'),
  yearToDate('YTD');

  const _ChartRange(this.label);

  final String label;
}

class _ChartSeries {
  const _ChartSeries({required this.points, required this.yTicks});

  final List<double> points;
  final List<double> yTicks;

  double get min => points.fold<double>(
    points.first,
    (current, value) => math.min(current, value),
  );
  double get max => points.fold<double>(
    points.first,
    (current, value) => math.max(current, value),
  );

  @override
  bool operator ==(Object other) {
    if (other is! _ChartSeries) {
      return false;
    }

    return listEquals(points, other.points) && listEquals(yTicks, other.yTicks);
  }

  @override
  int get hashCode => Object.hash(points, yTicks);
}

_ChartSeries _buildSeries({
  required _ChartRange range,
  required bool hasInvestments,
}) {
  if (!hasInvestments) {
    return _seriesForNoInvestment(range);
  }

  return _seriesForInvestment(range);
}

_ChartSeries _seriesForNoInvestment(_ChartRange range) {
  const ticks = [15000.0, 30000.0, 45000.0, 60000.0];

  switch (range) {
    case _ChartRange.oneDay:
      return const _ChartSeries(
        points: [50000, 50500, 49500, 50200, 50600, 50100, 50300],
        yTicks: ticks,
      );
    case _ChartRange.oneWeek:
      return const _ChartSeries(
        points: [49000, 50000, 51000, 49800, 50200, 49500, 50000],
        yTicks: ticks,
      );
    case _ChartRange.oneMonth:
      return const _ChartSeries(
        points: [
          50000,
          50500,
          50700,
          50300,
          50000,
          50200,
          50600,
          50800,
          50900,
          51000,
          51300,
          51700,
          52000,
          51900,
          51800,
          51600,
        ],
        yTicks: ticks,
      );
    case _ChartRange.sixMonths:
      return const _ChartSeries(
        points: [48000, 49000, 50000, 51000, 50500, 50000, 49500, 50200, 51000],
        yTicks: ticks,
      );
    case _ChartRange.yearToDate:
      return const _ChartSeries(
        points: [47000, 48000, 49500, 50000, 50500, 51000, 50000, 49000, 50000],
        yTicks: ticks,
      );
  }
}

_ChartSeries _seriesForInvestment(_ChartRange range) {
  const ticks = [20000.0, 40000.0, 60000.0, 80000.0];

  switch (range) {
    case _ChartRange.oneDay:
      return const _ChartSeries(
        points: [50000, 51000, 52000, 51500, 53000, 54000, 54500],
        yTicks: ticks,
      );
    case _ChartRange.oneWeek:
      return const _ChartSeries(
        points: [50000, 50500, 51000, 51500, 52000, 52500, 53000, 53500],
        yTicks: ticks,
      );
    case _ChartRange.oneMonth:
      return const _ChartSeries(
        points: [50000, 50500, 50800, 51200, 51500, 52000, 51800, 52200, 52800],
        yTicks: ticks,
      );
    case _ChartRange.sixMonths:
      return const _ChartSeries(
        points: [48000, 49500, 50500, 51500, 52500, 53000, 54500, 55500, 56500],
        yTicks: ticks,
      );
    case _ChartRange.yearToDate:
      return const _ChartSeries(
        points: [
          50000,
          49800,
          50300,
          50100,
          50800,
          50700,
          51200,
          51000,
          51400,
          51100,
          50900,
          51800,
          51500,
          52000,
          52300,
          51900,
          52200,
          52500,
          52100,
          52800,
          53100,
          52900,
          53500,
          53200,
          53800,
          54000,
          53600,
          54200,
          54500,
          54300,
          54800,
          55000,
          54700,
          55200,
          55500,
          56000,
          56500,
          55800,
          56200,
          57000,
          57500,
          57200,
          56800,
          56000,
          55800,
          56500,
          57200,
          58000,
          57800,
          59000,
          60000,
          59800,
          60500,
          61200,
        ],
        yTicks: ticks,
      );
  }
}

String _formatSignedCurrency(double value) {
  if (value == 0) {
    return '+R\$ 0,00';
  }

  final formatted = formatCurrency(value.abs());
  return value > 0 ? '+$formatted' : '-$formatted';
}
