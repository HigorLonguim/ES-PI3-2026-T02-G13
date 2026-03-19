/* Nome: Luigi Mazzoni Targa | RA: 23010918 */
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Centro de Ajuda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A1A), Color(0xFF1A0A2E)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // --- Barra de Pesquisa Simulada ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF141E2D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A3E)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Color(0xFF99A1AF)),
                    SizedBox(width: 12),
                    Text(
                      'Como podemos ajudar?',
                      style: TextStyle(color: Color(0xFF99A1AF), fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Perguntas Frequentes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // --- Lista de FAQs ---
              _buildFaqItem(
                Icons.info_outline,
                'O que é o MesclaInvest?',
                'É uma plataforma acadêmica para simulação de investimentos em startups do ecossistema Mescla da PUC-Campinas. O foco é aprendizado prático sobre o mercado de inovação.',
              ),
              _buildFaqItem(
                Icons.monetization_on_outlined,
                'O investimento é real?',
                'Não. Todas as operações, saldos e tokens são estritamente simulados para fins pedagógicos. Não há envolvimento de dinheiro real.',
              ),
              _buildFaqItem(
                Icons.token_outlined,
                'O que são Tokens?',
                'Nesta plataforma, tokens representam unidades digitais de participação em uma startup. Eles permitem que você simule a compra de partes de um negócio.',
              ),
              _buildFaqItem(
                Icons.account_balance_wallet_outlined,
                'Como ganho saldo?',
                'Você pode adicionar saldo fictício através da sua área de perfil, clicando em "Adicionar Saldo" dentro da sua carteira digital.',
              ),
              _buildFaqItem(
                Icons.security_outlined,
                'Como funciona o MFA?',
                'O Multi-Factor Authentication (MFA) é uma camada extra de segurança opcional que você ativa para proteger sua conta contra acessos indevidos.',
              ),
              const SizedBox(height: 40),
              // --- Seção de Contato Final ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F39F6), Color(0xFF9810FA)],
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ainda tem dúvidas?',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Entre em contato com o suporte do Mescla.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4F39F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Suporte'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(IconData icon, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A3E)),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color(0xFF9810FA), size: 22),
        iconColor: const Color(0xFF9810FA),
        collapsedIconColor: Colors.white,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(54, 0, 20, 20),
            child: Text(
              answer,
              style: const TextStyle(
                color: Color(0xFF99A1AF),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
