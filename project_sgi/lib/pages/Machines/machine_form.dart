import 'package:project_sgi/api/machine_service.dart';
import 'package:flutter/material.dart';
// Importe a nova página de scanner
import 'barcode_scanner_return_page.dart'; // <<< VERIFIQUE ESTE CAMINHO

class MachineForm extends StatefulWidget {
  const MachineForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MachineFormState createState() => _MachineFormState();
}

class _MachineFormState extends State<MachineForm> {
  String? memoryValue;
  String ticket = 'Não Validado';

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController patrimonioController = TextEditingController();
  final TextEditingController predioController = TextEditingController();
  final TextEditingController salaController = TextEditingController();
  final TextEditingController monitorController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController processadorController = TextEditingController();
  final TextEditingController problemaController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();

  // --- NOVA FUNÇÃO PARA ESCANEAR ---
  Future<void> _scanBarcode() async {
    try {
      // Navega para a página do scanner e espera o resultado
      final String? barcodeValue = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const BarcodeScannerReturnPage()),
      );

      // Se um valor foi retornado (ou seja, o usuário não apenas voltou),
      // atualiza o campo de patrimônio.
      if (barcodeValue != null && barcodeValue.isNotEmpty) {
        setState(() {
          patrimonioController.text = barcodeValue;
        });
      }
    } catch (e) {
      // Mostra um erro se algo der errado (ex: permissão da câmera negada)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao escanear: ${e.toString()}')),
      );
    }
  }
  // --- FIM DA NOVA FUNÇÃO ---

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
                  // --- ATUALIZA O onPressed ---
                  onPressed: _scanBarcode, // Chama a função de escaneamento
                  // --- FIM DA ATUALIZAÇÃO ---
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15), // Ajuste de padding
                    shape: RoundedRectangleBorder( // Borda arredondada
                        borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row( // Adiciona ícone
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Icon(Icons.qr_code_scanner, color: Colors.white),
                       SizedBox(width: 8),
                       Text(
                        'Escanear',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )
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
              child: ElevatedButton.icon( // Adiciona ícone
                onPressed: () {
                  print('Registrar foto...');
                  // Aqui você implementaria a lógica da câmera
                },
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text(
                  'Registrar Foto',
                  style: TextStyle(color: Colors.white),
                ),
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
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon( // Adiciona ícone
                onPressed: () async {
                  final dados = _criarMaquinaComoMapa();
                  try {
                     await MachineService().addMachine(dados);
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(
                         content: Text('Máquina cadastrada com sucesso!'),
                         backgroundColor: Color(0xFF002238), // Feedback visual
                       ),
                     );
                     Navigator.pop(context, true); // Retorna true para indicar sucesso
                  } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text('Erro ao cadastrar: ${e.toString()}'),
                         backgroundColor: Colors.red, // Feedback visual
                       ),
                     );
                  }
                },
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text('Enviar Cadastro'),
                style: ElevatedButton.styleFrom(
                   backgroundColor: Color(0xFF002238), 
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
                   textStyle: const TextStyle(fontSize: 16),
                ),
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
        items: items.map((item) {
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
      'ultimaAtualizacao': DateTime.now().toIso8601String(),
    };
  }
}