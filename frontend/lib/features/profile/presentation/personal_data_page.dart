// Autoria: Felipe Sousa - RA: 22018160
/* Nome: Luigi Mazzoni Targa | RA: 23010918 */
// Nome: Higor Vedovello Longuim RA: 23000291

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/auth/auth_session_storage.dart';
import '../../../core/widgets/app_status_indicator.dart';

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
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final nome =
        await _sessionStorage.getUserName() ?? firebaseUser?.displayName ?? '';
    final email =
        await _sessionStorage.getUserEmail() ?? firebaseUser?.email ?? '';
    final cpf = await _sessionStorage.getUserCpf() ?? '';
    final telefone =
        await _sessionStorage.getUserTelefone() ??
        firebaseUser?.phoneNumber ??
        '';

    if (!mounted) return;
    setState(() {
      _nome = nome;
      _email = email;
      _cpf = _formatCpf(cpf);
      _telefone = _formatTelefone(telefone);
      _isLoading = false;
    });
  }

  Future<void> _openEditModal() async {
    final nameController = TextEditingController(text: _nome);
    final emailController = TextEditingController(text: _email);
    final cpfController = TextEditingController(text: _cpf);
    final phoneController = TextEditingController(text: _telefone);

    final shouldSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141E2D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(label: 'Nome', controller: nameController),
              const SizedBox(height: 12),
              _field(label: 'Email', controller: emailController),
              const SizedBox(height: 12),
              _field(label: 'CPF', controller: cpfController),
              const SizedBox(height: 12),
              _field(label: 'Telefone', controller: phoneController),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9810FA),
                  ),
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (shouldSave != true || !mounted) {
      nameController.dispose();
      emailController.dispose();
      cpfController.dispose();
      phoneController.dispose();
      return;
    }

    final rawName = nameController.text.trim();
    final rawEmail = emailController.text.trim();
    final rawCpf = cpfController.text.trim();
    final rawPhone = phoneController.text.trim();

    nameController.dispose();
    emailController.dispose();
    cpfController.dispose();
    phoneController.dispose();

    if (rawName.isEmpty || rawEmail.isEmpty) {
      _show('Nome e email sao obrigatorios.', AppStatusType.error);
      return;
    }

    final cpfDigits = rawCpf.replaceAll(RegExp(r'\D'), '');
    if (cpfDigits.isNotEmpty && cpfDigits.length != 11) {
      _show('CPF invalido. Informe 11 digitos.', AppStatusType.error);
      return;
    }

    final phoneDigits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (phoneDigits.isNotEmpty && phoneDigits.length < 10) {
      _show('Telefone invalido.', AppStatusType.error);
      return;
    }

    await _sessionStorage.saveUserName(rawName);
    await _sessionStorage.saveUserEmail(rawEmail);
    await _sessionStorage.saveUserCpf(cpfDigits);
    await _sessionStorage.saveUserTelefone(phoneDigits);

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await firebaseUser.updateDisplayName(rawName);
      await firebaseUser.reload();
    }

    if (!mounted) return;

    setState(() {
      _nome = rawName;
      _email = rawEmail;
      _cpf = _formatCpf(cpfDigits);
      _telefone = _formatTelefone(phoneDigits);
    });

    _show('Dados pessoais atualizados com sucesso.', AppStatusType.success);
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

  void _show(String message, AppStatusType type) {
    showAppStatusSnackBar(context: context, message: message, type: type);
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
        actions: [
          IconButton(onPressed: _openEditModal, icon: const Icon(Icons.edit)),
        ],
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
                    value: _nome.isNotEmpty ? _nome : '-',
                  ),
                  const SizedBox(height: 12),
                  _buildDataCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _email.isNotEmpty ? _email : '-',
                  ),
                  const SizedBox(height: 12),
                  _buildDataCard(
                    icon: Icons.credit_card_outlined,
                    label: 'CPF',
                    value: _cpf.isNotEmpty ? _cpf : '-',
                  ),
                  const SizedBox(height: 12),
                  _buildDataCard(
                    icon: Icons.phone_android_outlined,
                    label: 'Telefone',
                    value: _telefone.isNotEmpty ? _telefone : '-',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1C273A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
