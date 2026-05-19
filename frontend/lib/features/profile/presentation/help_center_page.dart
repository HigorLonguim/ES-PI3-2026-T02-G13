/* Nome: Luigi Mazzoni Targa | RA: 23010918 */

import 'package:flutter/material.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();

  // Dúvidas de suporte técnico e usabilidade do sistema
  final List<Map<String, dynamic>> _supportItems = [
    {
      'question': 'Esqueci minha senha de acesso, como posso recuperar?',
      'answer':
          'Na tela de login, clique em "Esqueci minha senha". Insira o e-mail cadastrado e você receberá um link simulado para redefinir suas credenciais de acesso com segurança.',
    },
    {
      'question': 'Meu saldo fictício sumiu ou não atualizou, o que fazer?',
      'answer':
          'Isso pode ocorrer devido à latência da API simulada. Vá até o painel principal, puxe a tela para baixo para forçar o "Pull-to-Refresh" ou faça logout e login novamente para sincronizar a carteira.',
    },
    {
      'question': 'Como faço para alterar meus dados cadastrais?',
      'answer':
          'Acesse a aba "Perfil" no menu inferior e clique na opção "Dados Pessoais". Lá você conseguirá editar suas informações cadastrais e atualizar sua foto de perfil.',
    },
    {
      'question':
          'O aplicativo está travando ou fechando sozinho, como reportar?',
      'answer':
          'Como este é um ambiente em desenvolvimento (Beta), pedimos que limpe o cache do navegador ou app. Caso persista, tire um print do erro e envie para o e-mail do suporte com o log técnico.',
    },
    {
      'question': 'Por que minha ordem no Balcão de Negócios está "Pendente"?',
      'answer':
          'Uma ordem fica pendente até encontrar outro usuário com uma intenção de negociação equivalente (preço e quantidade). Se preferir, você pode cancelar a ordem a qualquer momento no seu histórico.',
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
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 24,
              ),
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
            // Campo de busca superior
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
              'Suporte Técnico e Conta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Listagem com as novas dúvidas técnicas resolvidas
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _supportItems.length,
              itemBuilder: (context, index) {
                final item = _supportItems[index];
                return _buildSupportBox(
                  question: item['question'],
                  answer: item['answer'],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Caixa expansível para os itens de suporte técnico
  Widget _buildSupportBox({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2D),
        borderRadius: BorderRadius.circular(16),
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
