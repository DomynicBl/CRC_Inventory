import 'package:flutter/material.dart';
import 'package:project_sgi/api/machine_service.dart';

class LastMachinesList extends StatelessWidget {
  const LastMachinesList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: MachineService().getLastMachines(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Erro: ${snap.error}'));
        }
        final machines = snap.data!;
        if (machines.isEmpty) {
          return const Center(child: Text('Nenhuma máquina encontrada.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: machines.length,
          itemBuilder: (_, i) {
            final m = machines[i];
            final data = DateTime.parse(m['dataCadastro']);
            final dateStr = '${data.day}/${data.month}/${data.year}';
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(m['nome'] ?? ''),
                subtitle: Text('Patrimônio: ${m['patrimonio'] ?? ''}'),
                trailing: Text(dateStr),
              ),
            );
          },
        );
      },
    );
  }
}
