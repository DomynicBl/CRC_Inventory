import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_sgi/api/machine_service.dart';
import 'barcode_scanner_return_page.dart';

class MachineForm extends StatefulWidget {
  const MachineForm({super.key});

  @override
  _MachineFormState createState() => _MachineFormState();
}

class _MachineFormState extends State<MachineForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = MachineService();
  
  // Controllers para campos de texto
  final nomeController = TextEditingController();
  final patrimonioController = TextEditingController();
  final modeloController = TextEditingController();
  final problemaController = TextEditingController();
  final observacaoController = TextEditingController();

  // Variáveis para os dropdowns
  String? _selectedPredio, _selectedSala, _selectedMonitor, _selectedProcessador, _selectedMemoria, _selectedArmazenamento;
  
  Map<String, dynamic>? _locations, _components;
  List<String> _availableRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  @override
  void dispose() {
    // Limpeza dos controllers para evitar vazamento de memória
    nomeController.dispose();
    patrimonioController.dispose();
    modeloController.dispose();
    problemaController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final locData = await _service.getLocations();
      final compData = await _service.getComponents();
      setState(() {
        _locations = locData;
        _components = compData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar opções: $e')));
    }
  }

  void _updateAvailableRooms(String? buildingName) {
    if (buildingName == null || _locations == null) {
      _availableRooms = []; return;
    }
    final building = (_locations!['buildings'] as List).firstWhere((b) => b['name'] == buildingName, orElse: () => null);
    if (building != null) {
      _selectedPredio = building['id'];
      _availableRooms = List<String>.from(building['rooms']);
    } else {
      _availableRooms = [];
    }
    _selectedSala = null; // Reseta a sala ao mudar de prédio
  }
  
  Future<void> _scanBarcode() async {
    try {
      final String? barcodeValue = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const BarcodeScannerReturnPage()));
      if (barcodeValue != null && barcodeValue.isNotEmpty) {
        setState(() => patrimonioController.text = barcodeValue);
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao escanear: $e')));
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final dados = {
        'nome': nomeController.text,
        'patrimonio': patrimonioController.text,
        'modelo': modeloController.text,
        'problema': problemaController.text,
        'observacoes': observacaoController.text,
        'predio': _selectedPredio,
        'sala': _selectedSala,
        'monitor': _selectedMonitor,
        'processador': _selectedProcessador,
        'memoria': _selectedMemoria,
        'armazenamento': _selectedArmazenamento,
      };

      try {
        await _service.addMachine(dados);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Máquina cadastrada com sucesso!')));
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cadastrar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Máquina')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome da máquina'), validator: (v) => (v!.isEmpty) ? 'Campo obrigatório' : null),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextFormField(controller: patrimonioController, decoration: const InputDecoration(labelText: 'Patrimônio', counterText: ""), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], maxLength: 11, validator: (v) { if (v!.isEmpty) return 'Campo obrigatório'; if (v.length != 11) return 'Patrimônio deve ter 11 dígitos'; return null; })),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _scanBarcode, child: const Icon(Icons.qr_code_scanner)),
              ]),
              const SizedBox(height: 12),
              TextFormField(controller: modeloController, decoration: const InputDecoration(labelText: 'Modelo'), validator: (v) => (v!.isEmpty) ? 'Campo obrigatório' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: _locations?['buildings']?.firstWhere((b) => b['id'] == _selectedPredio, orElse: () => null)?['name'], decoration: const InputDecoration(labelText: 'Prédio'), items: _locations?['buildings']?.map<DropdownMenuItem<String>>((b) => DropdownMenuItem(value: b['name'], child: Text(b['name']))).toList(), onChanged: (v) => setState(() => _updateAvailableRooms(v)), validator: (v) => v == null ? 'Campo obrigatório' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: _selectedSala, decoration: const InputDecoration(labelText: 'Sala'), items: _availableRooms.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(), onChanged: (v) => setState(() => _selectedSala = v), validator: (v) => v == null ? 'Campo obrigatório' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: _selectedMonitor, decoration: const InputDecoration(labelText: 'Monitor'), items: _components?['monitors']?.map<DropdownMenuItem<String>>((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => setState(() => _selectedMonitor = v), validator: (v) => v == null ? 'Campo obrigatório' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: _selectedProcessador, decoration: const InputDecoration(labelText: 'Processador'), items: _components?['processors']?.map<DropdownMenuItem<String>>((p) => DropdownMenuItem(value: p, child: Text(p))).toList(), onChanged: (v) => setState(() => _selectedProcessador = v), validator: (v) => v == null ? 'Campo obrigatório' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: _selectedArmazenamento, decoration: const InputDecoration(labelText: 'Armazenamento'), items: _components?['storage']?.map<DropdownMenuItem<String>>((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _selectedArmazenamento = v), validator: (v) => v == null ? 'Campo obrigatório' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(value: _selectedMemoria, decoration: const InputDecoration(labelText: 'Memória'), items: _components?['memory']?.map<DropdownMenuItem<String>>((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => setState(() => _selectedMemoria = v), validator: (v) => v == null ? 'Campo obrigatório' : null),
              const SizedBox(height: 12),
              TextFormField(controller: problemaController, decoration: const InputDecoration(labelText: 'Problema (se houver)')),
              const SizedBox(height: 12),
              TextFormField(controller: observacaoController, decoration: const InputDecoration(labelText: 'Observações / Justificativa')),
              const SizedBox(height: 24),
              ElevatedButton.icon(onPressed: _submitForm, icon: const Icon(Icons.send), label: const Text('Enviar Cadastro')),
            ],
          ),
        ),
      ),
    );
  }
}
