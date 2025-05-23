import 'package:flutter/material.dart';
import '../../api/machine_service.dart';
import '../Machines/edit_machine_form.dart';

class MachineCard extends StatefulWidget {
  final Map<String, dynamic> machine;
  final VoidCallback onUpdate;

  const MachineCard({
    super.key,
    required this.machine,
    required this.onUpdate,
  });

  @override
  State<MachineCard> createState() => _MachineCardState();
}

class _MachineCardState extends State<MachineCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.machine;
    final id = m['_id'];
    final dateStr = m['data'] ?? '';

    final backgroundColor = _isHovering
        ? const Color(0xFF002238)
        : const Color.fromARGB(255, 199, 232, 255);
    final textColor = _isHovering ? Colors.white : Colors.black;
    final iconColor = _isHovering ? Colors.white : const Color(0xFF002238);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () async {
            try {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditMachineForm(machine: m),
                ),
              );
              if (updated == true) {
                widget.onUpdate();
              }
            } catch (e, st) {
              debugPrint('Erro ao abrir edição: $e\n$st');
            }
          },
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Card(
            elevation: 0,
            shadowColor: Colors.transparent,
            color: backgroundColor,
            margin: const EdgeInsets.only(bottom: 3),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 1, 12, 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          m['nome'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: iconColor),
                        onPressed: () async {
                          try {
                            await MachineService().deleteMachine(id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Máquina excluída com sucesso!'),
                              ),
                            );
                            widget.onUpdate();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao excluir: $e')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Text(
                    'Patrimônio: ${m['patrimonio'] ?? ''}',
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      dateStr,
                      style: TextStyle(
                        color: _isHovering ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
