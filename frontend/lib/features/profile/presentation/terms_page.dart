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
        title: const Text('Termos e Políticas', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text('Conteúdo em desenvolvimento...', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}