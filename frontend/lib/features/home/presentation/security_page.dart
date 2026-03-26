/* Nome: Luigi Mazzoni Targa | RA: 23010918 */

import 'package:flutter/material.dart';
import 'package:frontend/features/home/presentation/change_password_page.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A), // Fundo padrão do app
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
          'Segurança',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Card de Opções de Segurança (Estilo Sóbrio da Imagem)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141E2D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  _buildSecurityTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Autenticação de Dois Fatores',
                    subtitle: 'Desativado — Configure agora',
                    onTap: () {
                      // Lógica para abrir configuração de 2FA
                    },
                  ),
                  _divider(),
                  _buildSecurityTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Alterar Senha',
                    subtitle: null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Card de Dicas de Segurança (Azul Escuro)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF101A3D), // Azul bem escuro
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dica de Segurança:',
                    style: TextStyle(
                      color: Color(0xFF60A5FA), // Azul claro para o título
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Dicas em formato de lista (sem ícones na imagem)
                  Text(
                    '• Use senhas fortes e únicas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.8,
                    ),
                  ),
                  Text(
                    '• Ative a autenticação de dois fatores',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.8,
                    ),
                  ),
                  Text(
                    '• Não compartilhe seus dados de acesso',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.8,
                    ),
                  ),
                  Text(
                    '• Salve seus códigos de backup em local seguro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  // Constrói os itens do menu de segurança com estilo sóbrio (ícones cinza)
  Widget _buildSecurityTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05), // Fundo cinza bem suave
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.grey[400], size: 22), // Ícone cinza
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      // Exibe o subtítulo apenas se ele for fornecido
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }

  Widget _divider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.05),
      height: 1,
      indent: 20,
      endIndent: 20,
    );
  }
}
