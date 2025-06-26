import 'package:flutter/material.dart';
import 'package:project_sgi/api/machine_service.dart';
import '../cards/machine_card.dart';

class LastMachineList extends StatefulWidget {
  const LastMachineList({super.key});

  @override
  State<LastMachineList> createState() => _LastMachineListState();
}

class _LastMachineListState extends State<LastMachineList> {
  List<Map<String, dynamic>> machines = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Garante que o estado não seja atualizado se o widget for removido
    if (!mounted) return;
    setState(() => loading = true);
    
    try {
      // Chama o método correto que agora existe no serviço
      final loadedMachines = await MachineService().getLastMachines();
      if (mounted) {
        setState(() {
          machines = loadedMachines;
          loading = false;
        });
      }
    } catch (e) {
      if(mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar máquinas: $e'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (machines.isEmpty) {
      return const Center(child: Text('Nenhuma máquina cadastrada.'));
    }
    return RefreshIndicator(
      onRefresh: _load, // Permite "puxar para atualizar"
      child: ListView.builder(
        itemCount: machines.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: MachineCard(machine: machines[index], onUpdate: _load),
          );
        },
      ),
    );
  }
}
