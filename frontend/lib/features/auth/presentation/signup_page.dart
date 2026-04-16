// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/input_formatters.dart';
import '../../../core/widgets/app_status_indicator.dart';
import '../data/auth_api_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, this.authApiService});

  final AuthApiService? authApiService;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  late final AuthApiService _authApiService;
  late final bool _ownsAuthApiService;

  @override
  void initState() {
    super.initState();
    _authApiService = widget.authApiService ?? AuthApiService();
    _ownsAuthApiService = widget.authApiService == null;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    if (_ownsAuthApiService) {
      _authApiService.dispose();
    }
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final cpf = _cpfController.text.replaceAll(RegExp(r'\D'), '');
    final telefone = _telefoneController.text.replaceAll(RegExp(r'\D'), '');
    final senha = _senhaController.text;
    final confirmarSenha = _confirmarSenhaController.text;

    if (nome.isEmpty ||
        email.isEmpty ||
        cpf.isEmpty ||
        telefone.isEmpty ||
        senha.isEmpty ||
        confirmarSenha.isEmpty) {
      _showMessage('Preencha todos os campos obrigatorios.', success: false);
      return;
    }

    if (cpf.length != 11) {
      _showMessage('Informe um CPF valido.', success: false);
      return;
    }

    if (telefone.length < 10 || telefone.length > 11) {
      _showMessage('Informe um telefone valido.', success: false);
      return;
    }

    if (senha != confirmarSenha) {
      _showMessage('As senhas nao conferem.', success: false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authApiService.register(
      nome: nome,
      email: email,
      cpf: cpf,
      telefone: telefone,
      senha: senha,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    _showMessage(result.message, success: result.success);

    if (result.success) {
      Navigator.of(context).pop();
    }
  }

  void _showMessage(String message, {required bool success}) {
    showAppStatusSnackBar(
      context: context,
      message: message,
      type: success ? AppStatusType.success : AppStatusType.error,
    );
  }

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
                        spreadRadius: 10,
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
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
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
                                  colors: [
                                    Color(0xFF4F39F6),
                                    Color(0xFF9810FA),
                                  ],
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
                          'Criar Conta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            height: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Comece a investir em startups hoje',
                          style: TextStyle(
                            color: Color(0xFF99A1AF),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const _FieldLabel('Nome Completo'),
                        const SizedBox(height: 8),
                        _InputField(
                          hintText: 'Joao Silva',
                          controller: _nomeController,
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('Email'),
                        const SizedBox(height: 8),
                        _InputField(
                          hintText: 'seu@email.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('CPF'),
                        const SizedBox(height: 8),
                        _InputField(
                          hintText: '000.000.000-00',
                          controller: _cpfController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                            CpfInputFormatter(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('Telefone'),
                        const SizedBox(height: 8),
                        _InputField(
                          hintText: '(11) 98765-4321',
                          controller: _telefoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                            TelefoneInputFormatter(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('Senha'),
                        const SizedBox(height: 8),
                        _InputField(
                          hintText: '********',
                          controller: _senhaController,
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
                        const _FieldLabel('Confirmar Senha'),
                        const SizedBox(height: 8),
                        _InputField(
                          hintText: '********',
                          controller: _confirmarSenhaController,
                          obscureText: _obscureConfirmPassword,
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF9CA3AF),
                              size: 20,
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
                              onPressed: _isLoading ? null : _cadastrar,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Criar Conta',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Wrap(
                            children: [
                              const Text(
                                'Ja tem uma conta? ',
                                style: TextStyle(
                                  color: Color(0xFF99A1AF),
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Entrar',
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
                      ],
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
    required this.controller,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
  });

  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.333,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1.183, color: const Color(0xFF2A2A3E)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF6A7282), fontSize: 16),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
