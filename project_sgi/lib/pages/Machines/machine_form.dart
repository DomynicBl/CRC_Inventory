import 'package:flutter/material.dart';
import 'package:project_sgi/api/machine_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

// Importe a página de scanner
import 'barcode_scanner_return_page.dart';

class MachineForm extends StatefulWidget {
  const MachineForm({super.key});

  @override
  _MachineFormState createState() => _MachineFormState();
}

class _MachineFormState extends State<MachineForm> {
  // --- VARIÁVEIS DO FORMULÁRIO ---
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

  // --- VARIÁVEIS PARA IMAGEM E SUPABASE ---
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _imageUrl;
  bool _isUploading = false;

  // --- FUNÇÃO PARA ESCANEAR BARCODE ---
  Future<void> _scanBarcode() async {
    try {
      final String? barcodeValue = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const BarcodeScannerReturnPage()),
      );
      if (barcodeValue != null && barcodeValue.isNotEmpty) {
        setState(() {
          patrimonioController.text = barcodeValue;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao escanear: ${e.toString()}')),
      );
    }
  }

  // --- FUNÇÃO PARA SELECIONAR IMAGEM ---
  Future<void> _pickImage() async {
     try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageUrl = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- FUNÇÃO PARA UPLOAD ---
  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma imagem primeiro.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() { _isUploading = true; });

    try {
      final fileExtension = p.extension(_imageFile!.path);
      final fileName = 'maquinas/${const Uuid().v4()}$fileExtension';

      await supabase.storage.from('fotos-maquinas').upload(
            fileName,
            _imageFile!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrlResponse = supabase.storage
          .from('fotos-maquinas')
          .getPublicUrl(fileName);

      setState(() {
        _imageUrl = imageUrlResponse;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto enviada com sucesso!'), backgroundColor: Colors.green),
      );

    } catch (e) {
      setState(() { _isUploading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no upload: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- FUNÇÃO _criarMaquinaComoMapa (ATUALIZADA) ---
   Map<String, dynamic> _criarMaquinaComoMapa() {
    return {
      'nome': nomeController.text,
      'patrimonio': patrimonioController.text,
      'predio': predioController.text,
      'sala': salaController.text, // <<< AGORA EXISTE
      'monitor': monitorController.text, // <<< AGORA EXISTE
      'modelo': modeloController.text, // <<< AGORA EXISTE
      'processador': processadorController.text, // <<< AGORA EXISTE
      'memoria': memoryValue ?? '',
      'problema': problemaController.text, // <<< AGORA EXISTE
      'observacoes': observacaoController.text, // <<< AGORA EXISTE
      'ultimaAtualizacao': DateTime.now().toIso8601String(),
      'fotoUrl': _imageUrl, // <<< ADICIONA A URL DA FOTO
    };
  }

  // --- buildTextField e buildDropdown ---
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
        // ... (resto do seu código buildDropdown) ...
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
            // --- CAMPOS DO FORMULÁRIO ---
            buildTextField('Nome da máquina', nomeController),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: buildTextField('Patrimônio', patrimonioController),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _scanBarcode, // Chama a função de escaneamento
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
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
            buildTextField('Sala', salaController), // <<< AGORA FUNCIONA
            buildTextField('Monitor', monitorController), // <<< AGORA FUNCIONA
            buildTextField('Modelo', modeloController), // <<< AGORA FUNCIONA
            buildTextField('Processador', processadorController), // <<< AGORA FUNCIONA
            const SizedBox(height: 12),
            buildDropdown(['4GB', '6GB', '8GB', '16GB', '32GB']),
            buildTextField('Problema (se houver)', problemaController), // <<< AGORA FUNCIONA
            buildTextField('Observações / Justificativa', observacaoController), // <<< AGORA FUNCIONA

            // --- SEÇÃO DE FOTO ---
            const SizedBox(height: 16),
            const Text("Foto da Máquina", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 200, height: 150,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                    child: _imageFile == null
                        ? const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey))
                        : Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Tirar/Escolher'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: (_imageFile == null || _isUploading) ? null : _uploadImage,
                        icon: _isUploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.cloud_upload),
                        label: Text(_isUploading ? 'Enviando...' : 'Enviar Foto'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                      ),
                    ],
                  ),
                   if (_imageUrl != null)
                      const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text("✅ Foto pronta para salvar!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),
                      )
                ],
              ),
            ),
            // --- FIM DA SEÇÃO DE FOTO ---

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: (_imageFile != null && _imageUrl == null) || _isUploading ? null : () async {
                   if (_imageFile != null && _imageUrl == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Por favor, clique em "Enviar Foto" antes de cadastrar.'), backgroundColor: Colors.orange,),
                      );
                      return;
                  }
                  final dados = _criarMaquinaComoMapa();
                   try {
                     await MachineService().addMachine(dados);
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(
                         content: Text('Máquina cadastrada com sucesso!'),
                         backgroundColor: Colors.green,
                       ),
                     );
                     Navigator.pop(context, true);
                  } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text('Erro ao cadastrar: ${e.toString()}'),
                         backgroundColor: Colors.red,
                       ),
                     );
                  }
                },
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text('Enviar Cadastro'),
                style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF002238), // Cor do seu botão original
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
}