// Autoria: Felipe Sousa - RA: 22018160
/* Nome: Luigi Mazzoni Targa | RA: 23010918 */

import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Map para controlar o estado de cada Switch
  final Map<String, bool> _settings = {
    'email': true,
    'push': true,
    'price': true,
    'news': true,
    'answers': false,
  };

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
          'Notificações',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141E2D), // Card escuro
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              _buildNotificationTile(
                id: 'email',
                icon: Icons.email_outlined,
                iconColor: Colors.blue,
                title: 'Notificações por Email',
                subtitle: 'Receba atualizações importantes por email',
              ),
              _divider(),
              _buildNotificationTile(
                id: 'push',
                icon: Icons.notifications_none_outlined,
                iconColor: Colors.purpleAccent,
                title: 'Notificações Push',
                subtitle: 'Receba notificações em tempo real',
              ),
              _divider(),
              _buildNotificationTile(
                id: 'price',
                icon: Icons.trending_up_rounded,
                iconColor: Colors.greenAccent,
                title: 'Alertas de Preço',
                subtitle: 'Seja notificado sobre variações significativas',
              ),
              _divider(),
              _buildNotificationTile(
                id: 'news',
                icon: Icons.notifications_active_outlined,
                iconColor: Colors.orange,
                title: 'Novidades das Startups',
                subtitle: 'Receba atualizações das suas startups',
              ),
              _divider(),
              _buildNotificationTile(
                id: 'answers',
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: Colors.pinkAccent,
                title: 'Respostas a Perguntas',
                subtitle:
                    'Seja notificado quando suas perguntas forem respondidas',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para cada linha de notificação
  Widget _buildNotificationTile({
    required String id,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
      trailing: Switch(
        value: _settings[id] ?? false,
        activeThumbColor: const Color(0xFF00A36C), // Verde do protótipo
        activeTrackColor: const Color(0xFF00A36C).withValues(alpha: 0.3),
        inactiveThumbColor: Colors.grey[400],
        inactiveTrackColor: Colors.white10,
        onChanged: (bool value) {
          setState(() {
            _settings[id] = value;
          });
        },
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.05),
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
