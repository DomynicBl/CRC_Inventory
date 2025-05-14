import 'package:flutter/material.dart';
import '../cards/machine_card.dart';

class SearchResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> machines;
  final String searchTerm;
  final VoidCallback onBack;

  const SearchResultScreen({
    Key? key,
    required this.machines,
    required this.searchTerm,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasResults = machines.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado da Busca'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: hasResults
            ? ListView.builder(
                itemCount: machines.length,
                itemBuilder: (context, index) {
                  return MachineCard(
                    machine: machines[index],
                    onUpdate: () {
                      Navigator.pop(context);
                    },
                  );
                },
              )
            : Center(
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Nenhum resultado para: $searchTerm',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
