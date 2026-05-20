/* Nome: Luigi Mazzoni Targa | RA: 23010918 */
/* Nome: Joao Vitor Custodio | RA: 22000115 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session_storage.dart';

class TwoFactorPage extends StatefulWidget {
  const TwoFactorPage({super.key});

  @override
  State<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {
  final AuthSessionStorage _storage = AuthSessionStorage();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  bool _loading = true;
  bool _codeSent = false;
  String? _verificationId;
  List<MultiFactorInfo> _factors = const [];

  bool get _isMfaEnabled => _factors.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadMfa();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadMfa() async {
    final savedPhone = await _storage.getUserTelefone();
    if (savedPhone != null && _phoneController.text.isEmpty) {
      _phoneController.text = _formatPhone(savedPhone);
    }

    if (Firebase.apps.isEmpty || FirebaseAuth.instance.currentUser == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    await user.reload();
    final factors = await user.multiFactor.getEnrolledFactors();

    if (!mounted) return;
    setState(() {
      _factors = factors;
      _loading = false;
    });
  }

  Future<void> _sendCode() async {
    final user = FirebaseAuth.instance.currentUser;
    final phone = _normalizePhone(_phoneController.text);

    if (user == null) {
      _showMessage('Faca login novamente para configurar MFA.');
      return;
    }

    if (phone == null) {
      _showMessage('Digite um telefone valido com DDD.');
      return;
    }

    if (!user.emailVerified) {
      await user.sendEmailVerification();
      _showMessage('Verifique seu email. Enviamos um link para voce.');
      return;
    }

    setState(() => _loading = true);

    try {
      final session = await user.multiFactor.getSession();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        multiFactorSession: session,
        verificationCompleted: _enrollMfa,
        verificationFailed: (error) {
          if (!mounted) return;
          setState(() => _loading = false);
          _showMessage(_firebaseError(error));
        },
        codeSent: (verificationId, _) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _loading = false;
          });
          _showMessage('Codigo enviado por SMS.');
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Nao foi possivel enviar o SMS.');
    }
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
    await _enrollMfa(credential);
  }

  Future<void> _enrollMfa(PhoneAuthCredential credential) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
      await user.multiFactor.enroll(assertion, displayName: 'Telefone');
      _codeController.clear();
      _verificationId = null;
      _codeSent = false;
      await _loadMfa();
      _showMessage('MFA ativado com sucesso.');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage(_firebaseError(error));
    }
  }

  Future<void> _disableMfa(MultiFactorInfo factor) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      await user.multiFactor.unenroll(multiFactorInfo: factor);
      await _loadMfa();
      _showMessage('MFA desativado.');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage(_firebaseError(error));
    }
  }

  String _formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10 || digits.length == 11) {
      return '+55$digits';
    }
    return phone;
  }

  String? _normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (phone.trim().startsWith('+') && digits.length >= 8) {
      return '+$digits';
    }
    if (digits.length == 10 || digits.length == 11) {
      return '+55$digits';
    }
    return null;
  }

  String _factorText(MultiFactorInfo factor) {
    if (factor is PhoneMultiFactorInfo) {
      return factor.phoneNumber;
    }
    return factor.displayName ?? 'Segundo fator';
  }

  String _firebaseError(FirebaseAuthException error) {
    if (error.code == 'invalid-phone-number') return 'Telefone invalido.';
    if (error.code == 'invalid-verification-code') return 'Codigo invalido.';
    if (error.code == 'requires-recent-login') {
      return 'Faca login novamente antes de alterar o MFA.';
    }
    return error.message ?? 'Nao foi possivel concluir a operacao.';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Autenticação de Dois Fatores'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.pop(context, _isMfaEnabled),
        ),
      ),
      body: _loading ? _loadingView() : _content(),
    );
  }

  Widget _loadingView() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF9810FA)),
    );
  }

  Widget _content() {
    if (Firebase.apps.isEmpty || FirebaseAuth.instance.currentUser == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Entre pelo Firebase Auth para configurar MFA.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.security, color: Color(0xFF9810FA), size: 64),
          const SizedBox(height: 20),
          Text(
            _isMfaEnabled ? 'MFA ativado' : 'MFA desativado',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          for (final factor in _factors)
            Card(
              color: const Color(0xFF141E2D),
              child: ListTile(
                title: Text(
                  _factorText(factor),
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _disableMfa(factor),
                ),
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+()\-\s]')),
            ],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Telefone',
              hintText: '+5511999999999',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF141E2D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _sendCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9810FA),
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(_codeSent ? 'Reenviar SMS' : 'Enviar SMS'),
          ),
          if (_codeSent) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
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
            ElevatedButton(
              onPressed: _confirmCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9810FA),
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Ativar MFA'),
            ),
          ],
        ],
      ),
    );
  }
}
