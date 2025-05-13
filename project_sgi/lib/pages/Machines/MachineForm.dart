import 'package:project_sgi/api/machine_service.dart';

import 'package:flutter/material.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class MachineForm extends StatefulWidget {
  const MachineForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MachineFormState createState() => _MachineFormState();
}

class _MachineFormState extends State<MachineForm> {
  String? memoryValue;
  String ticket = 'Não Validado'; // Define the ticket variable

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController patrimonioController = TextEditingController();
  final TextEditingController predioController = TextEditingController();
  final TextEditingController salaController = TextEditingController();
  final TextEditingController monitorController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController processadorController = TextEditingController();
  final TextEditingController problemaController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Cadastro de Máquina'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField('Nome da máquina', nomeController),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: buildTextField('Patrimônio', patrimonioController),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    debugPrint('Escanear patrimônio...');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                  ),
                  child: const Text(
                    'Escanear',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            buildTextField('Prédio', predioController),
            buildTextField('Sala', salaController),
            buildTextField('Monitor', monitorController),
            buildTextField('Modelo', modeloController),
            buildTextField('Processador', processadorController),

            const SizedBox(height: 12),
            buildDropdown(['4GB', '6GB', '8GB', '16GB', '32GB']),

            buildTextField('Problema (se houver)', problemaController),
            buildTextField('Observações / Justificativa', observacaoController),

            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  print('Registrar foto...');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Registrar Foto',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Center(
              // BOTAO DE ENVIO
              child: ElevatedButton(
                onPressed: () async {
                  final dados = _criarMaquinaComoMapa();

                  await MachineService().addMachine(dados);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Máquina cadastrada com sucesso!'),
                    ),
                  );

                  // ⬅️ Volta para a HomePage
                  Navigator.pop(context);
                },

                child: Text('Enviar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
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
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: 'Selecione a memória',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        iconEnabledColor: Colors.black,
        items:
            items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            memoryValue = value;
          });
        },
      ),
    );
  }

  Map<String, dynamic> _criarMaquinaComoMapa() {
    return {
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
      'dataCadastro': DateTime.now().toIso8601String(),
    };
  }
}
