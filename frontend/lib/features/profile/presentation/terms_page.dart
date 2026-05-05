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
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.1),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Termos e Políticas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Aceite dos Termos'),
            _buildContentText(
              'Ao acessar o MesclaInvest, você concorda em cumprir estes termos de serviço e todas as leis aplicáveis. Se você não concordar com algum destes termos, está proibido de usar ou acessar este aplicativo.',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('2. Natureza Acadêmica'),
            _buildContentText(
              'O MesclaInvest é uma plataforma desenvolvida exclusivamente para fins pedagógicos na disciplina de Engenharia de Software. Todas as startups, valores de mercado, moedas (tokens) e transações exibidas são fictícias e não possuem valor financeiro real ou validade jurídica de investimento.',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('3. Proteção de Dados (LGPD)'),
            _buildContentText(
              'Os dados coletados (como nome e e-mail) são utilizados apenas para a simulação das funcionalidades do sistema. Não realizamos o compartilhamento de informações pessoais com terceiros fora do escopo acadêmico da PUC-Campinas.',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('4. Isenção de Responsabilidade'),
            _buildContentText(
              'Os materiais no app MesclaInvest são fornecidos "como estão". Não oferecemos garantias de lucro ou precisão nos dados de mercado simulados, uma vez que o objetivo é o aprendizado de arquitetura de software e desenvolvimento mobile.',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('5. Modificações'),
            _buildContentText(
              'O grupo de desenvolvimento reserva-se o direito de revisar estes termos de serviço a qualquer momento, visando a melhoria do projeto ou adequação às orientações da disciplina.',
            ),
            const SizedBox(height: 40),

            // Rodapé com data de atualização
            Center(
              child: Column(
                children: [
                  Text(
                    'Última atualização: 05 de Maio de 2026',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2026 MesclaInvest Team',
                    style: TextStyle(color: Colors.grey[700], fontSize: 11),
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

  // Widget para títulos de seção
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget para o corpo de texto
  Widget _buildContentText(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(
        color: Color(0xFF99A1AF),
        fontSize: 14,
        height: 1.6,
      ),
    );
  }
}