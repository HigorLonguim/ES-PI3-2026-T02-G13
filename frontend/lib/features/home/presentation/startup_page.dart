// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';

import '../../../core/theme/mescla_colors.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _filterScrollController = ScrollController();

  String _selectedFilter = 'Todas';

  final List<_StartupData> _startups = const [
    _StartupData(
      name: 'TechFlow',
      description: 'Plataforma de automação para e-commerce',
      stage: 'Expansão',
      tokenValue: 'R\$ 125.50',
      variation: '+12.50%',
      imageUrl:
          'https://www.figma.com/api/mcp/asset/6ab3a4a1-55c3-40a1-854b-82fda3a66a82',
    ),
    _StartupData(
      name: 'GreenEnergy',
      description: 'Soluções em energia solar residencial',
      stage: 'Operação',
      tokenValue: 'R\$ 85.30',
      variation: '+5.20%',
      imageUrl:
          'https://www.figma.com/api/mcp/asset/398eb24d-fe8f-4800-bfbf-4f45c5664cf5',
    ),
    _StartupData(
      name: 'HealthAI',
      description: 'Diagnóstico médico assistido por IA',
      stage: 'Nova',
      tokenValue: 'R\$ 50.00',
      variation: '-2.30%',
      imageUrl:
          'https://www.figma.com/api/mcp/asset/da02914f-fcbe-44ad-ad89-4d1b9070b0c8',
    ),
    _StartupData(
      name: 'EduTech Pro',
      description: 'Ensino online personalizado para empresas',
      stage: 'Operação',
      tokenValue: 'R\$ 95.75',
      variation: '+8.10%',
      imageUrl:
          'https://www.figma.com/api/mcp/asset/5bb39f20-9628-4caf-b3de-f2e3ea1c1a7f',
    ),
    _StartupData(
      name: 'FoodChain',
      description: 'Rastreabilidade blockchain para alimentos',
      stage: 'Nova',
      tokenValue: 'R\$ 42.80',
      variation: '+15.70%',
      imageUrl:
          'https://www.figma.com/api/mcp/asset/15655d0b-dfa4-4a5f-a7fe-7c9c1157e7ed',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _filterScrollController.dispose();
    super.dispose();
  }

  List<_StartupData> get _filteredStartups {
    final query = _searchController.text.trim().toLowerCase();

    return _startups.where((startup) {
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
      case 'Em Operação':
        return 'Operação';
      case 'Em Expansão':
        return 'Expansão';
      default:
        return filter;
    }
  }

  @override
  Widget build(BuildContext context) {
    const filters = ['Todas', 'Novas', 'Em Operação', 'Em Expansão'];
    final startups = _filteredStartups;

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
            ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Olá, João',
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
                    Container(
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
                      child: const Text(
                        'J',
                        style: TextStyle(
                          color: MesclaColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
                    border: Border.all(color: MesclaColors.border, width: 1.2),
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
                          onTap: () => setState(() => _selectedFilter = filter),
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                if (startups.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: Center(
                      child: Text(
                        'Nenhuma startup encontrada',
                        style: TextStyle(
                          color: MesclaColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else
                  ...startups.map(
                    (startup) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _StartupCard(data: startup),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupCard extends StatelessWidget {
  const _StartupCard({required this.data});

  final _StartupData data;

  @override
  Widget build(BuildContext context) {
    final stageStyle = _stageStyles[data.stage] ?? _stageStyles['Nova']!;
    final isPositive = data.variation.startsWith('+');

    return Container(
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
    );
  }
}

class _StartupData {
  const _StartupData({
    required this.name,
    required this.description,
    required this.stage,
    required this.tokenValue,
    required this.variation,
    required this.imageUrl,
  });

  final String name;
  final String description;
  final String stage;
  final String tokenValue;
  final String variation;
  final String imageUrl;
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
