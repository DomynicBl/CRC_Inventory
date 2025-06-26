import 'package:flutter/material.dart';

/// Um card que exibe um resumo das informações de uma máquina.
///
/// Ideal para listas e feeds, mostrando os dados mais importantes de forma compacta.
/// Ao ser tocado, executa a função [onTap].
class SummaryMachineCard extends StatelessWidget {
  final Map<String, dynamic> machine;
  final VoidCallback onTap;

  const SummaryMachineCard({
    Key? key,
    required this.machine,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Lógica para determinar se é "Lab" ou "Sala"
    final salaValue = machine['sala'] ?? 'N/A';
    final isLab = salaValue.toUpperCase().contains('LAB');
    final locationLabel = isLab ? 'Lab' : 'Sala';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Coluna da Imagem
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  'https://placehold.co/80x100/e2e8f0/334155?text=PC',
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.computer, size: 80, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),

              // Conteúdo principal expandido
              Expanded(
                child: SizedBox(
                  height: 100, // Garante que a altura seja consistente
                  child: Row(
                    children: [
                      // Coluna de Informações da Máquina
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              machine['nome'] ?? 'Sem nome',
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Divider(),
                            Text('Patrimônio: ${machine['patrimonio'] ?? 'N/A'}', style: textTheme.bodySmall),
                            Text('Prédio: ${machine['predio'] ?? 'N/A'}', style: textTheme.bodySmall),
                            Text('$locationLabel: $salaValue', style: textTheme.bodySmall),
                          ],
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: VerticalDivider(thickness: 1),
                      ),

                      // Coluna de Solicitação
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Solicitação',
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Divider(),
                            Expanded(
                              child: Text(
                                machine['problema'] != null && machine['problema'].isNotEmpty
                                    ? machine['problema']
                                    : 'Nenhum problema reportado.',
                                style: textTheme.bodySmall,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
