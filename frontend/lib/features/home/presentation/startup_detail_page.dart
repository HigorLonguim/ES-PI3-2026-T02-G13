// Autoria: Felipe Sousa - RA: 22018160

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/navigation/app_route.dart';
import '../../../core/theme/mescla_colors.dart';
import 'models/startup_data.dart';
import 'token_transaction_page.dart';

class StartupDetailPage extends StatefulWidget {
  const StartupDetailPage({required this.startup, super.key});

  final StartupData startup;

  @override
  State<StartupDetailPage> createState() => _StartupDetailPageState();
}

class _StartupDetailPageState extends State<StartupDetailPage> {
  bool _showPublicQuestions = false;

  @override
  Widget build(BuildContext context) {
    final founderEntries = _parseFounderEntries(
      widget.startup.founders,
      widget.startup.ownershipStructure,
    );
    final mentors = _parseSimpleList(widget.startup.mentorsCouncil);
    final ownershipSlices = _buildOwnershipSlices(
      widget.startup.ownershipStructure,
      founderEntries,
    );
    final publicQaItems = widget.startup.publicQaItems;

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
                      bottom: BorderSide(
                        color: MesclaColors.border,
                        width: 1.2,
                      ),
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
                        _StartupHeader(startup: widget.startup),
                        const SizedBox(height: 16),
                        Container(
                          height: 226,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: MesclaColors.border,
                              width: 1.2,
                            ),
                            gradient: MesclaGradients.startupCard,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: _TokenChart(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _InfoStatCard(
                              width: 157.2,
                              title: 'Total de Tokens',
                              value: widget.startup.totalTokens
                                  .toString()
                                  .replaceAllMapped(
                                    RegExp(r'\B(?=(\d{3})+(?!\d))'),
                                    (_) => '.',
                                  ),
                            ),
                            const SizedBox(width: 12),
                            _InfoStatCard(
                              width: 157.2,
                              title: 'Capital Captado',
                              value: widget.startup.raisedCapital,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showPublicQuestions = false;
                                  });
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: !_showPublicQuestions
                                        ? MesclaGradients.purpleHorizontal
                                        : null,
                                    color: !_showPublicQuestions
                                        ? null
                                        : MesclaColors.surface,
                                    border: _showPublicQuestions
                                        ? Border.all(
                                            color: MesclaColors.border,
                                            width: 1.2,
                                          )
                                        : null,
                                    boxShadow: !_showPublicQuestions
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
                                    'Sobre',
                                    style: TextStyle(
                                      color: !_showPublicQuestions
                                          ? MesclaColors.textPrimary
                                          : MesclaColors.textSecondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showPublicQuestions = true;
                                  });
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: _showPublicQuestions
                                        ? MesclaGradients.purpleHorizontal
                                        : null,
                                    color: _showPublicQuestions
                                        ? null
                                        : MesclaColors.surface,
                                    border: !_showPublicQuestions
                                        ? Border.all(
                                            color: MesclaColors.border,
                                            width: 1.2,
                                          )
                                        : null,
                                    boxShadow: _showPublicQuestions
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
                                    'Perguntas (${publicQaItems.length})',
                                    style: TextStyle(
                                      color: _showPublicQuestions
                                          ? MesclaColors.textPrimary
                                          : MesclaColors.textSecondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (!_showPublicQuestions) ...[
                          const Text(
                            'Sumario Executivo',
                            style: TextStyle(
                              color: MesclaColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.startup.executiveSummary,
                            style: const TextStyle(
                              color: MesclaColors.textSecondary,
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle(title: 'Video Demonstrativo'),
                          const SizedBox(height: 10),
                          _VideoDemoCard(videoUrl: widget.startup.demoVideoUrl),
                          const SizedBox(height: 24),
                          const _SectionTitle(
                            title: 'Socios Fundadores',
                            icon: Icons.groups_rounded,
                          ),
                          const SizedBox(height: 10),
                          _FoundersCard(entries: founderEntries),
                          const SizedBox(height: 24),
                          const _SectionTitle(
                            title: 'Mentoria e Conselho',
                            icon: Icons.school_rounded,
                          ),
                          const SizedBox(height: 10),
                          _MentorsCard(mentors: mentors),
                          const SizedBox(height: 16),
                          _PitchDemoLink(videoUrl: widget.startup.demoVideoUrl),
                          const SizedBox(height: 24),
                          const Text(
                            'Estrutura Societaria',
                            style: TextStyle(
                              color: MesclaColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _OwnershipCard(slices: ownershipSlices),
                        ],
                        if (_showPublicQuestions) ...[
                          const _SectionTitle(
                            title: 'Perguntas e Respostas Publicas',
                            icon: Icons.forum_rounded,
                          ),
                          const SizedBox(height: 10),
                          _PublicQaCard(items: publicQaItems),
                        ],
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
                            TokenTransactionPage(
                              startup: widget.startup,
                              isSell: false,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.attach_money_rounded,
                        color: Colors.white,
                      ),
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

class _PublicQaCard extends StatelessWidget {
  const _PublicQaCard({required this.items});

  final List<PublicQaItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MesclaColors.border, width: 1.2),
          gradient: MesclaGradients.startupCard,
        ),
        child: const Text(
          'Ainda nao ha perguntas publicas cadastradas para esta startup.',
          style: TextStyle(
            color: MesclaColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
      ),
      child: Column(
        children: items
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final item = entry.value;
              final hasDivider = index < items.length - 1;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: hasDivider
                    ? const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: MesclaColors.border,
                            width: 1.2,
                          ),
                        ),
                      )
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'P: ${item.question}',
                      style: const TextStyle(
                        color: MesclaColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'R: ${item.answer}',
                      style: const TextStyle(
                        color: MesclaColors.textSecondary,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.icon});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null)
          Icon(icon, size: 16, color: MesclaColors.textSecondary),
        if (icon != null) const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: MesclaColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoDemoCard extends StatelessWidget {
  const _VideoDemoCard({required this.videoUrl});

  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 184,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: MesclaGradients.purpleHorizontal,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: MesclaColors.textPrimary,
              size: 30,
            ),
          ),
          if (videoUrl.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                videoUrl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: MesclaColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FoundersCard extends StatelessWidget {
  const _FoundersCard({required this.entries});

  final List<_FounderEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
      ),
      child: Column(
        children: entries
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final founder = entry.value;
              final hasDivider = index < entries.length - 1;

              return Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: hasDivider
                    ? const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: MesclaColors.border,
                            width: 1.2,
                          ),
                        ),
                      )
                    : null,
                child: Row(
                  children: [
                    _InitialAvatar(text: founder.name),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        founder.name,
                        style: const TextStyle(
                          color: Color(0xFFD1D5DC),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      founder.percentage,
                      style: const TextStyle(
                        color: Color(0xFF7C86FF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _MentorsCard extends StatelessWidget {
  const _MentorsCard({required this.mentors});

  final List<String> mentors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: mentors
            .map(
              (mentor) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  mentor,
                  style: const TextStyle(
                    color: Color(0xFFD1D5DC),
                    fontSize: 14,
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _PitchDemoLink extends StatelessWidget {
  const _PitchDemoLink({required this.videoUrl});

  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0x1A615FFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x66615FFF), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.open_in_new_rounded,
            color: Color(0xFF7C86FF),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              videoUrl.trim().isEmpty ? 'Ver Pitch / Demo' : videoUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF7C86FF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cleanText = text.trim();
    final initial = cleanText.isEmpty
        ? '?'
        : cleanText.substring(0, 1).toUpperCase();

    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: MesclaGradients.purpleHorizontal,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: MesclaColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
          child: CustomPaint(painter: _TokenLinePainter(), child: Container()),
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
      Offset(size.width * 0.17, size.height * 0.66),
      Offset(size.width * 0.3, size.height * 0.72),
      Offset(size.width * 0.48, size.height * 0.67),
      Offset(size.width * 0.66, size.height * 0.64),
      Offset(size.width * 0.83, size.height * 0.58),
      Offset(size.width * 0.98, size.height * 0.60),
    ];

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final control = Offset((previous.dx + current.dx) / 2, previous.dy);
      final control2 = Offset((previous.dx + current.dx) / 2, current.dy);
      linePath.cubicTo(
        control.dx,
        control.dy,
        control2.dx,
        control2.dy,
        current.dx,
        current.dy,
      );
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
  const _InfoStatCard({required this.title, required this.value, this.width});

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
  const _OwnershipCard({required this.slices});

  final List<_OwnershipSlice> slices;

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
            child: CustomPaint(painter: _PieChartPainter(slices: slices)),
          ),
          const SizedBox(height: 12),
          ...slices.map(
            (slice) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _legendRow(
                slice.label,
                '${slice.percentage}%',
                slice.color,
              ),
            ),
          ),
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
          style: const TextStyle(
            color: MesclaColors.textSecondary,
            fontSize: 14,
          ),
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
  const _PieChartPainter({required this.slices});

  final List<_OwnershipSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide * 0.45).clamp(62.0, 86.0);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final glowPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x335F5BFF), Color(0x00242438)],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.35));
    canvas.drawCircle(center, radius * 1.35, glowPaint);

    var start = -math.pi / 2;
    for (final slice in slices) {
      final sweep = 2 * math.pi * (slice.percentage / 100);
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, start, sweep, true, paint);

      final separator = Paint()
        ..color = const Color(0xFF242438)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawArc(rect, start, sweep, true, separator);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

class _FounderEntry {
  const _FounderEntry({required this.name, required this.percentageValue});

  final String name;
  final double? percentageValue;

  String get percentage {
    if (percentageValue == null) {
      return '--';
    }

    final rounded = percentageValue!.round();
    return '$rounded%';
  }
}

class _OwnershipSlice {
  const _OwnershipSlice({
    required this.label,
    required this.percentage,
    required this.color,
  });

  final String label;
  final int percentage;
  final Color color;
}

List<_FounderEntry> _parseFounderEntries(
  String foundersRaw,
  String ownershipRaw,
) {
  final founders = _parseSimpleList(foundersRaw);
  if (founders.isEmpty) {
    return const [_FounderEntry(name: 'Nao informado', percentageValue: null)];
  }

  final explicitPercents = _extractPercentagesByName(ownershipRaw);
  final orderedPercents = _extractOrderedPercentages(ownershipRaw);

  return founders
      .asMap()
      .entries
      .map((entry) {
        final founderName = entry.value;
        final mapped = explicitPercents[founderName.toLowerCase()];
        final fallback = entry.key < orderedPercents.length
            ? orderedPercents[entry.key]
            : null;

        return _FounderEntry(
          name: founderName,
          percentageValue: mapped ?? fallback,
        );
      })
      .toList(growable: false);
}

List<String> _parseSimpleList(String raw) {
  final clean = raw.trim();
  if (clean.isEmpty) {
    return const ['Nao informado'];
  }

  final split = clean
      .split(RegExp(r'[;\n,|]'))
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);

  if (split.isEmpty) {
    return const ['Nao informado'];
  }

  return split;
}

Map<String, double> _extractPercentagesByName(String raw) {
  final matches = RegExp(
    r'([^:;|\n]+)\s*[:=-]\s*(\d{1,3}(?:[\.,]\d+)?)\s*%?',
  ).allMatches(raw);

  final map = <String, double>{};
  for (final match in matches) {
    final name = (match.group(1) ?? '').trim().toLowerCase();
    final percentageText = (match.group(2) ?? '').replaceAll(',', '.');
    final percentage = double.tryParse(percentageText);
    if (name.isEmpty || percentage == null) {
      continue;
    }
    map[name] = percentage;
  }

  return map;
}

List<double> _extractOrderedPercentages(String raw) {
  final matches = RegExp(r'(\d{1,3}(?:[\.,]\d+)?)\s*%').allMatches(raw);

  return matches
      .map((match) => (match.group(1) ?? '').replaceAll(',', '.'))
      .map(double.tryParse)
      .whereType<double>()
      .toList(growable: false);
}

List<_OwnershipSlice> _buildOwnershipSlices(
  String ownershipRaw,
  List<_FounderEntry> founders,
) {
  final founderTotal = founders
      .map((entry) => entry.percentageValue ?? 0)
      .fold<double>(0, (left, right) => left + right);
  final investors = _findCategoryPercentage(ownershipRaw, ['investidor']);
  final available = _findCategoryPercentage(ownershipRaw, [
    'disponivel',
    'disponível',
    'treasury',
  ]);

  final safeFounder = founderTotal > 0 ? founderTotal : 75;
  final safeInvestors = investors > 0 ? investors : 5;
  var safeAvailable = available > 0
      ? available
      : (100 - safeFounder - safeInvestors);

  if (safeAvailable < 0) {
    safeAvailable = 20;
  }

  final total = safeFounder + safeInvestors + safeAvailable;

  if (total <= 0) {
    return const [
      _OwnershipSlice(
        label: 'Fundadores',
        percentage: 75,
        color: Color(0xFF6366F1),
      ),
      _OwnershipSlice(
        label: 'Investidores',
        percentage: 5,
        color: Color(0xFF10B981),
      ),
      _OwnershipSlice(
        label: 'Disponivel',
        percentage: 20,
        color: Color(0xFF374151),
      ),
    ];
  }

  final founderNormalized = ((safeFounder / total) * 100).round();
  final investorsNormalized = ((safeInvestors / total) * 100).round();
  final availableNormalized = 100 - founderNormalized - investorsNormalized;

  return [
    _OwnershipSlice(
      label: 'Fundadores',
      percentage: founderNormalized,
      color: const Color(0xFF6366F1),
    ),
    _OwnershipSlice(
      label: 'Investidores',
      percentage: investorsNormalized,
      color: const Color(0xFF10B981),
    ),
    _OwnershipSlice(
      label: 'Disponivel',
      percentage: availableNormalized,
      color: const Color(0xFF374151),
    ),
  ];
}

double _findCategoryPercentage(String text, List<String> aliases) {
  final lower = text.toLowerCase();

  for (final alias in aliases) {
    final regex = RegExp('$alias[^0-9]{0,8}(\\d{1,3}(?:[\\.,]\\d+)?)\\s*%?');
    final match = regex.firstMatch(lower);
    if (match != null) {
      final parsed = double.tryParse(
        (match.group(1) ?? '').replaceAll(',', '.'),
      );
      if (parsed != null) {
        return parsed;
      }
    }
  }

  return 0;
}

class _StageStyle {
  const _StageStyle({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

const _stageStyles = <String, _StageStyle>{
  'Expansao': _StageStyle(
    background: MesclaColors.stageExpansionSoft,
    foreground: MesclaColors.stageExpansion,
  ),
  'Operacao': _StageStyle(
    background: MesclaColors.successSoft,
    foreground: MesclaColors.success,
  ),
  'Nova': _StageStyle(
    background: MesclaColors.stageNewSoft,
    foreground: MesclaColors.stageNew,
  ),
};
