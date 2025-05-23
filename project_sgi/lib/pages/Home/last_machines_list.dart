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
    setState(() => loading = true);
    machines = await MachineService().getLastMachines();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (machines.isEmpty) {
      return const Center(child: Text('Nenhuma máquina cadastrada.'));
    }

    return ListView.builder(
      itemCount: machines.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: MachineCard(machine: machines[index], onUpdate: _load),
        );
      },
    );
  }
}
