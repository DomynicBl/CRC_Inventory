import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../machines/edit_machine_form.dart';

class MachineCard extends StatelessWidget {
  final Map<String, dynamic> machine;
  final VoidCallback onUpdate;

  const MachineCard({Key? key, required this.machine, required this.onUpdate}) : super(key: key);

  // Widgets auxiliares para manter o código limpo
  Widget _buildSpecRow(IconData i, String l, String? v) => (v == null || v.isEmpty) ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Row(children: [Icon(i, color: Colors.blueGrey, size: 20), const SizedBox(width: 8), Text('$l: ', style: const TextStyle(fontWeight: FontWeight.bold)), Expanded(child: Text(v))]));
  Widget _buildSectionTitle(String t) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const Divider()]));

  @override
  Widget build(BuildContext context) {
    // Formata a data para o padrão brasileiro
    String date = machine['dataCadastro'] != null ? DateFormat("dd/MM/yyyy - HH:mm'h'").format(DateTime.parse(machine['dataCadastro'])) : 'N/A';
    
    // --- LÓGICA Lab/Sala ---
    final salaValue = machine['sala'] ?? 'N/A';
    final isLab = salaValue.toUpperCase().contains('LAB');
    final locationLabel = isLab ? 'Lab' : 'Sala';

    return SingleChildScrollView(
      child: Stack(
        // Usamos Stack para posicionar os botões de ação no topo
        children: [
          // Conteúdo Principal
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8.0), child: Image.network('https://placehold.co/100x120/e2e8f0/334155?text=PC', width: 100, height: 120, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.computer, size: 100, color: Colors.grey))),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(machine['nome'] ?? 'N/A', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    // --- LINHA MAIS GROSSA ---
                    const Divider(thickness: 2.5, color: Colors.black26),
                    const SizedBox(height: 4),
                    // --- FONTE MENOR ---
                    DefaultTextStyle(
                      style: const TextStyle(fontSize: 12, color: Colors.black87), // Tamanho de fonte ajustado
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patrimônio: ${machine['patrimonio'] ?? 'N/A'}'),
                          const Text('Unidade: Coração Eucarístico'),
                          Text('Prédio: ${machine['predio'] ?? 'N/A'}'),
                          Text('$locationLabel: $salaValue'),
                        ],
                      ),
                    ),
                  ])),
                ]),
                
                _buildSectionTitle('Especificações'),
                _buildSpecRow(Icons.memory, 'CPU', machine['processador']),
                _buildSpecRow(Icons.storage_outlined, 'Armazenamento', machine['armazenamento']),
                _buildSpecRow(Icons.developer_board, 'RAM', machine['memoria']),

                if (machine['problema']?.isNotEmpty ?? false) ...[
                  _buildSectionTitle('Solicitação'),
                  Text(machine['problema'], style: const TextStyle(fontStyle: FontStyle.italic)),
                ],

                _buildSectionTitle('Emissor'),
                const Text('Master', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(date),
              ],
            ),
          ),
          
          // Botões de Ação
          Positioned(top: 8, right: 8, child: Row(children: [
            Material(color: Colors.grey[200], shape: const CircleBorder(), child: IconButton(icon: const Icon(Icons.edit, color: Colors.blueGrey), tooltip: 'Editar Máquina', onPressed: () async { if (await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => EditMachineForm(machine: machine))) == true) { onUpdate(); }})),
            const SizedBox(width: 8),
            Material(color: const Color(0xFFe33535), shape: const CircleBorder(), child: IconButton(icon: const Icon(Icons.close, color: Colors.white), tooltip: 'Fechar', onPressed: () => Navigator.of(context).pop())),
          ])),
        ],
      ),
    );
  }
}
