/* Nome: Luigi Mazzoni Targa | RA: 23010918 */

import 'package:flutter/material.dart';
import 'package:frontend/features/home/presentation/help_page.dart';
import 'package:frontend/features/home/presentation/notifications_page.dart';
import 'package:frontend/features/home/presentation/personal_data_page.dart';
import 'package:frontend/features/home/presentation/security_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      // Faz o corpo da tela subir até o topo, atrás da barra de status
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGradientHeader(),
            const SizedBox(height: 24),
            _buildMenuCard(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
            const SizedBox(height: 16),
            const Text(
              'Versão 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 1. Header com Gradiente Roxo e Informações do Usuário
  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A1BFF), Color(0xFF9810FA)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          // Avatar com borda branca
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF8A3FFF),
              child: Text(
                'J',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Nome e Email
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'João Silva',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'asdasd@mail.com',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Card Único que agrupa as opções de menu (Estilo da Imagem)
  Widget _buildMenuCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.person_outline,
            iconColor: Colors.blueAccent,
            title: 'Dados Pessoais',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PersonalDataPage(),
                ),
              );
            },
          ),
          _divider(),
          _buildMenuTile(
            icon: Icons.shield_outlined,
            iconColor: Colors.greenAccent,
            title: 'Segurança',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecurityPage()),
              );
            },
          ),
          _divider(),
          _buildMenuTile(
            icon: Icons.notifications_none_outlined,
            iconColor: Colors.deepPurpleAccent,
            title: 'Notificações',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),
          _divider(),
          _buildMenuTile(
            icon: Icons.help_outline_outlined,
            iconColor: Colors.orangeAccent,
            title: 'Ajuda e Suporte',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget para cada item do menu dentro do card
  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
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

  // 3. Botão de Sair Estilizado
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
            side: const BorderSide(color: Colors.redAccent, width: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.redAccent, size: 20),
              SizedBox(width: 10),
              Text(
                'Sair da Conta',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
