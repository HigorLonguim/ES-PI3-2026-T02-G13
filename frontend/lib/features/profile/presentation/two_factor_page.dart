/* Nome: Luigi Mazzoni Targa | RA: 23010918 */

import 'package:flutter/material.dart';

class TwoFactorPage extends StatefulWidget {
  const TwoFactorPage({super.key});

  @override
  State<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isMfaEnabled = false;

  void _toggleMfa() {
    if (_codeController.text.length == 6) {
      setState(() {
        _isMfaEnabled = !_isMfaEnabled;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isMfaEnabled 
                ? 'Autenticação de Dois Fatores ativada com sucesso!' 
                : 'MFA desativado.',
          ),
          backgroundColor: _isMfaEnabled ? Colors.green : Colors.redAccent,
        ),
      );
      
      _codeController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insira o código de 6 dígitos gerado pelo seu autenticador.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context, _isMfaEnabled),
            ),
          ),
        ),
        title: const Text(
          'Autenticação de Dois Fatores',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF9810FA).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security,
                color: Color(0xFF9810FA),
                size: 64,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Proteja sua carteira digital',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'A autenticação de dois fatores (MFA) adiciona uma camada extra de segurança para validar suas ordens de compra e venda simuladas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF99A1AF), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141E2D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepRow('1', 'Abra o Google Authenticator ou similar no seu celular.'),
                  const SizedBox(height: 16),
                  _buildStepRow('2', 'Insira a chave manual temporária do ambiente de testes: MESCLATEST2026'),
                  const SizedBox(height: 16),
                  _buildStepRow('3', 'Digite o código de 6 dígitos gerado abaixo para confirmar.'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Input do código simulado de 6 dígitos
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: const TextStyle(color: Colors.grey, letterSpacing: 8),
                counterStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF9810FA)),
                ),
                filled: true,
                fillColor: const Color(0xFF141E2D),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _toggleMfa,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isMfaEnabled ? Colors.redAccent : const Color(0xFF9810FA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _isMfaEnabled ? 'Desativar Autenticação' : 'Ativar Autenticação',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: const Color(0xFF9810FA),
          child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF99A1AF), fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }
}