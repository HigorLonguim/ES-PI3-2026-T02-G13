// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';

import '../../../core/navigation/app_route.dart';
import 'login_page.dart';

class RecoverPasswordSuccessPage extends StatelessWidget {
  const RecoverPasswordSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      const Text(
                        'E-mail Enviado!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Se o e-mail informado estiver cadastrado, voce recebera as instrucoes para recuperar sua senha.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF99A1AF),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFF4F39F6), Color(0xFF9810FA)],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(97, 95, 255, 0.3),
                                blurRadius: 15,
                                offset: Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Color.fromRGBO(97, 95, 255, 0.3),
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                AppRoute(const LoginPage()),
                                (route) => route.isFirst,
                              );
                            },
                            child: const Text(
                              'Voltar ao login',
                              style: TextStyle(
                                color: Colors.white,
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
        ),
      ),
    );
  }
}
