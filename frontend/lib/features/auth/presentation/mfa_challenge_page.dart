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
  String? _verificationId;
  bool _loading = false;

  PhoneMultiFactorInfo? get _phoneFactor {
    for (final factor in widget.resolver.hints) {
      if (factor is PhoneMultiFactorInfo) {
        return factor;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendSms());
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendSms() async {
    final phoneFactor = _phoneFactor;
    if (phoneFactor == null) return;

    setState(() => _loading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      multiFactorSession: widget.resolver.session,
      multiFactorInfo: phoneFactor,
      verificationCompleted: _finishLogin,
      verificationFailed: (error) {
        if (!mounted) return;
        setState(() => _loading = false);
        _showMessage(_firebaseError(error), AppStatusType.error);
      },
      codeSent: (verificationId, _) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _loading = false;
        });
        _showMessage('Codigo enviado por SMS.', AppStatusType.info);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _confirmCode() async {
    final verificationId = _verificationId;
    final code = _codeController.text.trim();

    if (verificationId == null || code.length != 6) {
      _showMessage('Digite o codigo de 6 digitos.', AppStatusType.error);
      return;
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: code,
    );
    await _finishLogin(credential);
  }

  Future<void> _finishLogin(PhoneAuthCredential credential) async {
    setState(() => _loading = true);

    try {
      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
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
      return 'Codigo SMS invalido.';
    }
    return error.message ?? 'Nao foi possivel validar o codigo.';
  }

  void _showMessage(String message, AppStatusType type) {
    showAppStatusSnackBar(context: context, message: message, type: type);
  }

  @override
  Widget build(BuildContext context) {
    final phone = _phoneFactor?.phoneNumber ?? 'seu telefone';

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
            Text(
              'Como medida de seguranca, enviamos um codigo de verificacao para',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF99A1AF), fontSize: 14),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF201641),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF4B3BB0)),
                ),
                child: Text(
                  phone,
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
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loading ? null : _sendSms,
              child: const Text('Reenviar codigo'),
            ),
          ],
        ),
      ),
    );
  }
}
