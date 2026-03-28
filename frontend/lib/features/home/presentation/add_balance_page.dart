// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';

import '../../../core/widgets/app_status_indicator.dart';
import '../../../core/theme/mescla_colors.dart';
import '../data/portfolio_store.dart';
import 'models/money_formatters.dart';

class AddBalancePage extends StatefulWidget {
  const AddBalancePage({super.key});

  @override
  State<AddBalancePage> createState() => _AddBalancePageState();
}

class _AddBalancePageState extends State<AddBalancePage> {
  final TextEditingController _controller = TextEditingController();

  double _amount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQuickValue(double value) {
    setState(() {
      _amount = value;
      _controller.text = value.toStringAsFixed(0);
    });
  }

  void _onInputChanged(String value) {
    final normalized = value.replaceAll(',', '.').trim();
    final parsed = double.tryParse(normalized) ?? 0;
    setState(() {
      _amount = parsed;
    });
  }

  void _submit() {
    if (_amount <= 0) {
      return;
    }

    PortfolioStore.instance.addBalance(_amount);
    showAppStatusSnackBar(
      context: context,
      message: 'Saldo adicionado com sucesso!',
      type: AppStatusType.success,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final balance = PortfolioStore.instance.balance;

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
                      Color(0x33000000),
                      Color(0x221A0A2E),
                      Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Container(
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
                      const Text(
                        'Adicionar Saldo',
                        style: TextStyle(
                          color: MesclaColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: MesclaGradients.purple,
                            boxShadow: const [
                              BoxShadow(
                                color: MesclaColors.purpleGlow,
                                blurRadius: 40,
                                offset: Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Saldo Atual',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formatCurrency(balance),
                                style: const TextStyle(
                                  color: MesclaColors.textPrimary,
                                  fontSize: 36 / 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Valor a Adicionar',
                          style: TextStyle(
                            color: MesclaColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 66,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: MesclaColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: MesclaColors.border, width: 1.2),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                color: MesclaColors.textTertiary,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  onChanged: _onInputChanged,
                                  style: const TextStyle(
                                    color: MesclaColors.textPrimary,
                                    fontSize: 40 / 1.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '0,00',
                                    hintStyle: TextStyle(
                                      color: Color(0x80FFFFFF),
                                      fontSize: 40 / 1.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatCurrency(_amount),
                          style: const TextStyle(
                            color: MesclaColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Valores Rápidos',
                          style: TextStyle(
                            color: MesclaColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [100, 500, 1000, 5000].map((value) {
                            return SizedBox(
                              width: (MediaQuery.sizeOf(context).width - 60) / 2,
                              height: 50,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: MesclaColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: MesclaColors.border,
                                    width: 1.2,
                                  ),
                                ),
                                child: TextButton(
                                  onPressed: () => _onQuickValue(value.toDouble()),
                                  child: Text(
                                    'R\$ $value',
                                    style: const TextStyle(
                                      color: MesclaColors.textPrimary,
                                      fontSize: 31 / 2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0x1A2B7FFF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x332B7FFF), width: 1.2),
                          ),
                          child: const Text(
                            'Simulação: Este é um saldo fictício para demonstração da plataforma.',
                            style: TextStyle(
                              color: Color(0xFF8EC5FF),
                              fontSize: 31 / 2,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
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
                                  color: Color.fromRGBO(0, 201, 80, 0.3),
                                  blurRadius: 14,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: _amount > 0 ? _submit : null,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                disabledForegroundColor: const Color(0x8021A260),
                              ),
                              child: Text(
                                'Adicionar ${formatCurrency(_amount)}',
                                style: const TextStyle(
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
  }
}

