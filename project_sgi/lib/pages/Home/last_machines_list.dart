import 'package:flutter/material.dart';
import 'dart:convert'; // Importação necessária para JSON
import 'package:http/http.dart' as http; // Importação necessária para chamadas de rede

// A importação do MachineService não é mais necessária aqui
// import '../../api/machine_service.dart'; 
import '../cards/machine_card.dart';
import '../cards/summary_machine_card.dart';

class LastMachineList extends StatefulWidget {
  const LastMachineList({super.key});

  @override
  State<LastMachineList> createState() => _LastMachineListState();
}

class _LastMachineListState extends State<LastMachineList> {
  late Future<List<Map<String, dynamic>>> _issuesFuture;
  
  @override
  void initState() {
    super.initState();
    _issuesFuture = _fetchAndFilterIssues();
  }

  /// --- LÓGICA CORRIGIDA ---
  /// Busca TODAS as máquinas e depois filtra no próprio aplicativo.
  Future<List<Map<String, dynamic>>> _fetchAndFilterIssues() async {
    const String baseUrl = 'https://crc-inventory-j85z.onrender.com';
    // 1. Aponta para a rota principal que já existe
    final uri = Uri.parse('$baseUrl/maquinas');
    
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> allMachines = jsonDecode(response.body);

        // 2. Filtra a lista aqui no Flutter
        final List<Map<String, dynamic>> machinesWithIssues = allMachines.where((machine) {
          // Pega os valores dos campos, tratando casos nulos
          final String problema = machine['problema']?.toString() ?? '';
          final String observacoes = machine['observacoes']?.toString() ?? '';
          
          // Condição: mostra a máquina se o problema OU as observações NÃO estiverem vazios.
          return problema.trim().isNotEmpty || observacoes.trim().isNotEmpty;
        }).cast<Map<String, dynamic>>().toList(); // Converte o resultado para o tipo correto

        return machinesWithIssues;
      } else {
        throw Exception('Falha ao carregar as máquinas (Cód: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  /// Recarrega os dados (usado no "puxar para atualizar").
  Future<void> _handleRefresh() async {
    setState(() {
      // Chama a função com a nova lógica de filtro
      _issuesFuture = _fetchAndFilterIssues();
    });
  }

  /// Exibe o card de detalhes completo em um diálogo.
  void _showMachineDetailsDialog(Map<String, dynamic> machine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        content: MachineCard(
          machine: machine,
          onUpdate: () {
            Navigator.of(context).pop();
            _handleRefresh();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _issuesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // A mensagem de erro agora será mais clara
          return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum chamado em aberto.'));
        }

        final machinesWithIssues = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView.builder(
            itemCount: machinesWithIssues.length,
            itemBuilder: (context, index) {
              final machine = machinesWithIssues[index];
              return SummaryMachineCard(
                machine: machine,
                onTap: () => _showMachineDetailsDialog(machine),
              );
            },
          ),
        );
      },
    );
  }
}
