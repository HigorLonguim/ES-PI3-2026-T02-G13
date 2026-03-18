/* Nome: Luigi Mazzoni Targa | RA: 23010918 */

import 'package:flutter/material.dart';
import 'help_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- Estados da Tela (Simulação Requisitos 5.1, 5.3 e 5.5) ---
  double _saldo = 50000.00;
  bool _isMfaEnabled = false;

  // Estados de visibilidade das senhas (para o BottomSheet)
  bool _obscureAtual = true;
  bool _obscureNova = true;
  bool _obscureConfirmar = true;

  // --- FUNÇÃO: Simular Recarga de Saldo Profissional (Req. 5.3) ---
  void _adicionarSaldo() {
    TextEditingController _valorController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 24, 
            left: 24, 
            right: 24, 
            bottom: MediaQuery.of(context).viewInsets.bottom + 24
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF141E2D),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              const Text('Simular Depósito', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('O saldo adicionado é fictício e será utilizado apenas para testes de investimento.', style: TextStyle(color: Color(0xFF99A1AF), fontSize: 14)),
              const SizedBox(height: 24),
              
              TextField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: 'R\$ ',
                  prefixStyle: const TextStyle(color: Color(0xFF00A36C), fontSize: 24),
                  labelText: 'Valor do Aporte',
                  labelStyle: const TextStyle(color: Color(0xFF99A1AF), fontSize: 16),
                  filled: true,
                  fillColor: const Color(0xFF0A0A1A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00A36C))),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickValueButton('1.000', _valorController),
                  _buildQuickValueButton('5.000', _valorController),
                  _buildQuickValueButton('10.000', _valorController),
                ],
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      double valor = double.tryParse(_valorController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
                      _saldo += valor;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF00A36C),
                        content: Text('R\$ ${_valorController.text} adicionados com sucesso!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A36C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirmar Depósito', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickValueButton(String value, TextEditingController controller) {
    return GestureDetector(
      onTap: () => controller.text = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1E2A3A)),
        ),
        child: Text('+ R\$ $value', style: const TextStyle(color: Color(0xFF00A36C), fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- FUNÇÃO: Ativação de MFA (Req. 5.5) ---
  void _showMfaActivationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141E2D),
        title: const Text('Ativar 2FA', style: TextStyle(color: Colors.white)),
        content: const Text('Deseja confirmar a ativação do MFA para sua conta?', style: TextStyle(color: Color(0xFF99A1AF))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A36C)),
            onPressed: () {
              setState(() => _isMfaEnabled = true);
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  // --- FUNÇÃO: Troca de Senha Profissional (Req. 5.1) ---
  void _showChangePasswordBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Color(0xFF141E2D),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text('Alterar Senha', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildPasswordField('Senha Atual', _obscureAtual, () => setModalState(() => _obscureAtual = !_obscureAtual)),
              const SizedBox(height: 16),
              _buildPasswordField('Nova Senha', _obscureNova, () => setModalState(() => _obscureNova = !_obscureNova)),
              const SizedBox(height: 16),
              _buildPasswordField('Confirmar Nova Senha', _obscureConfirmar, () => setModalState(() => _obscureConfirmar = !_obscureConfirmar)),
              const SizedBox(height: 32),
              _buildGradientButton('Salvar Nova Senha', () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0A1A), Color(0xFF13132B)]),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text('Perfil', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildSectionTitle('Carteira digital'),
                _buildWalletCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('Dados pessoais'),
                _buildInfoTile(Icons.person_outline, 'Nome completo', 'Investidor Demo'),
                _buildInfoTile(Icons.email_outlined, 'E-mail', 'demo@puc-campinas.edu.br'),
                const SizedBox(height: 24),
                _buildSectionTitle('Configurações e Segurança'),
                _buildSecuritySwitchTile(),
                const SizedBox(height: 8),
                _buildActionTile(Icons.lock_reset_outlined, 'Trocar senha da conta', Colors.white, _showChangePasswordBottomSheet),
                const SizedBox(height: 8),
                _buildActionTile(Icons.help_outline, 'Como funciona / FAQ', const Color(0xFF9810FA), () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpPage()));
                }),
                const SizedBox(height: 12),
                _buildLogoutTile(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets de Suporte ---

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(radius: 50, backgroundColor: Color(0xFF00A36C), child: Text('I', style: TextStyle(fontSize: 40, color: Colors.white))),
          const SizedBox(height: 16),
          const Text('Investidor Demo', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('RA: 23010918', style: TextStyle(color: Color(0xFF99A1AF), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF141E2D), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1E2A3A))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Saldo disponível (simulado)', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('R\$ ${_saldo.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAddBalanceButton(),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, bool obscure, VoidCallback toggle) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF99A1AF)),
        filled: true,
        fillColor: const Color(0xFF0A0A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey), onPressed: toggle),
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF4F39F6), Color(0xFF9810FA)])),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAddBalanceButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _adicionarSaldo,
        icon: const Icon(Icons.add, color: Color(0xFF00A36C)),
        label: const Text('Adicionar saldo', style: TextStyle(color: Colors.white)),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF1E3A3A)), backgroundColor: const Color(0xFF0D2D26), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)));
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF141E2D), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [Icon(icon, color: Colors.grey), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)), Text(value, style: const TextStyle(color: Colors.white))])]),
    );
  }

  Widget _buildSecuritySwitchTile() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF141E2D), borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.shield_outlined, color: Colors.orangeAccent),
        title: const Text('Autenticação multifator (MFA)', style: TextStyle(color: Colors.white, fontSize: 14)),
        trailing: Switch(value: _isMfaEnabled, activeColor: const Color(0xFF00A36C), onChanged: (v) => v ? _showMfaActivationDialog() : setState(() => _isMfaEnabled = false)),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF141E2D), borderRadius: BorderRadius.circular(12)),
      child: ListTile(onTap: onTap, leading: Icon(icon, color: color), title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)), trailing: const Icon(Icons.chevron_right, color: Colors.grey)),
    );
  }

  Widget _buildLogoutTile() {
    return Container(decoration: BoxDecoration(color: const Color(0xFF141E2D), borderRadius: BorderRadius.circular(12)), child: ListTile(onTap: () => Navigator.pop(context), leading: const Icon(Icons.logout, color: Colors.redAccent), title: const Text('Sair da conta', style: TextStyle(color: Colors.redAccent))));
  }
}