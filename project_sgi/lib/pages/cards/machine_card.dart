import 'package:flutter/material.dart';
import '../../api/machine_service.dart';
import '../Machines/edit_machine_form.dart';

class MachineCard extends StatelessWidget {
  final Map<String, dynamic> machine;
  final VoidCallback onUpdate;

  const MachineCard({
    super.key,
    required this.machine,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final m = machine;
    final id = m['_id'];
    final dateStr = m['data'] ?? '';

    return InkWell(
      onTap: () async {
        try {
          final updated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => EditMachineForm(machine: m),
            ),
          );
          if (updated == true) {
            onUpdate(); // informa à tela pai para atualizar
          }
        } catch (e, st) {
          debugPrint('Erro ao abrir edição: $e\n$st');
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      m['nome'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      try {
                        await MachineService().deleteMachine(id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Máquina excluída com sucesso!'),
                          ),
                        );
                        onUpdate(); // informa à tela pai para atualizar
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao excluir: $e')),
                        );
                      }
                    },
                  ),
                ],
              ),
              Text('Patrimônio: ${m['patrimonio'] ?? ''}'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  dateStr,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
