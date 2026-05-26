// Autoria: Felipe Sousa - RA: 22018160
/* Nome: Luigi Mazzoni Targa | RA: 23010918 */
/* Nome: Joao Vitor Custodio | RA: 22000115 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/widgets/app_status_indicator.dart';

class TwoFactorPage extends StatefulWidget {
  const TwoFactorPage({super.key});

  @override
  State<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {
  final TextEditingController _codeController = TextEditingController();

  bool _loading = true;
  List<MultiFactorInfo> _factors = const [];
  TotpSecret? _totpSecret;
  String? _qrUrl;

  bool get _isMfaEnabled => _factors.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadMfa();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadMfa() async {
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

  Future<void> _startTotpEnrollment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage(
        'Faca login novamente para configurar o MFA.',
        AppStatusType.error,
      );
      return;
    }

    if (!user.emailVerified) {
      await user.sendEmailVerification();
      _showMessage(
        'Verifique seu email antes de ativar o MFA.',
        AppStatusType.warning,
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final session = await user.multiFactor.getSession();
      final secret = await TotpMultiFactorGenerator.generateSecret(session);
      final email = user.email ?? 'usuario@mesclainvest.app';
      final qrCodeUrl = await secret.generateQrCodeUrl(
        accountName: email,
        issuer: 'MesclaInvest',
      );

      if (!mounted) return;
      setState(() {
        _totpSecret = secret;
        _qrUrl = qrCodeUrl;
        _loading = false;
      });

      _showMessage(
        'Chave TOTP gerada. Cadastre no autenticador e confirme o codigo.',
        AppStatusType.info,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage(_firebaseError(error), AppStatusType.error);
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (kDebugMode) {
        debugPrint(
          '[TOTP] FirebaseException ao gerar segredo: ${error.code} - ${error.message}',
        );
      }
      _showMessage(_firebasePlatformError(error), AppStatusType.error);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (kDebugMode) {
        debugPrint('[TOTP] Erro inesperado ao gerar segredo: $error');
      }
      _showMessage(
        'Nao foi possivel iniciar o cadastro TOTP.',
        AppStatusType.error,
      );
    }
  }

  Future<void> _confirmTotpEnrollment() async {
    final user = FirebaseAuth.instance.currentUser;
    final secret = _totpSecret;
    final code = _codeController.text.trim();

    if (user == null || secret == null) {
      _showMessage(
        'Gere a chave TOTP antes de confirmar.',
        AppStatusType.error,
      );
      return;
    }

    if (code.length != 6) {
      _showMessage(
        'Digite o codigo de 6 digitos do autenticador.',
        AppStatusType.error,
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final assertion =
          await TotpMultiFactorGenerator.getAssertionForEnrollment(
            secret,
            code,
          );

      await user.multiFactor.enroll(assertion, displayName: 'Authenticator');
      _codeController.clear();

      if (!mounted) return;
      setState(() {
        _totpSecret = null;
        _qrUrl = null;
      });
      await _loadMfa();
      _showMessage('MFA TOTP ativado com sucesso.', AppStatusType.success);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage(_firebaseError(error), AppStatusType.error);
    }
  }

  Future<void> _disableMfa(MultiFactorInfo factor) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      await user.multiFactor.unenroll(multiFactorInfo: factor);
      await _loadMfa();
      _showMessage('MFA desativado.', AppStatusType.success);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage(_firebaseError(error), AppStatusType.error);
    }
  }

  String _factorText(MultiFactorInfo factor) {
    if (factor.factorId == 'totp') {
      return factor.displayName ?? 'Authenticator (TOTP)';
    }
    if (factor is PhoneMultiFactorInfo) {
      return factor.phoneNumber;
    }
    return factor.displayName ?? 'Segundo fator';
  }

  String _firebaseError(FirebaseAuthException error) {
    if (error.code == 'requires-recent-login') {
      return 'Faca login novamente antes de alterar o MFA.';
    }
    if (error.code == 'unsupported-first-factor') {
      return 'Ative login por email/senha para usar TOTP.';
    }
    if (error.code == 'second-factor-already-in-use') {
      return 'Este fator ja esta cadastrado.';
    }
    if (error.code == 'invalid-verification-code') {
      return 'Codigo TOTP invalido. Tente novamente.';
    }
    if (error.code == 'operation-not-allowed') {
      return 'TOTP nao habilitado no projeto Firebase.';
    }
    if (error.code == 'invalid-app-credential') {
      return 'Credencial do app invalida para MFA. Revise configuracao do Firebase.';
    }
    return error.message ?? 'Nao foi possivel concluir a operacao.';
  }

  String _firebasePlatformError(FirebaseException error) {
    if (error.code == 'operation-not-allowed') {
      return 'TOTP nao habilitado no projeto Firebase.';
    }
    if (error.code == 'unimplemented') {
      return 'Projeto sem suporte a TOTP MFA (Identity Platform).';
    }
    if (error.code == 'permission-denied') {
      return 'Permissao negada para iniciar TOTP. Verifique configuracao do projeto.';
    }
    return error.message ?? 'Falha ao iniciar o cadastro TOTP.';
  }

  void _showMessage(String message, AppStatusType type) {
    showAppStatusSnackBar(context: context, message: message, type: type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Autenticacao de Dois Fatores'),
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

    final canConfirm = _totpSecret != null;

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
          ElevatedButton(
            onPressed: _startTotpEnrollment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9810FA),
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text('Configurar autenticador'),
          ),
          if (_totpSecret != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF141E2D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chave secreta (manual)',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    _totpSecret!.secretKey,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (_qrUrl != null) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'QR Code',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: QrImageView(
                          data: _qrUrl!,
                          size: 180,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'URL para QR Code',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      _qrUrl!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
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
              onPressed: canConfirm ? _confirmTotpEnrollment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9810FA),
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Ativar verificacao em duas etapas'),
            ),
          ],
        ],
      ),
    );
  }
}
