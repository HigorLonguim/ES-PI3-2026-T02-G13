// Autoria: Felipe Sousa - RA: 22018160

import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/home/data/portfolio_store.dart';
import 'package:frontend/features/home/data/mock_startup_repository.dart';
import 'package:frontend/features/home/presentation/models/money_formatters.dart';

import '../../../core/theme/mescla_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  _ChartRange _selectedRange = _ChartRange.oneHour;
  bool _userSelectedRange = false;
  final List<_ChartSample> _fallbackSamples = <_ChartSample>[];
  final StartupRepository _startupRepository = StartupRepository();
  Map<String, List<double>> _tokenHistoryByStartup = <String, List<double>>{};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refreshData(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final store = PortfolioStore.instance;
    await store.hydrate();
    await _refreshTokenHistories();
    _captureFallbackSample();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshTokenHistories() async {
    try {
      final startups = await _startupRepository.fetchStartups(
        useMockFallback: false,
      );
      final map = <String, List<double>>{};
      for (final startup in startups) {
        if (startup.id.trim().isEmpty || startup.tokenHistory.isEmpty) {
          continue;
        }
        map[startup.id.trim()] = startup.tokenHistory;
      }
      _tokenHistoryByStartup = map;
    } catch (_) {}
  }

  void _captureFallbackSample() {
    final value = PortfolioStore.instance.totalCurrentValue;
    final now = DateTime.now();
    if (_fallbackSamples.isNotEmpty &&
        now.difference(_fallbackSamples.last.timestamp).inSeconds < 10) {
      return;
    }
    _fallbackSamples.add(_ChartSample(timestamp: now, value: value));
    if (_fallbackSamples.length > 400) {
      _fallbackSamples.removeAt(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = PortfolioStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final hasInvestments = store.hasHoldings;
        if (!_userSelectedRange && hasInvestments) {
          _selectedRange = _ChartRange.oneHour;
        }

        final series = _buildSeries(
          range: _selectedRange,
          holdings: store.holdings,
          tokenHistoryByStartup: _tokenHistoryByStartup,
          fallbackSamples: _fallbackSamples,
          currentValue: store.totalCurrentValue,
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

class _HistoryCard extends StatefulWidget {
  const _HistoryCard({
    required this.selectedRange,
    required this.onRangeSelected,
    required this.series,
  });

  final _ChartRange selectedRange;
  final ValueChanged<_ChartRange> onRangeSelected;
  final _ChartSeries series;

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  int? _selectedIndex;

  void _selectByPosition(Offset localPosition, double width) {
    if (widget.series.points.isEmpty) {
      return;
    }
    const leftPadding = 64.0;
    final usableWidth = math.max(1.0, width - leftPadding);
    final x = (localPosition.dx - leftPadding).clamp(0.0, usableWidth);
    final ratio = x / usableWidth;
    final index = (ratio * (widget.series.points.length - 1)).round().clamp(
      0,
      widget.series.points.length - 1,
    );
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final selectedValue =
        _selectedIndex == null ||
            _selectedIndex! < 0 ||
            _selectedIndex! >= widget.series.points.length
        ? null
        : widget.series.points[_selectedIndex!];
    final selectedLabel =
        _selectedIndex == null ||
            _selectedIndex! < 0 ||
            _selectedIndex! >= widget.series.labels.length
        ? null
        : widget.series.labels[_selectedIndex!];

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
                          selected: range == widget.selectedRange,
                          onTap: () => widget.onRangeSelected(range),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (selectedValue != null) ...[
            Text(
              formatCurrency(selectedValue),
              style: const TextStyle(
                color: MesclaColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (selectedLabel != null && selectedLabel.isNotEmpty)
              Text(
                selectedLabel,
                style: const TextStyle(
                  color: MesclaColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            height: 280,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                onTapDown: (details) => _selectByPosition(
                  details.localPosition,
                  constraints.maxWidth,
                ),
                onPanDown: (details) => _selectByPosition(
                  details.localPosition,
                  constraints.maxWidth,
                ),
                onPanUpdate: (details) => _selectByPosition(
                  details.localPosition,
                  constraints.maxWidth,
                ),
                onPanEnd: (_) => setState(() => _selectedIndex = null),
                child: CustomPaint(
                  painter: _DashboardChartPainter(
                    series: widget.series,
                    selectedIndex: _selectedIndex,
                  ),
                ),
              ),
            ),
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
  const _DashboardChartPainter({
    required this.series,
    required this.selectedIndex,
  });

  final _ChartSeries series;
  final int? selectedIndex;

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
        text: _formatTickLabel(tick),
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

    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < points.length) {
      final selectedPoint = points[selectedIndex!];
      final indicatorPaint = Paint()
        ..color = const Color(0xFF9EF7DA)
        ..strokeWidth = 1.1;
      canvas.drawLine(
        Offset(selectedPoint.dx, chartRect.top),
        Offset(selectedPoint.dx, chartRect.bottom),
        indicatorPaint,
      );
      canvas.drawCircle(
        selectedPoint,
        5,
        Paint()..color = const Color(0xFF00D9A3),
      );
      canvas.drawCircle(
        selectedPoint,
        2.5,
        Paint()..color = MesclaColors.textPrimary,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashboardChartPainter oldDelegate) {
    return oldDelegate.series != series ||
        oldDelegate.selectedIndex != selectedIndex;
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

String _formatTickLabel(double value) {
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}k';
  }
  return value.toStringAsFixed(0);
}

enum _ChartRange {
  tenMinutes('10M'),
  thirtyMinutes('30M'),
  oneHour('1H'),
  sixHours('6H'),
  oneDay('24H');

  const _ChartRange(this.label);

  final String label;
}

class _ChartSeries {
  const _ChartSeries({
    required this.points,
    required this.yTicks,
    this.labels = const <String>[],
  });

  final List<double> points;
  final List<double> yTicks;
  final List<String> labels;

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

    return listEquals(points, other.points) &&
        listEquals(yTicks, other.yTicks) &&
        listEquals(labels, other.labels);
  }

  @override
  int get hashCode => Object.hash(points, yTicks, labels);
}

_ChartSeries _buildSeries({
  required _ChartRange range,
  required List<PortfolioHolding> holdings,
  required Map<String, List<double>> tokenHistoryByStartup,
  required List<_ChartSample> fallbackSamples,
  required double currentValue,
}) {
  final realSamples = _buildPortfolioHistorySamples(
    holdings: holdings,
    tokenHistoryByStartup: tokenHistoryByStartup,
  );
  final filtered = _samplesForRange(
    range,
    realSamples.isNotEmpty ? realSamples : fallbackSamples,
  );
  if (filtered.length >= 2) {
    final points = filtered
        .map((sample) => sample.value)
        .toList(growable: false);
    final labels = filtered
        .map((sample) => _formatSampleTime(sample.timestamp))
        .toList(growable: false);
    return _ChartSeries(
      points: points,
      yTicks: _buildTicks(points),
      labels: labels,
    );
  }

  if (currentValue >= 0) {
    final now = DateTime.now();
    final seed = <double>[
      currentValue == 0 ? 0 : currentValue * 0.98,
      currentValue == 0 ? 0 : currentValue * 0.99,
      currentValue,
    ];
    final labels = <String>[
      _formatSampleTime(now.subtract(const Duration(seconds: 20))),
      _formatSampleTime(now.subtract(const Duration(seconds: 10))),
      _formatSampleTime(now),
    ];
    return _ChartSeries(
      points: seed,
      yTicks: _buildTicks(seed),
      labels: labels,
    );
  }
  return const _ChartSeries(
    points: <double>[0, 0],
    yTicks: <double>[0, 1],
    labels: <String>['--:--', '--:--'],
  );
}

List<_ChartSample> _samplesForRange(_ChartRange range, List<_ChartSample> all) {
  if (all.isEmpty) {
    return const <_ChartSample>[];
  }
  final now = DateTime.now();
  final Duration window = switch (range) {
    _ChartRange.tenMinutes => const Duration(minutes: 10),
    _ChartRange.thirtyMinutes => const Duration(minutes: 30),
    _ChartRange.oneHour => const Duration(hours: 1),
    _ChartRange.sixHours => const Duration(hours: 6),
    _ChartRange.oneDay => const Duration(hours: 24),
  };
  final minTime = now.subtract(window);
  final filtered = all
      .where((sample) => sample.timestamp.isAfter(minTime))
      .toList(growable: false);
  return filtered;
}

List<_ChartSample> _buildPortfolioHistorySamples({
  required List<PortfolioHolding> holdings,
  required Map<String, List<double>> tokenHistoryByStartup,
}) {
  if (holdings.isEmpty || tokenHistoryByStartup.isEmpty) {
    return const <_ChartSample>[];
  }

  var minLength = 1 << 30;
  final participating = <({PortfolioHolding holding, List<double> history})>[];
  for (final holding in holdings) {
    final startupId = holding.startup.id.trim();
    if (startupId.isEmpty) {
      continue;
    }
    final history = tokenHistoryByStartup[startupId];
    if (history == null || history.isEmpty) {
      continue;
    }
    participating.add((holding: holding, history: history));
    if (history.length < minLength) {
      minLength = history.length;
    }
  }

  if (participating.isEmpty || minLength <= 0) {
    return const <_ChartSample>[];
  }

  final now = DateTime.now();
  final samples = <_ChartSample>[];
  for (var i = 0; i < minLength; i++) {
    var total = 0.0;
    for (final entry in participating) {
      final history = entry.history;
      final price = history[history.length - minLength + i];
      total += price * entry.holding.quantity;
    }
    final timestamp = now.subtract(Duration(minutes: minLength - 1 - i));
    samples.add(_ChartSample(timestamp: timestamp, value: total));
  }

  return samples;
}

List<double> _buildTicks(List<double> points) {
  final minValue = points.reduce(math.min);
  final maxValue = points.reduce(math.max);
  if (minValue == 0 && maxValue == 0) {
    return const <double>[0, 0.25, 0.5, 1];
  }
  if ((maxValue - minValue).abs() < 1) {
    return [minValue * 0.97, minValue * 0.99, minValue * 1.01, minValue * 1.03];
  }
  final step = (maxValue - minValue) / 3;
  return [minValue, minValue + step, minValue + (step * 2), maxValue];
}

String _formatSampleTime(DateTime timestamp) {
  final hour = timestamp.hour.toString().padLeft(2, '0');
  final minute = timestamp.minute.toString().padLeft(2, '0');
  final second = timestamp.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
}

class _ChartSample {
  const _ChartSample({required this.timestamp, required this.value});

  final DateTime timestamp;
  final double value;
}

String _formatSignedCurrency(double value) {
  if (value == 0) {
    return '+R\$ 0,00';
  }

  final formatted = formatCurrency(value.abs());
  return value > 0 ? '+$formatted' : '-$formatted';
}
