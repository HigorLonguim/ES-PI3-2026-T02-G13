// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';

import '../../../core/navigation/app_route.dart';
import '../../../core/theme/mescla_colors.dart';
import 'main_navigation_page.dart';

class TransactionSuccessPage extends StatelessWidget {
  const TransactionSuccessPage({required this.isSell, super.key});

  final bool isSell;

  @override
  Widget build(BuildContext context) {
    final title = isSell ? 'Venda Realizada!' : 'Compra Realizada!';

    return Scaffold(
      backgroundColor: MesclaColors.background,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0A1A), Color(0xFF1A0A2E), Color(0xFF0A0A1A)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 4,
                top: 284,
                child: Container(
                  width: 384,
                  height: 384,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(0, 166, 62, 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 166, 62, 0.2),
                        blurRadius: 150,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF00A63E), Color(0xFF009966)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 201, 80, 0.5),
                              blurRadius: 40,
                              offset: Offset(0, 20),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: MesclaColors.textPrimary,
                          fontSize: 48 / 1.6,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sua transação foi processada com sucesso. Você pode acompanhar seus investimentos na sua carteira.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: MesclaColors.textSecondary,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _ActionButton(
                        label: 'Ver Carteira',
                        isPrimary: true,
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            AppRoute(const MainNavigationPage(initialIndex: 1)),
                            (route) => false,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _ActionButton(
                        label: 'Explorar Mais Startups',
                        isPrimary: false,
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            AppRoute(const MainNavigationPage(initialIndex: 0)),
                            (route) => false,
                          );
                        },
                      ),
                    ],
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
              : Border.all(color: MesclaColors.border, width: 1.2),
          boxShadow: isPrimary
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 201, 80, 0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: MesclaColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

