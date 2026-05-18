/* Nome: Luigi Mazzoni Targa | RA: 23010918 */

import 'package:flutter/material.dart';

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  String _selectedCategory = 'Dúvidas Gerais';
  bool _isLoading = false;

  final List<String> _categories = [
    'Dúvidas Gerais',
    'Problemas com Saldo/Carteira',
    'Erro nas Ordens do Balcão',
    'Segurança e Acesso',
    'Reportar um Bug (Ambiente Beta)',
  ];

  void _submitTicket() {}

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
              icon: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text('Contatar Suporte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Text('Formulário em desenvolvimento...', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}