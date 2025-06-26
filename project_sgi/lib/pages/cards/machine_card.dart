import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MachineCard extends StatelessWidget {
  final Map<String, dynamic> machine;
  final VoidCallback onUpdate; // Mantido para futuras interações

  const MachineCard({
    Key? key,
    required this.machine,
    required this.onUpdate,
  }) : super(key: key);

  // Widget auxiliar para criar as linhas de especificação
  Widget _buildSpecRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink(); // Não mostra a linha se não houver valor
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  // Widget auxiliar para criar os títulos de seção
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Formata a data de cadastro
    String formattedDate = 'Data indisponível';
    if (machine['dataCadastro'] != null) {
      try {
        final date = DateTime.parse(machine['dataCadastro']);
        formattedDate = DateFormat("dd/MM/yyyy - HH:mm'h'").format(date);
      } catch (e) {
        // Tratar erro de parsing se necessário
      }
    }
    
    final problemDescription = machine['problema'];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- SEÇÃO SUPERIOR: IMAGEM E DADOS PRINCIPAIS ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem da Máquina
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    'https://placehold.co/100x120/e2e8f0/334155?text=PC', // Imagem placeholder
                    width: 100,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.computer, size: 100, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                // Detalhes Principais
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        machine['nome'] ?? 'Nome Indisponível',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Patrimônio: ${machine['patrimonio'] ?? 'N/A'}'),
                      // A unidade virá do JSON de locais no futuro
                      const Text('Unidade: Coração Eucarístico'), 
                      Text('Prédio: ${machine['predio'] ?? 'N/A'}'),
                      Text('Lab/Sala: ${machine['sala'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              ],
            ),
            
            // --- SEÇÃO DE ESPECIFICAÇÕES ---
            _buildSectionTitle('Especificações'),
            _buildSpecRow(Icons.memory, 'CPU', machine['processador']),
            _buildSpecRow(Icons.storage, 'SSD/HD', machine['armazenamento']),
            _buildSpecRow(Icons.developer_board, 'RAM', machine['memoria']),

            // --- SEÇÃO DE SOLICITAÇÃO (se houver problema) ---
            if (problemDescription != null && problemDescription.isNotEmpty) ...[
              _buildSectionTitle('Solicitação'),
              Text(
                problemDescription,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],

            // --- SEÇÃO DO EMISSOR ---
            _buildSectionTitle('Emissor'),
            Text(
              'Master',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(formattedDate),

            const SizedBox(height: 16),
            
            // Botão para fechar o diálogo
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Fechar'),
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

