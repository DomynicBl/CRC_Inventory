import 'package:flutter/material.dart';
import 'package:project_sgi/api/machine_service.dart';

import '../Machines/edit_machine_form.dart';

class LastMachinesList extends StatefulWidget {
  const LastMachinesList({super.key});
  @override
  _LastMachinesListState createState() => _LastMachinesListState();
}

class _LastMachinesListState extends State<LastMachinesList> {
  late Future<List<Map<String, dynamic>>> _futureList;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _futureList = MachineService().getLastMachines();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureList,
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
            final id = m['_id'] as String;
            final data = DateTime.parse(m['ultimaAtualizacao']);
            final dateStr = '${data.day}/${data.month}/${data.year}';

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
                    setState(() {
                      _reload();
                    });
                  }
                } catch (e, st) {
                  // se der algum erro não-visto, a gente mostra no console
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
                      // Linha com título + ícone de exclusão
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
                                    content: Text(
                                      'Máquina excluída com sucesso!',
                                    ),
                                  ),
                                );
                                setState(() {
                                  _reload();
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao excluir: $e'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      // Subtítulo (patrimônio)
                      Text('Patrimônio: ${m['patrimonio'] ?? ''}'),

                      const SizedBox(height: 8),

                      // Data no canto inferior esquerdo
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
          },
        );
      },
    );
  }
}
