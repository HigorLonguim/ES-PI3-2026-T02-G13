// Autoria: Felipe Sousa - RA: 22018160
/* Nome: Luigi Mazzoni Targa | RA: 23010918 */
// Nome: Higor Vedovello Longuim RA: 23000291

import 'package:flutter/material.dart';
import '../../../core/auth/auth_session_storage.dart';

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  final AuthSessionStorage _sessionStorage = AuthSessionStorage();

  String _nome = '';
  String _email = '';
  String _cpf = '';
  String _telefone = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final nome = await _sessionStorage.getUserName() ?? '';
    final email = await _sessionStorage.getUserEmail() ?? '';
    final cpf = await _sessionStorage.getUserCpf() ?? '';
    final telefone = await _sessionStorage.getUserTelefone() ?? '';

    if (!mounted) return;
    setState(() {
      _nome = nome;
      _email = email;
      _cpf = _formatCpf(cpf);
      _telefone = _formatTelefone(telefone);
      _isLoading = false;
    });
  }

  String _formatCpf(String rawCpf) {
    final digits = rawCpf.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) {
      return rawCpf;
    }
    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.'
        '${digits.substring(6, 9)}-${digits.substring(9, 11)}';
  }

  String _formatTelefone(String rawTelefone) {
    final digits = rawTelefone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-'
          '${digits.substring(7, 11)}';
    }
    if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-'
          '${digits.substring(6, 10)}';
    }
    return rawTelefone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
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
          'Dados Pessoais',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF9810FA)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDataCard(
                    icon: Icons.person_outline,
                    label: 'Nome Completo',
                    value: _nome.isNotEmpty ? _nome : '—',
                  ),
                  const SizedBox(height: 12),
                  _buildDataCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _email.isNotEmpty ? _email : '—',
                  ),
                  const SizedBox(height: 12),
                  _buildDataCard(
                    icon: Icons.credit_card_outlined,
                    label: 'CPF',
                    value: _cpf.isNotEmpty ? _cpf : '—',
                  ),
                  const SizedBox(height: 12),
                  _buildDataCard(
                    icon: Icons.phone_android_outlined,
                    label: 'Telefone',
                    value: _telefone.isNotEmpty ? _telefone : '—',
                  ),
                  const SizedBox(height: 24),
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
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: 'Importante: ',
                            style: TextStyle(
                              color: Color(0xFF60A5FA),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Para alterar seus dados pessoais, entre em contato com o suporte.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDataCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF9810FA),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
