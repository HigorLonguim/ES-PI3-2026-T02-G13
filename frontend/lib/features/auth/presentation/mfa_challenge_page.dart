// Autoria: Felipe Sousa - RA: 22018160
/* Nome: Joao Vitor Custodio | RA: 22000115 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/app_status_indicator.dart';

class MfaChallengePage extends StatefulWidget {
  const MfaChallengePage({super.key, required this.resolver});

  final MultiFactorResolver resolver;

  @override
  State<MfaChallengePage> createState() => _MfaChallengePageState();
}

class _MfaChallengePageState extends State<MfaChallengePage> {
  final TextEditingController _codeController = TextEditingController();
  bool _loading = false;

  MultiFactorInfo? get _primaryFactor {
    if (widget.resolver.hints.isEmpty) {
      return null;
    }
    for (final factor in widget.resolver.hints) {
      if (factor.factorId == 'totp') {
        return factor;
      }
    }
    return widget.resolver.hints.first;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _confirmCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      _showMessage('Digite o codigo de 6 digitos.', AppStatusType.error);
      return;
    }

    final factor = _primaryFactor;
    if (factor == null) {
      _showMessage('Nenhum fator MFA cadastrado para este usuario.', AppStatusType.error);
      return;
    }

    setState(() => _loading = true);

    try {
      MultiFactorAssertion assertion;
      if (factor.factorId == 'totp') {
        assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
          factor.uid,
          code,
        );
      } else {
        _showMessage('Este fluxo agora suporta apenas TOTP.', AppStatusType.error);
        setState(() => _loading = false);
        return;
      }

      final userCredential = await widget.resolver.resolveSignIn(assertion);
      if (!mounted) return;
      Navigator.pop(context, userCredential);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage(_firebaseError(error), AppStatusType.error);
    }
  }

  String _firebaseError(FirebaseAuthException error) {
    if (error.code == 'invalid-verification-code') {
      return 'Codigo TOTP invalido.';
    }
    return error.message ?? 'Nao foi possivel validar o codigo.';
  }

  void _showMessage(String message, AppStatusType type) {
    showAppStatusSnackBar(context: context, message: message, type: type);
  }

  @override
  Widget build(BuildContext context) {
    final factor = _primaryFactor;
    final label = factor?.displayName ?? 'Authenticator';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Confirmar MFA'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const Icon(Icons.lock, color: Color(0xFF7B61FF), size: 72),
            const SizedBox(height: 24),
            const Text(
              'Confirme sua Identidade',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Digite o codigo de 6 digitos do seu aplicativo autenticador.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF99A1AF), fontSize: 14),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF201641),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF4B3BB0)),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              enabled: !_loading,
              maxLength: 6,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '000000',
                filled: true,
                fillColor: const Color(0xFF12052E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _confirmCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B61FF),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF7B61FF),
                disabledForegroundColor: Colors.white70,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(_loading ? 'Aguarde...' : 'Verificar e Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
