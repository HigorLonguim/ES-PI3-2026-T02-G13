/* Nome: Luigi Mazzoni Targa | RA: 23010918 */

import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Quando você instalar o Firebase, use isso

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Simulação de saldo local (depois você integrará com Firebase)
  double _saldo = 50000.00;

  // Função que simula o requisito 5.3: Carregamento de saldo fictício
  void _adicionarSaldo() {
    TextEditingController _valorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141E2D),
          title: const Text('Simular Depósito', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _valorController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Valor (R\$)',
              labelStyle: TextStyle(color: Color(0xFF00A36C)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A36C)),
              onPressed: () {
                setState(() {
                  double valor = double.tryParse(_valorController.text) ?? 0.0;
                  _saldo += valor;
                  // AQUI você chamaria seu serviço do Firebase para persistir o dado
                  // FirebaseFirestore.instance.collection('usuarios').doc(ID).update({'saldo': _saldo});
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('R\$ ${_valorController.text} adicionados com sucesso!')),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A1A), Color(0xFF13132B)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Perfil',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                
                // Avatar e Nome (Mantendo seus dados)
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF00A36C),
                        child: Text('I', style: TextStyle(fontSize: 40, color: Colors.white)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Investidor Demo',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        '12321',
                        style: TextStyle(color: Color(0xFF99A1AF), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                _buildSectionTitle('Carteira digital'),
                
                // Card de Carteira Digital com o Saldo Dinâmico
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141E2D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E2A3A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF00A36C), size: 20),
                          SizedBox(width: 8),
                          Text('Saldo disponível (simulado)', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${_saldo.toStringAsFixed(2)}', // Aqui exibe o saldo que muda
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _adicionarSaldo, // Chama a função de adicionar
                          icon: const Icon(Icons.add, color: Color(0xFF00A36C)),
                          label: const Text('Adicionar saldo', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF1E3A3A)),
                            backgroundColor: const Color(0xFF0D2D26),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionTitle('Dados pessoais'),
                _buildInfoTile(Icons.person_outline, 'Nome completo', 'Investidor Demo'),
                _buildInfoTile(Icons.email_outlined, 'E-mail', '12321'),
                _buildInfoTile(Icons.credit_card_outlined, 'CPF', '123.456.789-00'),
                
                const SizedBox(height: 24),
                
                _buildSectionTitle('Segurança'),
                _buildSecurityTile(),
                const SizedBox(height: 12),
                _buildLogoutTile(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // Métodos auxiliares mantidos conforme o seu original
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2A3A)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF141E2D), borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.shield_outlined, color: Colors.orangeAccent),
        title: const Text('Autenticação multifator (2FA)', style: TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: const Text('Camada extra de segurança via SMS', style: TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Switch(value: false, onChanged: (v) {}, activeColor: const Color(0xFF00A36C)),
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF141E2D), borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => Navigator.pop(context),
        leading: const Icon(Icons.logout, color: Colors.redAccent),
        title: const Text('Sair da conta', style: TextStyle(color: Colors.redAccent)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0A0A1A),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF00A36C),
      unselectedItemColor: Colors.grey,
      currentIndex: 3,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Startups'),
        BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Balcão'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), label: 'Portfólio'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}