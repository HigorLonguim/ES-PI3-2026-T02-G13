/* Nome: Joao Vitor Custodio | RA: 22000115 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        _showMessage(_firebaseError(error));
      },
      codeSent: (verificationId, _) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _loading = false;
        });
        _showMessage('Codigo enviado por SMS.');
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
      _showMessage('Digite o codigo de 6 digitos.');
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
      _showMessage(_firebaseError(error));
    }
  }

  String _firebaseError(FirebaseAuthException error) {
    if (error.code == 'invalid-verification-code') {
      return 'Codigo SMS invalido.';
    }
    return error.message ?? 'Nao foi possivel validar o codigo.';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            const Icon(Icons.sms, color: Color(0xFF9810FA), size: 64),
            const SizedBox(height: 24),
            Text(
              'Codigo enviado para $phone',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18),
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
                fillColor: const Color(0xFF141E2D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _confirmCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9810FA),
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(_loading ? 'Aguarde...' : 'Confirmar'),
            ),
            TextButton(
              onPressed: _loading ? null : _sendSms,
              child: const Text('Reenviar SMS'),
            ),
          ],
        ),
      ),
    );
  }
}
