import 'package:flutter/material.dart';
import '../cards/machine_card.dart';

class SearchResultWidget extends StatelessWidget {
  final List<Map<String, dynamic>> machines;
  final String searchTerm;
  final VoidCallback onUpdate; // Callback para MachineCard

  const SearchResultWidget({
    Key? key,
    required this.machines,
    required this.searchTerm,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasResults = machines.isNotEmpty;


    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adiciona padding lateral
        child: hasResults
            ? ListView.builder(
                itemCount: machines.length,
                itemBuilder: (context, index) {
                  return MachineCard(
                    machine: machines[index],
                    onUpdate: onUpdate,
                  );
                },
              )
            : Center(
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 16), // Ajustado
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Nenhum resultado para: $searchTerm',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}