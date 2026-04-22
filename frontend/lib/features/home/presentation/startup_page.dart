// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';
import 'package:frontend/core/auth/auth_session_storage.dart';

import '../../../core/navigation/app_route.dart';
import '../../../core/theme/mescla_colors.dart';
import '../data/mock_startup_repository.dart';
import 'models/startup_data.dart';
import 'startup_detail_page.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({this.onProfileTap, super.key});

  final VoidCallback? onProfileTap;

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _filterScrollController = ScrollController();
  final ScrollController _startupsScrollController = ScrollController();
  final StartupRepository _startupRepository = StartupRepository();
  final AuthSessionStorage _authSessionStorage = AuthSessionStorage();

  String _selectedFilter = 'Todas';
  List<StartupData> _allStartups = const [];
  String _userName = 'Usuario';

  @override
  void initState() {
    super.initState();
    _loadStartups();
    _loadUserProfile();
  }

  Future<void> _loadStartups() async {
    final startups = await _startupRepository.fetchStartups();
    if (!mounted) {
      return;
    }

    setState(() {
      _allStartups = startups;
    });
  }

  Future<void> _loadUserProfile() async {
    final nome = (await _authSessionStorage.getUserName())?.trim();
    if (!mounted || nome == null || nome.isEmpty) {
      return;
    }

    setState(() {
      _userName = nome;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterScrollController.dispose();
    _startupsScrollController.dispose();
    super.dispose();
  }

  List<StartupData> get _filteredStartups {
    final query = _searchController.text.trim().toLowerCase();

    return _allStartups.where((startup) {
      final matchesFilter =
          _selectedFilter == 'Todas' ||
          startup.stage == _filterToStage(_selectedFilter);
      final matchesSearch =
          query.isEmpty ||
          startup.name.toLowerCase().contains(query) ||
          startup.description.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  String _filterToStage(String filter) {
    switch (filter) {
      case 'Novas':
        return 'Nova';
      case 'Em Operacao':
        return 'Operacao';
      case 'Em Expansao':
        return 'Expansao';
      default:
        return filter;
    }
  }

  @override
  Widget build(BuildContext context) {
    const filters = ['Todas', 'Novas', 'Em Operacao', 'Em Expansao'];
    final startups = _filteredStartups;
    final firstName = _userName.split(' ').first.trim();
    final avatarLetter = firstName.isNotEmpty
        ? firstName.substring(0, 1).toUpperCase()
        : 'U';

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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, $firstName',
                              style: TextStyle(
                                color: MesclaColors.textPrimary,
                                fontSize: 24,
                                height: 1.1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Explore oportunidades',
                              style: TextStyle(
                                color: MesclaColors.textSecondary,
                                fontSize: 14,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => widget.onProfileTap?.call(),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: MesclaGradients.purple,
                            boxShadow: [
                              BoxShadow(
                                color: MesclaColors.purpleGlow,
                                blurRadius: 15,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            avatarLetter,
                            style: const TextStyle(
                              color: MesclaColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: MesclaColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: MesclaColors.border,
                        width: 1.2,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                        color: MesclaColors.textPrimary,
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: MesclaColors.textTertiary,
                        ),
                        hintText: 'Buscar startups...',
                        hintStyle: TextStyle(
                          color: MesclaColors.textTertiary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    controller: _filterScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filters.map((filter) {
                        final isSelected = filter == _selectedFilter;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedFilter = filter),
                            child: Container(
                              height: 42,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: isSelected
                                    ? MesclaGradients.purpleHorizontal
                                    : null,
                                color: isSelected ? null : MesclaColors.surface,
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: MesclaColors.border,
                                        width: 1.2,
                                      ),
                                boxShadow: isSelected
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
                                filter,
                                style: TextStyle(
                                  color: isSelected
                                      ? MesclaColors.textPrimary
                                      : MesclaColors.textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: startups.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhuma startup encontrada',
                              style: TextStyle(
                                color: MesclaColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: _startupsScrollController,
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: startups.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return _StartupCard(
                                data: startups[index],
                                onTap: () {
                                  Navigator.of(context).push(
                                    AppRoute(
                                      StartupDetailPage(
                                        startup: startups[index],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupCard extends StatelessWidget {
  const _StartupCard({required this.data, required this.onTap});

  final StartupData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stageStyle = _stageStyles[data.stage] ?? _stageStyles['Nova']!;
    final isPositive = data.variation.startsWith('+');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: MesclaColors.border, width: 1.2),
            gradient: MesclaGradients.startupCard,
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 15,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.network(
                    data.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, error, stackTrace) => Container(
                      color: MesclaColors.border,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: MesclaColors.textTertiary,
                      ),
                    ),
                  ),
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
                            data.name,
                            style: const TextStyle(
                              color: MesclaColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: stageStyle.background,
                          ),
                          child: Text(
                            data.stage,
                            style: TextStyle(
                              color: stageStyle.foreground,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.description,
                      style: const TextStyle(
                        color: MesclaColors.textSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Valor do token',
                                style: TextStyle(
                                  color: MesclaColors.textTertiary,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                data.tokenValue,
                                style: const TextStyle(
                                  color: MesclaColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isPositive
                                ? MesclaColors.successSoft
                                : MesclaColors.dangerSoft,
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
                                data.variation,
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
        ),
      ),
    );
  }
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

