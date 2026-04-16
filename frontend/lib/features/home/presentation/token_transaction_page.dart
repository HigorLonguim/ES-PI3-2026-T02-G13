// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';

import '../../../core/navigation/app_route.dart';
import '../../../core/widgets/app_status_indicator.dart';
import '../../../core/theme/mescla_colors.dart';
import '../data/portfolio_store.dart';
import 'models/money_formatters.dart';
import 'models/startup_data.dart';
import 'transaction_success_page.dart';

class TokenTransactionPage extends StatefulWidget {
  const TokenTransactionPage({
    required this.startup,
    required this.isSell,
    super.key,
  });

  final StartupData startup;
  final bool isSell;

  @override
  State<TokenTransactionPage> createState() => _TokenTransactionPageState();
}

class _TokenTransactionPageState extends State<TokenTransactionPage> {
  int _quantity = 1;

  PortfolioStore get _store => PortfolioStore.instance;

  int get _maxSellQuantity {
    final holding = _store.holdingFor(widget.startup.name);
    return holding?.quantity ?? 0;
  }

  double get _total => _quantity * widget.startup.tokenPrice;

  void _changeQuantity(int offset) {
    setState(() {
      _quantity += offset;
      if (_quantity < 1) {
        _quantity = 1;
      }

      if (widget.isSell && _quantity > _maxSellQuantity) {
        _quantity = _maxSellQuantity;
      }
    });
  }

  Future<void> _confirm() async {
    final success = widget.isSell
        ? _store.sellTokens(widget.startup, _quantity)
        : _store.buyTokens(widget.startup, _quantity);

    if (!success) {
      final message = widget.isSell
          ? 'Quantidade indisponível para venda.'
          : 'Saldo insuficiente para concluir a compra.';
      showAppStatusSnackBar(
        context: context,
        message: message,
        type: AppStatusType.error,
      );
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(
      context,
    ).push(AppRoute(TransactionSuccessPage(isSell: widget.isSell)));
  }

  @override
  Widget build(BuildContext context) {
    final isSell = widget.isSell;
    final title = isSell ? 'Vender Tokens' : 'Comprar Tokens';

    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: MesclaColors.background,
          body: SafeArea(
            child: Stack(
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x334F39F6),
                          Color(0x1A1A0A2E),
                          Color(0x00000000),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    _TransactionHeader(title: title),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StartupMiniCard(startup: widget.startup),
                            const SizedBox(height: 24),
                            const Text(
                              'Quantidade de Tokens',
                              style: TextStyle(
                                color: MesclaColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _QuantityActionButton(
                                  icon: Icons.remove,
                                  onPressed: () => _changeQuantity(-1),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 96,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: MesclaColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: MesclaColors.border,
                                      width: 1.2,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$_quantity',
                                    style: const TextStyle(
                                      color: MesclaColors.textPrimary,
                                      fontSize: 36 / 1.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _QuantityActionButton(
                                  icon: Icons.add,
                                  onPressed: () => _changeQuantity(1),
                                ),
                              ],
                            ),
                            if (isSell && _maxSellQuantity > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Disponível para venda: $_maxSellQuantity tokens',
                                  style: const TextStyle(
                                    color: MesclaColors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            _SummaryCard(
                              unitPrice: widget.startup.tokenPrice,
                              quantity: _quantity,
                              total: _total,
                            ),
                            const SizedBox(height: 24),
                            _BalanceCard(balance: _store.balance),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: isSell
                                        ? const [
                                            Color(0xFFFB2C36),
                                            Color(0xFFFF6467),
                                          ]
                                        : const [
                                            Color(0xFF00A63E),
                                            Color(0xFF009966),
                                          ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSell
                                          ? const Color.fromRGBO(
                                              251,
                                              44,
                                              54,
                                              0.3,
                                            )
                                          : const Color.fromRGBO(
                                              0,
                                              201,
                                              80,
                                              0.3,
                                            ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: _confirm,
                                  child: Text(
                                    isSell
                                        ? 'Confirmar Venda'
                                        : 'Confirmar Compra',
                                    style: const TextStyle(
                                      color: MesclaColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
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

class _TransactionHeader extends StatelessWidget {
  const _TransactionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      decoration: const BoxDecoration(
        color: Color(0xCC1A1A2E),
        border: Border(
          bottom: BorderSide(color: MesclaColors.border, width: 1.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: MesclaColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartupMiniCard extends StatelessWidget {
  const _StartupMiniCard({required this.startup});

  final StartupData startup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              startup.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startup.name,
                  style: const TextStyle(
                    color: MesclaColors.textPrimary,
                    fontSize: 34 / 2.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${startup.tokenValue} por token',
                  style: const TextStyle(
                    color: MesclaColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityActionButton extends StatelessWidget {
  const _QuantityActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: MesclaColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MesclaColors.border, width: 1.2),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: MesclaColors.textPrimary),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.unitPrice,
    required this.quantity,
    required this.total,
  });

  final double unitPrice;
  final int quantity;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Preço unitário',
            value: formatCurrency(unitPrice),
          ),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Quantidade', value: '$quantity tokens'),
          const SizedBox(height: 12),
          const Divider(color: MesclaColors.border, height: 1),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Total',
            value: formatCurrency(total),
            emphasis: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: emphasis
                ? MesclaColors.textPrimary
                : MesclaColors.textSecondary,
            fontSize: emphasis ? 32 / 2 : 16,
            fontWeight: emphasis ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: MesclaColors.textPrimary,
            fontSize: emphasis ? 24 * 4 / 3 : 16,
            fontWeight: emphasis ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0x1A615FFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4D615FFF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: MesclaColors.navActive,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Saldo disponível',
                style: TextStyle(
                  color: MesclaColors.navActive,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(balance),
            style: const TextStyle(
              color: MesclaColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
