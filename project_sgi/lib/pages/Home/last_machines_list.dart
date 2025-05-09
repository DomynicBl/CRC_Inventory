import 'package:flutter/material.dart';
import '../../database/database_service.dart';

class LastMachinesList extends StatefulWidget {
  const LastMachinesList({super.key});

  @override
  State<LastMachinesList> createState() => _LastMachinesListState();
}

class _LastMachinesListState extends State<LastMachinesList> {
  List<Map<String, dynamic>> _machines = [];

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  Future<void> _loadMachines() async {
    final all = await DatabaseService().getAllMachines();
    setState(() {
      // ordena pela data decrescente e pega as últimas 10
      _machines = all.reversed.take(10).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _machines.isEmpty
        ? const Center(child: Text("Nenhuma máquina cadastrada ainda."))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _machines.length,
            itemBuilder: (context, index) {
              final machine = _machines[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(machine['nome'] ?? 'Sem nome', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Patrimônio: ${machine['patrimonio'] ?? '-'}'),
                      Text('Prédio: ${machine['predio'] ?? '-'} | Sala: ${machine['sala'] ?? '-'}'),
                      Text('Monitor: ${machine['monitor'] ?? '-'}'),
                      Text('Modelo: ${machine['modelo'] ?? '-'}'),
                      Text('Processador: ${machine['processador'] ?? '-'}'),
                      Text('Memória: ${machine['memoria'] ?? '-'}'),
                      Text('Data de Cadastro: ${machine['dataCadastro'] ?? '-'}'),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
