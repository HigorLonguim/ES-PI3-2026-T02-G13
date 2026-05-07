// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';

import '../../../core/theme/mescla_colors.dart';
import '../data/portfolio_store.dart';
import '../data/trading_api_service.dart';
import 'models/money_formatters.dart';

class WalletHistoryPage extends StatefulWidget {
  const WalletHistoryPage({super.key});

  @override
  State<WalletHistoryPage> createState() => _WalletHistoryPageState();
}

class _WalletHistoryPageState extends State<WalletHistoryPage> {
  final PortfolioStore _store = PortfolioStore.instance;

  @override
  void initState() {
    super.initState();
    _store.refreshTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final transactions = _store.transactions;
        return Scaffold(
          backgroundColor: MesclaColors.background,
          appBar: AppBar(
            backgroundColor: const Color(0xCC1A1A2E),
            elevation: 0,
            title: const Text(
              'Historico de Transacoes',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: transactions.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma transacao registrada',
                    style: TextStyle(color: MesclaColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _TransactionTile(item: transactions[index]);
                  },
                ),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item});

  final WalletTransaction item;

  @override
  Widget build(BuildContext context) {
    final isCredit = item.type == 'CREDIT';
    final isBuy = item.type == 'BUY';
    final title = isCredit
        ? 'Credito de saldo'
        : isBuy
        ? 'Compra de tokens'
        : 'Venda de tokens';
    final amountPrefix = isBuy ? '-' : '+';
    final amountColor = isBuy ? MesclaColors.danger : MesclaColors.success;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MesclaColors.border, width: 1.2),
        gradient: MesclaGradients.startupCard,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: MesclaColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$amountPrefix${formatCurrency(item.amount)}',
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (item.startupName != null && item.startupName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.startupName!,
              style: const TextStyle(color: MesclaColors.textSecondary),
            ),
          ],
          if (item.quantity > 0) ...[
            const SizedBox(height: 2),
            Text(
              'Quantidade: ${item.quantity} tokens',
              style: const TextStyle(color: MesclaColors.textSecondary),
            ),
          ],
          if (item.createdAtIso != null && item.createdAtIso!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              item.createdAtIso!,
              style: const TextStyle(
                color: MesclaColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
