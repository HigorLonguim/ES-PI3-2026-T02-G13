/* Nome: Luigi Mazzoni Targa | RA: 23010918 */
import 'package:flutter/material.dart';

import 'package:frontend/features/profile/presentation/terms_page.dart';
import 'package:frontend/features/profile/presentation/help_center_page.dart';

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
          'Ajuda e Suporte',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            child: IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu de ações principais (Central, Contato e Termos)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141E2D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  _buildActionTile(
                    icon: Icons.forum_outlined,
                    title: 'Central de Ajuda',
                    subtitle: 'Encontre respostas para suas dúvidas',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HelpCenterPage()),
                      );
                    },
                  ),
                  _divider(),
                  _buildActionTile(
                    icon: Icons.email_outlined,
                    title: 'Contatar Suporte',
                    subtitle: 'Fale diretamente com nossa equipe',
                    onTap: () {},
                  ),
                  _divider(),
                  _buildActionTile(
                    icon: Icons.description_outlined,
                    title: 'Termos e Políticas',
                    subtitle: 'Leia nossos termos de uso e privacidade',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Perguntas Frequentes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Listagem do FAQ (Acordeon)
            _buildFaqTile(
              'Como funciona o investment em startups?',
              'Todas as operações são simuladas...',
            ),
            _buildFaqTile(
              'Os investimentos são reais?',
              'Não, o MesclaInvest é um ambiente pedagógico simulado.',
            ),
            _buildFaqTile(
              'Como posso vender meus tokens?',
              'Você pode colocar ofertas de venda no Balcão...',
            ),
            _buildFaqTile(
              'Existe taxa de transação?',
              'No ambiente simulado, não há taxas reais.',
            ),
            const SizedBox(height: 32),
            
            // Card informativo com horários de atendimento
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF101A3D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horário de Atendimento:',
                    style: TextStyle(
                      color: Color(0xFF60A5FA),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Segunda a Sexta: 9h às 18h\nSábado: 9h às 13h',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Componente reutilizável para as linhas de menu de ação
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap, 
  }) {
    return ListTile(
      onTap: onTap, 
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF9810FA).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF9810FA), size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }

  // Componente expansível para perguntas do FAQ
  Widget _buildFaqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ExpansionTile(
        iconColor: const Color(0xFF9810FA),
        collapsedIconColor: Colors.grey,
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(color: Color(0xFF99A1AF), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // Divisor de linhas do menu
  Widget _divider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.05),
      height: 1,
      indent: 20,
      endIndent: 20,
    );
  }
}