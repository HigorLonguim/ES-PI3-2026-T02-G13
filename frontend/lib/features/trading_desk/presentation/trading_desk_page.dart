// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/app_status_indicator.dart';
import 'package:frontend/features/home/data/trading_api_service.dart';
import 'package:frontend/features/home/presentation/models/money_formatters.dart';
import 'package:frontend/features/trading_desk/data/trading_desk_api_service.dart';

import '../../../core/theme/mescla_colors.dart';

enum _DeskTab { market, myOffers }

enum _OfferTypeFilter { all, buy, sell }

class TradingDeskPage extends StatefulWidget {
  const TradingDeskPage({super.key});

  @override
  State<TradingDeskPage> createState() => _TradingDeskPageState();
}

class _TradingDeskPageState extends State<TradingDeskPage> {
  final TradingDeskApiService _service = TradingDeskApiService();
  final TradingApiService _walletService = TradingApiService();
  _DeskTab _tab = _DeskTab.market;
  _OfferTypeFilter _typeFilter = _OfferTypeFilter.all;
  String _startupFilter = 'Todas';
  bool _isLoading = true;
  List<_DeskOffer> _marketOffers = const <_DeskOffer>[];
  List<_DeskOffer> _myOffers = const <_DeskOffer>[];
  List<TradingDeskStartup> _catalogStartups = const <TradingDeskStartup>[];
  Map<String, int> _walletHoldingsByStartup = const <String, int>{};

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  @override
  void dispose() {
    _service.dispose();
    _walletService.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);
    try {
      if (_service.hasStartupCatalogConfig) {
        try {
          _catalogStartups = await _service.listActiveStartups();
        } catch (_) {
          _catalogStartups = const <TradingDeskStartup>[];
        }
      } else {
        _catalogStartups = const <TradingDeskStartup>[];
      }

      if (_walletService.hasRemoteWalletConfig) {
        try {
          final wallet = await _walletService.fetchWallet();
          _walletHoldingsByStartup = {
            for (final holding in wallet.holdings)
              holding.startupId: holding.quantity,
          };
        } catch (_) {
          _walletHoldingsByStartup = const <String, int>{};
        }
      } else {
        _walletHoldingsByStartup = const <String, int>{};
      }

      if (_service.hasListOffersConfig) {
        final market = await _service.listMarketOffers();
        final mine = await _service.listMyOffers();
        if (!mounted) {
          return;
        }
        setState(() {
          _marketOffers = market
              .map(_DeskOffer.fromApiMarket)
              .toList(growable: false);
          _myOffers = mine.map(_DeskOffer.fromApiMine).toList(growable: false);
        });
      } else {
        _marketOffers = const <_DeskOffer>[];
        _myOffers = const <_DeskOffer>[];
      }
    } catch (error) {
      if (_service.hasListOffersConfig) {
        if (mounted) {
          showAppStatusSnackBar(
            context: context,
            message:
                _service.extractErrorMessage(error) ??
                'Falha ao carregar ofertas reais do balcao',
            type: AppStatusType.error,
          );
        }
        _marketOffers = const <_DeskOffer>[];
        _myOffers = const <_DeskOffer>[];
      } else {
        _marketOffers = const <_DeskOffer>[];
        _myOffers = const <_DeskOffer>[];
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openCreateOfferDialog() async {
    if (!_service.hasCreateOfferConfig) {
      showAppStatusSnackBar(
        context: context,
        message: 'Configure as URLs das functions para criar ofertas reais',
        type: AppStatusType.warning,
      );
      return;
    }

    final options = _startupOptions;
    if (options.isEmpty) {
      showAppStatusSnackBar(
        context: context,
        message: 'Nenhuma startup disponivel para criar oferta',
        type: AppStatusType.warning,
      );
      return;
    }

    final result = await showModalBottomSheet<_CreateOfferPayload>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => _CreateOfferDialog(
        options: options,
        walletHoldingsByStartup: _walletHoldingsByStartup,
      ),
    );

    if (result == null) {
      return;
    }

    try {
      await _service.createOffer(
        startupId: result.startupId,
        type: result.type,
        quantity: result.quantity,
        pricePerToken: result.pricePerToken,
      );
      if (!mounted) {
        return;
      }
      await _loadOffers();
      if (!mounted) {
        return;
      }
      setState(() => _tab = _DeskTab.myOffers);
      showAppStatusSnackBar(
        context: context,
        message: 'Oferta criada com sucesso',
        type: AppStatusType.success,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppStatusSnackBar(
        context: context,
        message: 'Falha ao criar oferta',
        type: AppStatusType.error,
      );
    }
  }

  Future<void> _executeOfferAction(_DeskOffer offer) async {
    if (offer.id.trim().isEmpty) {
      showAppStatusSnackBar(
        context: context,
        message:
            'Oferta sem identificador valido. Atualize a lista para carregar ofertas reais.',
        type: AppStatusType.warning,
      );
      return;
    }

    if (offer.isMine && !_service.hasCancelOfferConfig) {
      showAppStatusSnackBar(
        context: context,
        message: 'Configure a URL da function para cancelar ofertas',
        type: AppStatusType.warning,
      );
      return;
    }

    if (offer.isMine && offer.id.isNotEmpty && _service.hasCancelOfferConfig) {
      try {
        await _service.cancelOffer(offer.id);
        if (!mounted) {
          return;
        }
        await _loadOffers();
        if (!mounted) {
          return;
        }
        showAppStatusSnackBar(
          context: context,
          message: 'Oferta cancelada',
          type: AppStatusType.success,
        );
      } catch (_) {
        if (!mounted) {
          return;
        }
        showAppStatusSnackBar(
          context: context,
          message: 'Falha ao cancelar oferta',
          type: AppStatusType.error,
        );
      }
      return;
    }

    if (!_service.hasAcceptOfferConfig) {
      showAppStatusSnackBar(
        context: context,
        message:
            'Configure a URL da function para executar ofertas reais do balcao',
        type: AppStatusType.warning,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (dialogContext) => _OfferConfirmDialog(offer: offer),
    );
    if (confirmed != true) {
      return;
    }

    try {
      await _service.acceptOffer(offer.id);
      if (!mounted) {
        return;
      }
      await _loadOffers();
      if (!mounted) {
        return;
      }
      showAppStatusSnackBar(
        context: context,
        message: offer.type == _OfferType.sell
            ? 'Compra executada com sucesso'
            : 'Venda executada com sucesso',
        type: AppStatusType.success,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message =
          _service.extractErrorMessage(error) ??
          'Falha ao executar oferta real do balcao';
      showAppStatusSnackBar(
        context: context,
        message: message,
        type: AppStatusType.error,
      );
    }
  }

  List<_DeskOffer> get _offers {
    final base = _tab == _DeskTab.market ? _marketOffers : _myOffers;

    return base
        .where((offer) {
          final typeOk =
              _typeFilter == _OfferTypeFilter.all ||
              (_typeFilter == _OfferTypeFilter.buy &&
                  offer.type == _OfferType.buy) ||
              (_typeFilter == _OfferTypeFilter.sell &&
                  offer.type == _OfferType.sell);
          final startupOk =
              _startupFilter == 'Todas' || offer.startupName == _startupFilter;
          return typeOk && startupOk;
        })
        .toList(growable: false);
  }

  int get _activeOffersCount => _offers.length;

  double get _marketVolume => _offers.fold(
    0,
    (total, offer) => total + (offer.quantity * offer.pricePerToken),
  );

  List<String> get _startupFilters {
    final merged = <_DeskOffer>[..._marketOffers, ..._myOffers];
    final startups = merged.map((e) => e.startupName).toSet().toList()..sort();
    return <String>['Todas', ...startups];
  }

  List<_StartupOption> get _startupOptions {
    if (_catalogStartups.isNotEmpty) {
      final values =
          _catalogStartups
              .map(
                (startup) => _StartupOption(
                  id: startup.id,
                  name: startup.name,
                  currentPrice: startup.tokenPrice,
                  category: startup.sector,
                ),
              )
              .toList(growable: false)
            ..sort((a, b) => a.name.compareTo(b.name));
      return values;
    }

    final merged = <_DeskOffer>[..._marketOffers, ..._myOffers];
    final byId = <String, _StartupOption>{};
    for (final offer in merged) {
      if (offer.startupId.isEmpty || offer.startupName.isEmpty) {
        continue;
      }
      byId[offer.startupId] = _StartupOption(
        id: offer.startupId,
        name: offer.startupName,
        currentPrice: offer.pricePerToken,
        category: _startupCategoryFor(offer.startupName),
      );
    }

    final values = byId.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return values;
  }

  @override
  Widget build(BuildContext context) {
    final myOffersCount = _myOffers.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0118),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MesclaColors.purpleStart,
        onPressed: _openCreateOfferDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: MesclaGradients.headerFade),
              ),
            ),
            Positioned(
              top: 520,
              right: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  color: Color(0x147B61FF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _DeskHeader(),
                  const SizedBox(height: 16),
                  _DeskMetrics(
                    activeOffers: _activeOffersCount,
                    marketVolume: _marketVolume,
                  ),
                  const SizedBox(height: 16),
                  _DeskTabs(
                    tab: _tab,
                    myOffersCount: myOffersCount,
                    onTabChanged: (value) => setState(() => _tab = value),
                  ),
                  const SizedBox(height: 16),
                  _DeskFilters(
                    typeFilter: _typeFilter,
                    startupFilter: _startupFilter,
                    startupOptions: _startupFilters,
                    onTypeChanged: (value) =>
                        setState(() => _typeFilter = value),
                    onStartupChanged: (value) =>
                        setState(() => _startupFilter = value),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _offers.isEmpty
                        ? RefreshIndicator(
                            onRefresh: _loadOffers,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 92),
                              children: const [
                                SizedBox(height: 120),
                                Center(
                                  child: Text(
                                    'Nao ha ofertas disponiveis no momento',
                                    style: TextStyle(
                                      color: MesclaColors.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    'Puxe para atualizar ou crie uma nova oferta.',
                                    style: TextStyle(
                                      color: MesclaColors.textTertiary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadOffers,
                            child: ListView.separated(
                              padding: const EdgeInsets.only(bottom: 92),
                              itemCount: _offers.length,
                              separatorBuilder: (_, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final offer = _offers[index];
                                return _OfferCard(
                                  offer: offer,
                                  onAction: () => _executeOfferAction(offer),
                                );
                              },
                            ),
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

class _DeskHeader extends StatelessWidget {
  const _DeskHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Row(
          children: [
            _GlowIcon(icon: Icons.swap_horiz_rounded),
            SizedBox(width: 12),
            Text(
              'Balcão de Negociacão',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Ofertas simuladas de compra e venda de tokens',
          style: TextStyle(color: MesclaColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}

class _DeskMetrics extends StatelessWidget {
  const _DeskMetrics({required this.activeOffers, required this.marketVolume});

  final int activeOffers;
  final double marketVolume;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'Ofertas ativas',
            value: activeOffers.toString(),
            valueColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: 'Volume no mercado',
            value: formatCurrency(marketVolume),
            valueColor: const Color(0xFF7B61FF),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  final String title;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0x0DFFFFFF),
        border: Border.all(color: const Color(0x14FFFFFF), width: 1.2),
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
            style: TextStyle(
              color: valueColor,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeskTabs extends StatelessWidget {
  const _DeskTabs({
    required this.tab,
    required this.myOffersCount,
    required this.onTabChanged,
  });

  final _DeskTab tab;
  final int myOffersCount;
  final ValueChanged<_DeskTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Mercado',
              selected: tab == _DeskTab.market,
              onTap: () => onTabChanged(_DeskTab.market),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabButton(
              label: 'Minhas Ofertas',
              selected: tab == _DeskTab.myOffers,
              badge: tab == _DeskTab.myOffers && myOffersCount > 0
                  ? '$myOffersCount'
                  : null,
              onTap: () => onTabChanged(_DeskTab.myOffers),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: selected ? MesclaGradients.purpleHorizontal : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : MesclaColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeskFilters extends StatelessWidget {
  const _DeskFilters({
    required this.typeFilter,
    required this.startupFilter,
    required this.startupOptions,
    required this.onTypeChanged,
    required this.onStartupChanged,
  });

  final _OfferTypeFilter typeFilter;
  final String startupFilter;
  final List<String> startupOptions;
  final ValueChanged<_OfferTypeFilter> onTypeChanged;
  final ValueChanged<String> onStartupChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_outlined,
            color: MesclaColors.textSecondary,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Todas',
            selected: typeFilter == _OfferTypeFilter.all,
            onTap: () => onTypeChanged(_OfferTypeFilter.all),
          ),
          _FilterChip(
            label: '▲ Compra',
            selected: typeFilter == _OfferTypeFilter.buy,
            onTap: () => onTypeChanged(_OfferTypeFilter.buy),
          ),
          _FilterChip(
            label: '▼ Venda',
            selected: typeFilter == _OfferTypeFilter.sell,
            onTap: () => onTypeChanged(_OfferTypeFilter.sell),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 30, color: const Color(0x1AFFFFFF)),
          const SizedBox(width: 10),
          ...startupOptions.map(
            (startup) => _FilterChip(
              label: startup,
              selected: startupFilter == startup,
              onTap: () => onStartupChanged(startup),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0x405B4BFF) : const Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0x665B4BFF)
                  : const Color(0x14FFFFFF),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF7B61FF)
                  : MesclaColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer, required this.onAction});

  final _DeskOffer offer;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final isBuy = offer.type == _OfferType.buy;
    final isBuyingAction = offer.type == _OfferType.sell;
    final tagBackground = isBuy
        ? const Color(0x3300BC7D)
        : const Color(0x33FF2056);
    final tagForeground = isBuy
        ? const Color(0xFF00D492)
        : const Color(0xFFFF637E);
    final buttonGradient = isBuyingAction
        ? const LinearGradient(colors: [Color(0xFF009966), Color(0xFF00BC7D)])
        : const LinearGradient(colors: [Color(0xFFEC003F), Color(0xFFFF2056)]);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14FFFFFF), width: 1.2),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16112E), Color(0xFF1C1535)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  offer.imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, stackTrace) => Container(
                    width: 40,
                    height: 40,
                    color: MesclaColors.surfaceStrong,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 16,
                      color: MesclaColors.textTertiary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          offer.startupName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: tagBackground,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isBuy ? '▲ COMPRA' : '▼ VENDA',
                            style: TextStyle(
                              color: tagForeground,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${offer.timeAgo} atrás  ·  ${offer.userName}',
                      style: const TextStyle(
                        color: MesclaColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OfferMetricCard(
                  title: 'Quantidade',
                  value: offer.quantity.toString(),
                  footer: 'tokens',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OfferMetricCard(
                  title: 'Preco/token',
                  value: formatCurrency(offer.pricePerToken),
                  valueColor: tagForeground,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OfferMetricCard(
                  title: 'Total',
                  value: formatCurrency(offer.quantity * offer.pricePerToken),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: offer.isMine ? 42 : 40,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(
                offer.isMine
                    ? Icons.close_rounded
                    : isBuy
                    ? Icons.call_made_rounded
                    : Icons.call_received_rounded,
                size: 16,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: offer.isMine ? const Color(0x0DFFFFFF) : null,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: offer.isMine
                      ? const BorderSide(color: Color(0x1AFFFFFF), width: 1.2)
                      : BorderSide.none,
                ),
                padding: EdgeInsets.zero,
              ),
              label: Ink(
                decoration: offer.isMine
                    ? null
                    : BoxDecoration(
                        gradient: buttonGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    offer.isMine
                        ? 'Cancelar oferta'
                        : isBuy
                        ? 'Vender para este usuario'
                        : 'Comprar deste usuario',
                    style: TextStyle(
                      color: offer.isMine
                          ? MesclaColors.textSecondary
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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

class _OfferMetricCard extends StatelessWidget {
  const _OfferMetricCard({
    required this.title,
    required this.value,
    this.valueColor = Colors.white,
    this.footer,
  });

  final String title;
  final String value;
  final Color valueColor;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: MesclaColors.textTertiary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (footer != null)
            Text(
              footer!,
              style: const TextStyle(
                color: MesclaColors.textTertiary,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}

class _OfferConfirmDialog extends StatelessWidget {
  const _OfferConfirmDialog({required this.offer});

  final _DeskOffer offer;

  @override
  Widget build(BuildContext context) {
    final isBuying = offer.type == _OfferType.sell;
    final title = isBuying ? 'Confirmar Compra' : 'Confirmar Venda';
    final subtitle = isBuying
        ? 'Você comprará ${offer.quantity} tokens de ${offer.startupName} de ${offer.userName}'
        : 'Você venderá ${offer.quantity} tokens de ${offer.startupName} para ${offer.userName}';
    final accent = isBuying
        ? const [Color(0xFF009966), Color(0xFF00BC7D)]
        : const [Color(0xFFEC003F), Color(0xFFFF2056)];
    final iconBg = isBuying ? const Color(0x3300BC7D) : const Color(0x33FF2056);
    final icon = isBuying
        ? Icons.call_made_rounded
        : Icons.call_received_rounded;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x1AFFFFFF), width: 1.2),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1035), Color(0xFF0A0118)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MesclaColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _ConfirmRow(label: 'Startup', value: offer.startupName),
            _ConfirmRow(label: 'Quantidade', value: '${offer.quantity} tokens'),
            _ConfirmRow(
              label: 'Preço/token',
              value: formatCurrency(offer.pricePerToken),
            ),
            _ConfirmRow(
              label: 'Total',
              value: formatCurrency(offer.quantity * offer.pricePerToken),
              isLast: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0x1AFFFFFF),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: MesclaColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(colors: accent),
                        ),
                        child: const Center(
                          child: Text(
                            'Confirmar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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
          ],
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0x0DFFFFFF), width: 1.2),
        ),
      ),
      child: Row(
        children: [
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
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowIcon extends StatelessWidget {
  const _GlowIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: MesclaGradients.purple,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: MesclaColors.purpleGlow,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}

class _StartupOption {
  const _StartupOption({
    required this.id,
    required this.name,
    required this.currentPrice,
    required this.category,
  });

  final String id;
  final String name;
  final double currentPrice;
  final String category;
}

class _CreateOfferPayload {
  const _CreateOfferPayload({
    required this.startupId,
    required this.type,
    required this.quantity,
    required this.pricePerToken,
  });

  final String startupId;
  final String type;
  final int quantity;
  final double pricePerToken;
}

class _CreateOfferDialog extends StatefulWidget {
  const _CreateOfferDialog({
    required this.options,
    required this.walletHoldingsByStartup,
  });

  final List<_StartupOption> options;
  final Map<String, int> walletHoldingsByStartup;

  @override
  State<_CreateOfferDialog> createState() => _CreateOfferDialogState();
}

class _CreateOfferDialogState extends State<_CreateOfferDialog> {
  late String _startupId;
  String _type = 'BUY';
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startupId = widget.options.first.id;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.options.firstWhere((s) => s.id == _startupId);
    final quantity = int.tryParse(_quantityController.text.trim());
    final price = double.tryParse(
      _priceController.text.trim().replaceAll(',', '.'),
    );
    final canSubmit =
        quantity != null && quantity > 0 && price != null && price > 0;
    final buyMode = _type == 'BUY';
    final maxSellTokens = widget.walletHoldingsByStartup[_startupId] ?? 0;
    final exceedsSellLimit =
        !buyMode && quantity != null && quantity > maxSellTokens;
    final canPublish = canSubmit && !exceedsSellLimit;

    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0x1AFFFFFF), width: 1.2)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1035), Color(0xFF0A0118)],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nova Oferta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0x1AFFFFFF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close,
                        color: MesclaColors.textSecondary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0x0DFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TradeTypeButton(
                        label: '▲ Compra',
                        selected: buyMode,
                        buy: true,
                        onTap: () => setState(() => _type = 'BUY'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TradeTypeButton(
                        label: '▼ Venda',
                        selected: !buyMode,
                        buy: false,
                        onTap: () => setState(() => _type = 'SELL'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Startup',
                style: TextStyle(
                  color: Color(0xFFD1D5DC),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _startupId,
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: MesclaColors.textSecondary,
                decoration: _newOfferFieldDecoration(),
                items: widget.options
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option.id,
                        child: Text(option.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _startupId = value);
                },
              ),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: MesclaColors.textTertiary,
                    fontSize: 12,
                  ),
                  children: [
                    const TextSpan(text: 'Preco atual: '),
                    TextSpan(
                      text: formatCurrency(selected.currentPrice),
                      style: const TextStyle(color: Color(0xFF7B61FF)),
                    ),
                    TextSpan(text: ' · ${selected.category}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Quantidade de tokens',
                style: TextStyle(
                  color: Color(0xFFD1D5DC),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _newOfferFieldDecoration(hint: 'Ex: 100'),
                onChanged: (_) => setState(() {}),
              ),
              if (!buyMode) ...[
                const SizedBox(height: 6),
                Text(
                  'Maximo para venda: $maxSellTokens tokens',
                  style: TextStyle(
                    color: exceedsSellLimit
                        ? const Color(0xFFFF637E)
                        : MesclaColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Preco por token (R\$)',
                style: TextStyle(
                  color: Color(0xFFD1D5DC),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: Colors.white),
                decoration: _newOfferFieldDecoration(hint: 'Ex: 1.50'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Opacity(
                  opacity: canPublish ? 1 : 0.3,
                  child: ElevatedButton(
                    onPressed: canPublish
                        ? () {
                            Navigator.of(context).pop(
                              _CreateOfferPayload(
                                startupId: _startupId,
                                type: _type,
                                quantity: quantity,
                                pricePerToken: price,
                              ),
                            );
                          }
                        : () {
                            final message = exceedsSellLimit
                                ? 'Quantidade para venda excede seus tokens disponiveis'
                                : 'Preencha quantidade e preco validos';
                            showAppStatusSnackBar(
                              context: context,
                              message: message,
                              type: AppStatusType.warning,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: buyMode
                            ? const LinearGradient(
                                colors: [Color(0xFF009966), Color(0xFF00BC7D)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFFEC003F), Color(0xFFFF2056)],
                              ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.call_made_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              buyMode
                                  ? 'Publicar oferta de compra'
                                  : 'Publicar oferta de venda',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

InputDecoration _newOfferFieldDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: MesclaColors.textTertiary, fontSize: 16),
    filled: true,
    fillColor: const Color(0xFF1A1A2E),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0x667B61FF), width: 1.2),
    ),
  );
}

class _TradeTypeButton extends StatelessWidget {
  const _TradeTypeButton({
    required this.label,
    required this.selected,
    required this.buy,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool buy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: selected
              ? LinearGradient(
                  colors: buy
                      ? const [Color(0xFF009966), Color(0xFF00BC7D)]
                      : const [Color(0xFFEC003F), Color(0xFFFF2056)],
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : MesclaColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

String _startupCategoryFor(String startupName) {
  switch (startupName) {
    case 'EcoLoop':
      return 'Cleantech';
    case 'VitalTrack':
      return 'Healthtech';
    case 'EduVibe':
      return 'Edtech';
    case 'SafePay':
      return 'Fintech';
    case 'AgroSense':
      return 'Agtech';
    default:
      return 'Startup';
  }
}

enum _OfferType { buy, sell }

class _DeskOffer {
  const _DeskOffer({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.imageUrl,
    required this.type,
    required this.userName,
    required this.timeAgo,
    required this.quantity,
    required this.pricePerToken,
    required this.isMine,
  });

  final String id;
  final String startupId;
  final String startupName;
  final String imageUrl;
  final _OfferType type;
  final String userName;
  final String timeAgo;
  final int quantity;
  final double pricePerToken;
  final bool isMine;

  factory _DeskOffer.fromApiMarket(TradingDeskOffer offer) {
    return _DeskOffer(
      id: offer.id,
      startupId: offer.startupId,
      startupName: offer.startupName,
      imageUrl: offer.startupImageUrl,
      type: offer.type == 'SELL' ? _OfferType.sell : _OfferType.buy,
      userName: offer.userName,
      timeAgo: _relativeTimeLabel(offer.createdAtIso),
      quantity: offer.quantity,
      pricePerToken: offer.pricePerToken,
      isMine: false,
    );
  }

  factory _DeskOffer.fromApiMine(TradingDeskOffer offer) {
    return _DeskOffer(
      id: offer.id,
      startupId: offer.startupId,
      startupName: offer.startupName,
      imageUrl: offer.startupImageUrl,
      type: offer.type == 'SELL' ? _OfferType.sell : _OfferType.buy,
      userName: 'Minha oferta',
      timeAgo: _relativeTimeLabel(offer.createdAtIso),
      quantity: offer.quantity,
      pricePerToken: offer.pricePerToken,
      isMine: true,
    );
  }
}

String _relativeTimeLabel(String? isoDate) {
  if (isoDate == null || isoDate.trim().isEmpty) {
    return '0min';
  }

  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) {
    return '0min';
  }

  final now = DateTime.now().toUtc();
  final created = parsed.toUtc();
  final diff = now.difference(created);
  if (diff.inMinutes < 1) {
    return '0min';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}min';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h';
  }
  return '${diff.inDays}d';
}
