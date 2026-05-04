/* Nome: Luigi Mazzoni Targa | RA: 23010918 */
import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Termos e Políticas', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Aceite dos Termos'),
            _buildContentText('Ao acessar o MesclaInvest, você concorda com os termos...'),
            const SizedBox(height: 24),
            _buildSectionTitle('2. Ambiente Simulado'),
            _buildContentText('Este é um projeto acadêmico de Engenharia de Software...'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildContentText(String text) {
    return Text(text, style: const TextStyle(color: Color(0xFF99A1AF), fontSize: 14));
  }
}