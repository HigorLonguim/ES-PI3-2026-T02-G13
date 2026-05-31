// Autoria: Felipe Sousa - RA: 22018160

import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/navigation/app_route.dart';
import '../../../core/theme/mescla_colors.dart';
import '../../../core/widgets/app_status_indicator.dart';
import '../data/portfolio_store.dart';
import '../data/mock_startup_repository.dart';
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
  final TextEditingController _privateQuestionController =
      TextEditingController();
  PortfolioStore get _portfolioStore => PortfolioStore.instance;
  final StartupRepository _startupRepository = StartupRepository();
  late StartupData _currentStartup;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _currentStartup = widget.startup;
    _portfolioStore.hydrate();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _refreshStartupData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _privateQuestionController.dispose();
    super.dispose();
  }

  Future<void> _refreshStartupData() async {
    try {
      final startups = await _startupRepository.fetchStartups(
        useMockFallback: false,
      );
      final startupId = _currentStartup.id.trim();
      final matched = startups
          .where((item) {
            if (startupId.isNotEmpty && item.id.trim() == startupId) {
              return true;
            }
            return item.name.trim().toLowerCase() ==
                _currentStartup.name.trim().toLowerCase();
          })
          .toList(growable: false);
      if (!mounted || matched.isEmpty) {
        return;
      }
      setState(() {
        _currentStartup = matched.first;
      });
    } catch (_) {}
  }

  Future<void> _sendPrivateQuestion() async {
    final result = await _portfolioStore.sendPrivateQuestion(
      startup: _currentStartup,
      question: _privateQuestionController.text,
    );
    if (!mounted) {
      return;
    }

    showAppStatusSnackBar(
      context: context,
      message: result.message,
      type: result.success ? AppStatusType.success : AppStatusType.error,
    );

    if (result.success) {
      _privateQuestionController.clear();
    }
  }

  Future<void> _openDemoVideo() async {
    final rawUrl = _currentStartup.demoVideoUrl.trim();
    if (rawUrl.isEmpty) {
      showAppStatusSnackBar(
        context: context,
        message: 'Video demonstrativo indisponivel para esta startup.',
        type: AppStatusType.warning,
      );
      return;
    }

    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      showAppStatusSnackBar(
        context: context,
        message: 'Link do video invalido.',
        type: AppStatusType.error,
      );
      return;
    }

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => _VideoPlayerDialog(videoUri: uri),
    );
  }

  @override
  Widget build(BuildContext context) {
    final founderEntries = _parseFounderEntries(
      _currentStartup.founders,
      _currentStartup.ownershipStructure,
    );
    final mentors = _parseSimpleList(_currentStartup.mentorsCouncil);
    final ownershipSlices = _buildOwnershipSlices(
      _currentStartup.ownershipStructure,
      founderEntries,
    );
    final publicQaItems = _currentStartup.publicQaItems;

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
                        _StartupHeader(startup: _currentStartup),
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
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: _TokenChart(
                              tokenHistory: _currentStartup.tokenHistory,
                              currentTokenPrice: _currentStartup.tokenPrice,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _InfoStatCard(
                              width: 157.2,
                              title: 'Total de Tokens',
                              value: _currentStartup.totalTokens
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
                              value: _currentStartup.raisedCapital,
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
                            _currentStartup.executiveSummary,
                            style: const TextStyle(
                              color: MesclaColors.textSecondary,
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle(title: 'Video Demonstrativo'),
                          const SizedBox(height: 10),
                          _VideoDemoCard(
                            videoUrl: _currentStartup.demoVideoUrl,
                            startupName: _currentStartup.name,
                            onTap: _openDemoVideo,
                          ),
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
                          _PitchDemoLink(
                            videoUrl: _currentStartup.demoVideoUrl,
                            startupName: _currentStartup.name,
                            onTap: _openDemoVideo,
                          ),
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
                        if (_showPublicQuestions)
                          AnimatedBuilder(
                            animation: _portfolioStore,
                            builder: (context, _) {
                              final isInvestor = _portfolioStore
                                  .isInvestorForStartup(_currentStartup);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionTitle(
                                    title: 'Perguntas e Respostas Publicas',
                                    icon: Icons.forum_rounded,
                                  ),
                                  const SizedBox(height: 10),
                                  _PublicQaCard(items: publicQaItems),
                                  const SizedBox(height: 16),
                                  _PrivateQuestionCard(
                                    controller: _privateQuestionController,
                                    canSend: isInvestor,
                                    onSend: _sendPrivateQuestion,
                                  ),
                                ],
                              );
                            },
                          ),
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
                              startup: _currentStartup,
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

class _PrivateQuestionCard extends StatelessWidget {
  const _PrivateQuestionCard({
    required this.controller,
    required this.canSend,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool canSend;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: MesclaColors.navActive),
              SizedBox(width: 8),
              Text(
                'Pergunta Privada',
                style: TextStyle(
                  color: MesclaColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            canSend
                ? 'Envie uma pergunta exclusiva para esta startup.'
                : 'Disponivel apenas para usuarios que ja investiram nesta startup.',
            style: const TextStyle(
              color: MesclaColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 3,
            enabled: canSend,
            style: const TextStyle(color: MesclaColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Digite sua pergunta privada',
              hintStyle: const TextStyle(color: MesclaColors.textTertiary),
              filled: true,
              fillColor: MesclaColors.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: MesclaColors.border),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: MesclaColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: MesclaColors.navActive),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canSend ? onSend : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: MesclaColors.navActive,
                foregroundColor: Colors.white,
                disabledBackgroundColor: MesclaColors.surfaceStrong,
              ),
              icon: const Icon(Icons.send_rounded),
              label: const Text('Enviar pergunta privada'),
            ),
          ),
        ],
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
  const _VideoDemoCard({
    required this.videoUrl,
    required this.startupName,
    required this.onTap,
  });

  final String videoUrl;
  final String startupName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
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
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Video demonstrativo da startup $startupName',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: MesclaColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
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
  const _PitchDemoLink({
    required this.videoUrl,
    required this.startupName,
    required this.onTap,
  });

  final String videoUrl;
  final String startupName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
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
                  videoUrl.trim().isEmpty
                      ? 'Ver video demonstrativo'
                      : 'Ver video demonstrativo da startup $startupName',
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
        ),
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

class _VideoPlayerDialog extends StatefulWidget {
  const _VideoPlayerDialog({required this.videoUri});

  final Uri videoUri;

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeFuture;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(widget.videoUri);
    _initializeFuture = _controller.initialize().then((_) {
      _controller.play();
      if (!mounted) {
        return;
      }
      setState(() {
        _isPlaying = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() {
        _isPlaying = false;
      });
      return;
    }

    _controller.play();
    setState(() {
      _isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: MesclaColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Video demonstrativo',
              style: TextStyle(
                color: MesclaColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<void>(
              future: _initializeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: MesclaColors.textPrimary,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Nao foi possivel carregar o video.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: MesclaColors.textSecondary),
                      ),
                    ),
                  );
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio <= 0
                        ? 16 / 9
                        : _controller.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_controller),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.1),
                          ),
                          child: const SizedBox.expand(),
                        ),
                        IconButton(
                          onPressed: _togglePlayPause,
                          iconSize: 48,
                          color: Colors.white,
                          icon: Icon(
                            _isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
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

class _TokenChart extends StatefulWidget {
  const _TokenChart({
    required this.tokenHistory,
    required this.currentTokenPrice,
  });

  final List<double> tokenHistory;
  final double currentTokenPrice;

  @override
  State<_TokenChart> createState() => _TokenChartState();
}

class _TokenChartState extends State<_TokenChart> {
  int? _selectedIndex;

  List<double> get _series {
    if (widget.tokenHistory.isNotEmpty) {
      return widget.tokenHistory;
    }
    final base = widget.currentTokenPrice > 0 ? widget.currentTokenPrice : 1.0;
    return <double>[
      base * 0.96,
      base * 0.98,
      base * 0.99,
      base * 1.01,
      base * 1.0,
      base * 1.02,
      base,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final labels = _buildVisibleHourLabels(_series.length);
    final selected = _selectedIndex != null ? _series[_selectedIndex!] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selected != null)
          Text(
            'R\$ ${selected.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (selected != null) const SizedBox(height: 8),
        Expanded(
          child: GestureDetector(
            onPanDown: (details) => _selectByDx(details.localPosition.dx),
            onPanUpdate: (details) => _selectByDx(details.localPosition.dx),
            onPanEnd: (_) => setState(() => _selectedIndex = null),
            child: CustomPaint(
              painter: _TokenLinePainter(
                values: _series,
                selectedIndex: _selectedIndex,
              ),
              child: Container(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels
              .map(
                (label) => Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: _ChartLabel(label),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }

  void _selectByDx(double dx) {
    final chartWidth = context.size?.width ?? 1.0;
    final safeWidth = chartWidth <= 0 ? 1.0 : chartWidth;
    final ratio = (dx / safeWidth).clamp(0.0, 1.0);
    final index = (ratio * (_series.length - 1)).round().clamp(
      0,
      _series.length - 1,
    );
    setState(() => _selectedIndex = index);
  }

  List<String> _buildVisibleHourLabels(int count) {
    const maxLabels = 6;
    final safeCount = count.clamp(2, 2000);
    final now = DateTime.now();
    if (safeCount <= maxLabels) {
      return List<String>.generate(safeCount, (index) {
        final hour = now.subtract(Duration(hours: safeCount - 1 - index)).hour;
        return '${hour.toString().padLeft(2, '0')}:00';
      });
    }

    return List<String>.generate(maxLabels, (labelIndex) {
      final ratio = labelIndex / (maxLabels - 1);
      final pointIndex = (ratio * (safeCount - 1)).round();
      final hour = now
          .subtract(Duration(hours: safeCount - 1 - pointIndex))
          .hour;
      return '${hour.toString().padLeft(2, '0')}:00';
    });
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
  const _TokenLinePainter({required this.values, required this.selectedIndex});

  final List<double> values;
  final int? selectedIndex;

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

    final min = values.reduce(math.min);
    final max = values.reduce(math.max);
    final diff = (max - min).abs() < 0.001 ? 1.0 : max - min;
    final points = List<Offset>.generate(values.length, (index) {
      final x = size.width * (index / (values.length - 1));
      final normalized = (values[index] - min) / diff;
      final y = size.height * (0.82 - (normalized * 0.64));
      return Offset(x, y);
    });

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
    if (selectedIndex != null) {
      final point = points[selectedIndex!];
      final markerPaint = Paint()..color = Colors.white;
      canvas.drawCircle(point, 4.5, markerPaint);
    }
    canvas.drawLine(
      Offset(0, size.height * 0.88),
      Offset(size.width, size.height * 0.88),
      baseLine,
    );
  }

  @override
  bool shouldRepaint(covariant _TokenLinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.selectedIndex != selectedIndex;
  }
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
