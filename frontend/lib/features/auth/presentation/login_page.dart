/* Nome: Felipe Sousa de Almeida | RA: 22018160 */

import 'package:flutter/material.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A0A1A),
                Color(0xFF1A0A2E),
                Color(0xFF0A0A1A),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 39.99,
                top: 79.99,
                child: Container(
                  width: 287.991,
                  height: 287.991,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(79, 57, 246, 0.3),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(79, 57, 246, 0.3),
                        blurRadius: 120,
                        spreadRadius: 14,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 64.83,
                top: 483.9,
                child: Container(
                  width: 287.991,
                  height: 287.991,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(152, 16, 250, 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(152, 16, 250, 0.2),
                        blurRadius: 120,
                        spreadRadius: 14,
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 63.984,
                                height: 63.984,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF4F39F6), Color(0xFF9810FA)],
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(97, 95, 255, 0.5),
                                      blurRadius: 15,
                                      offset: Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: Color.fromRGBO(97, 95, 255, 0.5),
                                      blurRadius: 6,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.trending_up_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                splashRadius: 20,
                                icon: const Icon(
                                  Icons.chevron_left_rounded,
                                  color: Color(0xFFD1D5DC),
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Bem-vindo de volta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              height: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Por favor, digite suas credenciais',
                            style: TextStyle(
                              color: Color(0xFF99A1AF),
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 48),
                          const _FieldLabel('Email'),
                          const SizedBox(height: 8),
                          const _InputField(
                            hintText: 'seu@email.com',
                          ),
                          const SizedBox(height: 16),
                          const _FieldLabel('Senha'),
                          const SizedBox(height: 8),
                          _InputField(
                            hintText: '••••••••',
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF9CA3AF),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Esqueceu a senha?',
                              style: TextStyle(
                                color: Color(0xFF7C86FF),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 51.967,
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
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 196),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Wrap(
                                children: [
                                  const Text(
                                    'Não tem uma conta? ',
                                    style: TextStyle(
                                      color: Color(0xFF99A1AF),
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => const SignUpPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Cadastre-se',
                                      style: TextStyle(
                                        color: Color(0xFF7C86FF),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        height: 1.5,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFD1D5DC),
        fontSize: 14,
        height: 1.43,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.hintText,
    this.obscureText = false,
    this.suffix,
  });

  final String hintText;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.333,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1.183,
          color: const Color(0xFF2A2A3E),
        ),
      ),
      child: TextField(
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF6A7282),
            fontSize: 16,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
