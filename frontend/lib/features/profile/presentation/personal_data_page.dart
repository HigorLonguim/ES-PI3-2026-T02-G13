// Autoria: Felipe Sousa - RA: 22018160
/* Nome: Luigi Mazzoni Targa | RA: 23010918 */

import 'package:flutter/material.dart';

class PersonalDataPage extends StatelessWidget {
  const PersonalDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Dados Pessoais',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Cards individuais para cada dado pessoal
            _buildDataCard(
              icon: Icons.person_outline,
              label: 'Nome Completo',
              value: 'João Silva',
            ),
            const SizedBox(height: 12),
            _buildDataCard(
              icon: Icons.email_outlined,
              label: 'Email',
              value: 'ajfaf@mail.com',
            ),
            const SizedBox(height: 12),
            _buildDataCard(
              icon: Icons.credit_card_outlined,
              label: 'CPF',
              value: '123.456.789-00',
            ),
            const SizedBox(height: 12),
            _buildDataCard(
              icon: Icons.phone_android_outlined,
              label: 'Telefone',
              value: '(11) 98765-4321',
            ),

            const SizedBox(height: 24),

            // Card de Aviso (Importante)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF101A3D), // Azul escuro
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
                ),
              ),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'Importante: ',
                      style: TextStyle(
                        color: Color(0xFF60A5FA),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Para alterar seus dados pessoais, entre em contato com o suporte.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para criar os cards de informação individuais
  Widget _buildDataCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          // Ícone com fundo roxo circular
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF9810FA),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          // Textos (Label e Valor)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
