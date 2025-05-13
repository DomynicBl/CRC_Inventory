import 'package:flutter/material.dart';
import 'package:project_sgi/api/machine_service.dart';

class LastMachinesList extends StatelessWidget {
  const LastMachinesList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: MachineService().getLastMachines(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma máquina cadastrada.'));
        }

        final machines = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: machines.length,
          itemBuilder: (context, index) {
            final machine = machines[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ListTile(
                title: Text(machine['nome'] ?? 'Sem nome'),
                subtitle: Text('Patrimônio: ${machine['patrimonio'] ?? 'N/A'}'),
                trailing: Text(
                  _formatDate(machine['dataCadastro']),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    final date = DateTime.parse(isoString);
    return '${date.day}/${date.month}/${date.year}';
  }
}
