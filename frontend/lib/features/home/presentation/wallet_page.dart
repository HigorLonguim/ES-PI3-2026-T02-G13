// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';

import '../../../core/navigation/app_route.dart';
import '../../../core/theme/mescla_colors.dart';
import '../data/portfolio_store.dart';
import 'add_balance_page.dart';
import 'models/money_formatters.dart';
import 'token_transaction_page.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({required this.onExploreStartups, super.key});

  final VoidCallback onExploreStartups;

  @override
  Widget build(BuildContext context) {
    final store = PortfolioStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
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
                    _WalletHeader(balance: store.balance),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InvestmentSummary(store: store),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                const Text(
                                  'Meus Tokens',
                                  style: TextStyle(
                                    color: MesclaColors.textPrimary,
                                    fontSize: 31 / 2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.history,
                                    color: MesclaColors.navActive,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Histórico',
                                    style: TextStyle(
                                      color: MesclaColors.navActive,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (!store.hasHoldings)
                              _EmptyPortfolioCard(onExploreStartups: onExploreStartups),
                            if (store.hasHoldings)
                              ...store.holdings.map(
                                (holding) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _HoldingCard(holding: holding),
                                ),
                              ),
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

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MesclaColors.purpleStart, MesclaColors.purpleEnd],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.credit_card_outlined, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                'Saldo Disponível',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48 / 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x4DFFFFFF), width: 1.2),
              ),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(AppRoute(const AddBalancePage()));
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Adicionar Saldo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 31 / 2,
                    fontWeight: FontWeight.w600,
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

class _InvestmentSummary extends StatelessWidget {
  const _InvestmentSummary({required this.store});

  final PortfolioStore store;

  @override
  Widget build(BuildContext context) {
    final variation = store.totalVariationPercent;
    final isPositive = variation >= 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Resumo de Investimentos',
                  style: TextStyle(
                    color: MesclaColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: MesclaColors.successSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: MesclaColors.success,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryValue(
                  'Investido',
                  formatCurrency(store.totalInvested),
                ),
              ),
              Expanded(
                child: _summaryValue(
                  'Valor Atual',
                  formatCurrency(store.totalCurrentValue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Variação Total',
                style: TextStyle(color: MesclaColors.textTertiary, fontSize: 12),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isPositive ? MesclaColors.successSoft : MesclaColors.dangerSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 16,
                      color: isPositive ? MesclaColors.success : MesclaColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatPercent(variation),
                      style: TextStyle(
                        color: isPositive ? MesclaColors.success : MesclaColors.danger,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: MesclaColors.textTertiary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: MesclaColors.textPrimary,
            fontSize: 32 / 2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyPortfolioCard extends StatelessWidget {
  const _EmptyPortfolioCard({required this.onExploreStartups});

  final VoidCallback onExploreStartups;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MesclaColors.surface,
                border: Border.all(color: MesclaColors.border, width: 1.2),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: MesclaColors.textTertiary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum investimento ainda',
              style: TextStyle(
                color: MesclaColors.textPrimary,
                fontSize: 32 / 1.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Comece a investir em startups promissoras e acompanhe seu portfólio aqui',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MesclaColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: MesclaGradients.purpleHorizontal,
                ),
                child: TextButton(
                  onPressed: onExploreStartups,
                  child: const Text(
                    'Explorar Startups',
                    style: TextStyle(
                      color: MesclaColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({required this.holding});

  final PortfolioHolding holding;

  @override
  Widget build(BuildContext context) {
    final isPositive = holding.profit >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  holding.startup.imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
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
                            holding.startup.name,
                            style: const TextStyle(
                              color: MesclaColors.textPrimary,
                              fontSize: 32 / 1.9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isPositive
                                ? MesclaColors.successSoft
                                : MesclaColors.dangerSoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            formatPercent((holding.startup.tokenPrice / holding.averagePrice - 1) * 100),
                            style: TextStyle(
                              color: isPositive
                                  ? MesclaColors.success
                                  : MesclaColors.danger,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _itemDetail(
                            'Quantidade',
                            '${holding.quantity} tokens',
                          ),
                        ),
                        Expanded(
                          child: _itemDetail(
                            'Valor Total',
                            formatCurrency(holding.totalValue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _itemDetail(
                      'Lucro/Prejuízo',
                      '${holding.profit >= 0 ? '+' : ''}${formatCurrency(holding.profit)}',
                      valueColor: isPositive
                          ? MesclaColors.success
                          : MesclaColors.danger,
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
                child: _ActionHoldingButton(
                  label: 'Comprar Mais',
                  isPrimary: true,
                  onPressed: () {
                    Navigator.of(context).push(
                      AppRoute(
                        TokenTransactionPage(
                          startup: holding.startup,
                          isSell: false,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionHoldingButton(
                  label: 'Vender',
                  isPrimary: false,
                  onPressed: () {
                    Navigator.of(context).push(
                      AppRoute(
                        TokenTransactionPage(
                          startup: holding.startup,
                          isSell: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemDetail(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: MesclaColors.textTertiary, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? MesclaColors.textPrimary,
            fontSize: 30 / 2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionHoldingButton extends StatelessWidget {
  const _ActionHoldingButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isPrimary
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF00A63E), Color(0xFF009966)],
                )
              : null,
          color: isPrimary ? null : MesclaColors.surface,
          border: isPrimary
              ? null
              : Border.all(color: const Color(0x4DFB2C36), width: 1.2),
        ),
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(
              color: isPrimary ? Colors.white : MesclaColors.danger,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

