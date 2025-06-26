import 'package:flutter/material.dart';

// O caminho para o MachineCard pode precisar de ajuste
import '../cards/machine_card.dart'; 

// Widget renomeado para corresponder ao uso em map_page
// e refatorado para não usar um Scaffold, pois ele é embutido em outra tela.
class SearchResultWidget extends StatelessWidget {
  final List<Map<String, dynamic>> machines;
  final String searchTerm;
  final VoidCallback onUpdate; // Callback para atualizar a busca

  const SearchResultWidget({
    Key? key,
    required this.machines,
    required this.searchTerm,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (machines.isEmpty) {
      // Mensagem para quando não há resultados
      return Expanded(
        child: Center(
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Nenhum resultado encontrado para: "$searchTerm"',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    // Lista de resultados
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: machines.length,
        itemBuilder: (context, index) {
          // O MachineCard provavelmente navega para uma tela de detalhes
          // e chama onUpdate quando volta para recarregar a lista.
          return MachineCard(
            machine: machines[index],
            onUpdate: onUpdate,
          );
        },
      ),
    );
  }
}
