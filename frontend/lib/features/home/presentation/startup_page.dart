/* Nome: Luigi Mazzoni Targa | RA: 23010918 */

import 'package:flutter/material.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  // Controle do texto de busca
  final TextEditingController _searchController = TextEditingController();

  // Filtro selecionado (Padrão: Todas)
  String _selectedFilter = "Todas";

  // Lista original de dados
  final List<Map<String, dynamic>> startups = [
    {
      "nome": "EcoLoop",
      "descricao": "Logística reversa inteligente para condomínios.",
      "categoria": "Cleantech",
      "estagio": "Nova",
      "preco": 1.50,
      "variacao": "+2.5%",
      "captado": 100000,
      "meta": 150000,
    },
    {
      "nome": "EduVibe",
      "descricao": "Plataforma de aprendizado gamificado para o ENEM.",
      "categoria": "Edtech",
      "estagio": "Em operação",
      "preco": 2.10,
      "variacao": "+1.8%",
      "captado": 300000,
      "meta": 450000,
    },
    {
      "nome": "VitalTrack",
      "descricao": "Pulseiras inteligentes para monitoramento de idosos.",
      "categoria": "Healthtech",
      "estagio": "Em expansão",
      "preco": 4.80,
      "variacao": "-1.5%",
      "captado": 500000,
      "meta": 1200000,
    },
    {
      "nome": "AgroSense",
      "descricao": "Monitoramento de solo em tempo real via IoT.",
      "categoria": "Agrotech",
      "estagio": "Em operação",
      "preco": 3.25,
      "variacao": "+4.2%",
      "captado": 400000,
      "meta": 800000,
    },
    {
      "nome": "SafePay",
      "descricao": "Carteira digital para micro-transações em campus.",
      "categoria": "Fintech",
      "estagio": "Nova",
      "preco": 1.20,
      "variacao": "+0.5%",
      "captado": 150000,
      "meta": 200000,
    },
  ];

  // Função lógica que retorna a lista filtrada
  List<Map<String, dynamic>> get _filteredStartups {
    return startups.where((startup) {
      // Regra de Filtro por Tag (Chip)
      final matchesFilter =
          _selectedFilter == "Todas" ||
          startup['estagio'].toLowerCase() == _selectedFilter.toLowerCase();

      // Regra de Busca por Nome
      final matchesSearch = startup['nome'].toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredStartups;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Startups',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Barra de Busca Funcional
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF141E2D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() {}), // Atualiza a lista enquanto digita
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Buscar startups...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Chips de Filtro Clicáveis
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip("Todas"),
                _buildFilterChip("Nova"),
                _buildFilterChip("Em operação"),
                _buildFilterChip("Em expansão"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Lista de Startups Dinâmica
          Expanded(
            child: filteredList.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhuma startup encontrada",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildStartupCard(filteredList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: const Color(0xFF141E2D),
        selectedColor: const Color(0xFF00A36C),
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
      ),
    );
  }

  Widget _buildStartupCard(Map<String, dynamic> data) {
    double progresso = data['captado'] / data['meta'];
    bool isPositive = data['variacao'].contains('+');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2A3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF0A0A1A),
                ),
                child: const Icon(Icons.business, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['nome'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      data['categoria'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data['estagio'].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data['descricao'],
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Preço do token",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    "R\$ ${data['preco'].toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data['variacao'],
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Capital captado",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Text(
                "R\$ ${data['captado']} / R\$ ${data['meta']}",
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progresso,
            backgroundColor: const Color(0xFF0A0A1A),
            color: const Color(0xFF00A36C),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}
