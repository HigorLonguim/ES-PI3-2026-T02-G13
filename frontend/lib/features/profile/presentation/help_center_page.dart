/* Nome: Luigi Mazzoni Targa | RA: 23010918 */

import 'package:flutter/material.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();

  // Dados das categorias de ajuda
  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.account_balance_wallet_outlined,
      'title': 'Conta e Carteira',
      'description': 'Problemas com saldo fictício, login ou dados.',
    },
    {
      'icon': Icons.toll_outlined,
      'title': 'Tokens e Negociações',
      'description': 'Como comprar, vender ou entender as oscilações.',
    },
    {
      'icon': Icons.security_outlined,
      'title': 'Segurança e 2FA',
      'description': 'Gerenciamento de senhas e autenticação de dois fatores.',
    },
    {
      'icon': Icons.business_outlined,
      'title': 'Avaliação de Startups',
      'description': 'Como ler as métricas e entender as captações.',
    },
  ];

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
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Central de Ajuda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de busca por texto
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF141E2D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Qual é a sua dúvida?",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Navegue por tópicos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Listagem dos cards de tópicos
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildCategoryCard(
                  icon: category['icon'],
                  title: category['title'],
                  description: category['description'],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Card para cada categoria de suporte
  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF9810FA).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF9810FA), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}