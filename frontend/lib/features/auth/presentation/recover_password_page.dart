// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/navigation/app_route.dart';
import '../../../core/widgets/app_status_indicator.dart';
import '../data/auth_api_service.dart';
import 'recover_password_success_page.dart';

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({
    super.key,
    this.authApiService,
    this.useMockRecoverPasswordFlow,
  });

  final AuthApiService? authApiService;
  final bool? useMockRecoverPasswordFlow;

  @override
  State<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  static const int _requestCooldownInSeconds = 30;

  bool _isLoading = false;
  bool _ownsAuthApiService = false;
  DateTime? _lastRecoverRequestAt;
  late final AuthApiService _authApiService;
  late final bool _useMockRecoverPasswordFlow;
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authApiService = widget.authApiService ?? AuthApiService();
    _ownsAuthApiService = widget.authApiService == null;
    _useMockRecoverPasswordFlow =
        widget.useMockRecoverPasswordFlow ?? AppConfig.recoverPasswordUseMock;
  }

  @override
  void dispose() {
    _emailController.dispose();
    if (_ownsAuthApiService) {
      _authApiService.dispose();
    }
    super.dispose();
  }

  Future<void> _enviarInstrucoes() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showMessage('Informe um email valido.', success: false);
      return;
    }

    final remainingCooldown = _remainingCooldown();
    if (remainingCooldown > 0) {
      _showMessage(
        'Aguarde $remainingCooldown segundos para tentar novamente.',
        success: false,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (_useMockRecoverPasswordFlow) {
      await Future<void>.delayed(const Duration(milliseconds: 600));

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _lastRecoverRequestAt = DateTime.now();
      Navigator.of(context).push(AppRoute(const RecoverPasswordSuccessPage()));
      return;
    }

    final result = await _authApiService.recoverPassword(email: email);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (!result.success) {
      _showMessage(result.message, success: false);
      return;
    }

    _lastRecoverRequestAt = DateTime.now();
    Navigator.of(context).push(AppRoute(const RecoverPasswordSuccessPage()));
  }

  int _remainingCooldown() {
    final lastRecoverRequestAt = _lastRecoverRequestAt;
    if (lastRecoverRequestAt == null) {
      return 0;
    }

    final elapsedSeconds = DateTime.now()
        .difference(lastRecoverRequestAt)
        .inSeconds;
    if (elapsedSeconds >= _requestCooldownInSeconds) {
      return 0;
    }

    return _requestCooldownInSeconds - elapsedSeconds;
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
          decoration: const BoxDecoration(color: Color(0xFF0A0A1A)),
          child: Stack(
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
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
                child: SizedBox.expand(),
              ),
              Positioned(
                left: 40,
                top: 80,
                child: Container(
                  width: 288,
                  height: 288,
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
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1A1A2E),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          splashRadius: 20,
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFFD1D5DC),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      const Text(
                        'Recuperar Senha',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          height: 0.86,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Informe seu email para receber as instrucoes de recuperacao',
                        style: TextStyle(
                          color: Color(0xFF99A1AF),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const _FieldLabel('Email'),
                      const SizedBox(height: 8),
                      _InputField(
                        hintText: 'seu@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
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
                            onPressed: _isLoading ? null : _enviarInstrucoes,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Enviar Instrucoes',
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
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.hintText,
    required this.controller,
    this.keyboardType,
  });

  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.167,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1.083, color: const Color(0xFF2A2A3E)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF6A7282), fontSize: 16),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
