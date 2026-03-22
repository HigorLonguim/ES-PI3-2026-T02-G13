/* Nome: Felipe Sousa de Almeida | RA: 22018160 */
/* Nome: Luigi Mazzoni Targa | RA: 23010918 */

import 'package:flutter/material.dart';
import 'startup_page.dart'; 
import 'profile_page.dart'; 

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  // Lista das páginas das abas
  final List<Widget> _pages = [
    const StartupPage(), // Aba 0
    const Center(
      child: Text('Balcão', style: TextStyle(color: Colors.white)),
    ), // Aba 1
    const Center(
      child: Text('Portfólio', style: TextStyle(color: Colors.white)),
    ), // Aba 2
    const ProfilePage(), // Aba 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0A0A1A),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00A36C),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Startups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Balcão',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Portfólio',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
