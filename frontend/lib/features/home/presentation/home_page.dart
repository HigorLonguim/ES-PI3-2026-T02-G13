/* Nome: Felipe Sousa de Almeida | RA: 22018160 */
/* Nome: Luigi Mazzoni Targa | RA: 23010918 */

import 'package:flutter/material.dart';
import '../../../core/navigation/app_route.dart';
import '../../auth/presentation/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0A1A), Color(0xFF0C1E1A), Color(0xFF102821)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 98.2,
                top: 212.97,
                child: Container(
                  width: 383.994,
                  height: 383.994,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(0, 163, 108, 0.22),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 163, 108, 0.22),
                        blurRadius: 110,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: -89.38,
                top: 254.92,
                child: Container(
                  width: 383.994,
                  height: 383.994,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(68, 209, 122, 0.16),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(68, 209, 122, 0.16),
                        blurRadius: 110,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: SizedBox(
                    width: 392.812,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 180),
                          Container(
                            width: 95.985,
                            height: 95.985,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF00A36C), Color(0xFF44D17A)],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 163, 108, 0.45),
                                  blurRadius: 50,
                                  offset: Offset(0, 25),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.trending_up_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'MesclaInvest',
                            style: TextStyle(
                              fontSize: 56,
                              height: 1,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Invista em startups promissoras com\ntokens digitais',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.5,
                              color: Color(0xFF99A1AF),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 48),

                          // BOTÃO 1: CONTINUAR (FLUXO LOGIN)
                          SizedBox(
                            width: double.infinity,
                            height: 55.96,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF00A36C),
                                    Color(0xFF44D17A),
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 163, 108, 0.35),
                                    blurRadius: 15,
                                    offset: Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 163, 108, 0.35),
                                    blurRadius: 6,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).push(AppRoute(const LoginPage()));
                                },
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Continuar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Colors.white,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
