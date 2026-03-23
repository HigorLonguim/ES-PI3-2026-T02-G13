// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';
import '../navigation/app_route.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/signup_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/home/presentation/help_page.dart';
import '../../features/home/presentation/main_navigation_page.dart';
import '../../features/home/presentation/profile_page.dart';
import '../../features/home/presentation/startup_page.dart';

class DebugMenuOverlay extends StatefulWidget {
  final Widget child;

  const DebugMenuOverlay({super.key, required this.child});

  @override
  State<DebugMenuOverlay> createState() => _DebugMenuOverlayState();
}

class _DebugMenuOverlayState extends State<DebugMenuOverlay> {
  Offset _offset = const Offset(20, 100);

  void _showDebugMenu(BuildContext context) {
    final navigator = AppRoute.navigatorKey.currentState;
    if (navigator == null) return;

    showModalBottomSheet(
      context: navigator.context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Navegador de Debug',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pressione para navegar rapidamente entre as telas.',
                    style: TextStyle(color: Color(0xFF99A1AF), fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildSection('Autenticação'),
                        _buildMenuItem('Login', const LoginPage(), Icons.login),
                        _buildMenuItem('SignUp', const SignUpPage(), Icons.person_add),
                        const SizedBox(height: 16),
                        _buildSection('Principal'),
                        _buildMenuItem('Página Inicial (Home)', const HomePage(), Icons.home),
                        _buildMenuItem('Navegação Principal', const MainNavigationPage(), Icons.navigation),
                        _buildMenuItem('Portfolio/Startups', const StartupPage(), Icons.business),
                        const SizedBox(height: 16),
                        _buildSection('Usuário'),
                        _buildMenuItem('Perfil', const ProfilePage(), Icons.person),
                        _buildMenuItem('Ajuda / FAQ', const HelpPage(), Icons.help),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF00A36C),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, Widget page, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2A3A)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          final navigator = AppRoute.navigatorKey.currentState;
          if (navigator != null) {
            navigator.pop(); // Fecha o bottom sheet
            navigator.push(AppRoute(page)); // Vai para a página
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => Stack(
                children: [
                  widget.child,
                  _buildDraggableButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableButton() {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: Draggable(
        feedback: _buildFloatingButton(isFeedback: true),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          setState(() {
            _offset = details.offset;
          });
        },
        child: _buildFloatingButton(),
      ),
    );
  }

  Widget _buildFloatingButton({bool isFeedback = false}) {
    return Opacity(
      opacity: isFeedback ? 0.7 : 1.0,
      child: GestureDetector(
        onTap: isFeedback ? null : () => _showDebugMenu(context),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00A36C), Color(0xFF44D17A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00A36C).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.bug_report,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
