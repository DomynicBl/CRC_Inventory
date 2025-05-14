import 'package:flutter/material.dart';
import 'package:project_sgi/api/machine_service.dart';

class EditMachineForm extends StatefulWidget {
  final Map<String, dynamic> machine;
  const EditMachineForm({super.key, required this.machine});

  @override
  _EditMachineFormState createState() => _EditMachineFormState();
}

class _EditMachineFormState extends State<EditMachineForm> {
  late TextEditingController nomeController;
  late TextEditingController patrimonioController;
  late TextEditingController predioController;
  late TextEditingController salaController;
  late TextEditingController monitorController;
  late TextEditingController modeloController;
  late TextEditingController processadorController;
  String? memoryValue;
  late TextEditingController problemaController;
  late TextEditingController observacaoController;

  @override
  void initState() {
    super.initState();
    final m = widget.machine;
    nomeController = TextEditingController(text: m['nome']);
    patrimonioController = TextEditingController(text: m['patrimonio']);
    predioController = TextEditingController(text: m['predio']);
    salaController = TextEditingController(text: m['sala']);
    monitorController = TextEditingController(text: m['monitor']);
    modeloController = TextEditingController(text: m['modelo']);
    processadorController = TextEditingController(text: m['processador']);
    memoryValue = m['memoria'];
    problemaController = TextEditingController(text: m['problema']);
    observacaoController = TextEditingController(text: m['observacoes']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar Máquina'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            buildTextField('Nome da máquina', nomeController),
            buildTextField('Patrimônio', patrimonioController),
            buildTextField('Prédio', predioController),
            buildTextField('Sala', salaController),
            buildTextField('Monitor', monitorController),
            buildTextField('Modelo', modeloController),
            buildTextField('Processador', processadorController),
            buildDropdown(['4GB', '6GB', '8GB', '16GB', '32GB']),
            buildTextField('Problema (se houver)', problemaController),
            buildTextField('Observações / Justificativa', observacaoController),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'nome': nomeController.text,
                  'patrimonio': patrimonioController.text,
                  'predio': predioController.text,
                  'sala': salaController.text,
                  'monitor': monitorController.text,
                  'modelo': modeloController.text,
                  'processador': processadorController.text,
                  'memoria': memoryValue ?? '',
                  'problema': problemaController.text,
                  'observacoes': observacaoController.text,
                  'ultimaAtualizacao': DateTime.now().toIso8601String(),
                };

                try {
                  await MachineService().updateMachine(
                    widget.machine['_id'],
                    data,
                  );

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Máquina alterada com sucesso!'),
                    ),
                  );
                  Navigator.pop(context, true);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao alterar: $e')),
                  );
                }
              },

              child: const Text('Alterar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController ctl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctl,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget buildDropdown(List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: memoryValue,
        items:
            items
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
        onChanged: (v) => setState(() => memoryValue = v),
        decoration: InputDecoration(
          labelText: 'Selecione a memória',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
