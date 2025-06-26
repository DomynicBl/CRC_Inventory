import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_sgi/api/machine_service.dart';

class EditMachineForm extends StatefulWidget {
  final Map<String, dynamic> machine;
  const EditMachineForm({super.key, required this.machine});

  @override
  _EditMachineFormState createState() => _EditMachineFormState();
}

class _EditMachineFormState extends State<EditMachineForm> {
  // Chave para controlar e validar o formulário
  final _formKey = GlobalKey<FormState>();
  final _service = MachineService();
  
  // Mantemos os controllers para os campos de texto livre
  late TextEditingController nomeController;
  late TextEditingController patrimonioController;
  late TextEditingController modeloController;
  late TextEditingController problemaController;
  late TextEditingController observacaoController;

  // Variáveis para guardar os valores selecionados nos dropdowns
  String? _selectedPredio;
  String? _selectedSala;
  String? _selectedMonitor;
  String? _selectedProcessador;
  String? _selectedMemoria;
  String? _selectedArmazenamento;

  // Variáveis para guardar os dados da API para os dropdowns
  Map<String, dynamic>? _locations;
  Map<String, dynamic>? _components;
  List<String> _availableRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final m = widget.machine;

    // Inicializa os controllers
    nomeController = TextEditingController(text: m['nome']);
    patrimonioController = TextEditingController(text: m['patrimonio']);
    modeloController = TextEditingController(text: m['modelo']);
    problemaController = TextEditingController(text: m['problema']);
    observacaoController = TextEditingController(text: m['observacoes']);

    // Inicializa as variáveis dos dropdowns com os valores da máquina
    _selectedPredio = m['predio'];
    _selectedSala = m['sala'];
    _selectedMonitor = m['monitor'];
    _selectedProcessador = m['processador'];
    _selectedMemoria = m['memoria'];
    _selectedArmazenamento = m['armazenamento'];

    // Busca os dados da API para preencher os dropdowns
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final locData = await _service.getLocations();
      final compData = await _service.getComponents();
      setState(() {
        _locations = locData;
        _components = compData;
        _updateAvailableRooms(_selectedPredio);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar opções: $e')));
    }
  }

  void _updateAvailableRooms(String? buildingId) {
    if (buildingId == null || _locations == null) {
      _availableRooms = []; return;
    }
    final building = (_locations!['buildings'] as List).firstWhere((b) => b['id'] == buildingId, orElse: () => null);
    if (building != null) {
      _availableRooms = List<String>.from(building['rooms']);
    } else {
      _availableRooms = [];
    }
    if (!_availableRooms.contains(_selectedSala)) {
      _selectedSala = null;
    }
  }

  void _submitForm() async {
    // Aciona a validação de todos os campos
    if (_formKey.currentState!.validate()) {
      final data = {
        'nome': nomeController.text,
        'patrimonio': patrimonioController.text,
        'modelo': modeloController.text,
        'problema': problemaController.text,
        'observacoes': observacaoController.text,
        // Adiciona os valores dos dropdowns
        'predio': _selectedPredio,
        'sala': _selectedSala,
        'monitor': _selectedMonitor,
        'processador': _selectedProcessador,
        'memoria': _selectedMemoria,
        'armazenamento': _selectedArmazenamento,
        'ultimaAtualizacao': DateTime.now().toIso8601String(),
      };

      try {
        await _service.updateMachine(widget.machine['_id'], data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Máquina alterada com sucesso!')));
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao alterar: $e')));
      }
    }
  }
  
  // Helper para criar os campos de texto
  Widget buildTextField(String label, TextEditingController ctl, {TextInputType? keyboardType, List<TextInputFormatter>? formatters, int? maxLength, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField( // Trocado para TextFormField para ter validação
        controller: ctl,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), counterText: ""),
        keyboardType: keyboardType,
        inputFormatters: formatters,
        maxLength: maxLength,
        validator: validator,
      ),
    );
  }

  // Helper para criar os Dropdowns
  Widget buildDropdown(String label, String? selectedValue, List<dynamic>? items, void Function(String?)? onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: items?.map((v) => DropdownMenuItem(value: v.toString(), child: Text(v.toString()))).toList() ?? [],
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar Máquina'), backgroundColor: Colors.white, foregroundColor: Colors.black87),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form( // Adicionado o widget Form
          key: _formKey,
          child: Column(
            children: [
              buildTextField('Nome da máquina', nomeController, validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null),
              buildTextField('Patrimônio', patrimonioController,
                keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 11,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obrigatório';
                  if (v.length != 11) return 'Patrimônio deve ter 11 dígitos';
                  return null;
                },
              ),
              buildTextField('Modelo', modeloController, validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null),

              // Dropdown para Prédio
              buildDropdown('Prédio', _selectedPredio, _locations?['buildings']?.map((b) => b['name']).toList(), (v) {
                setState(() {
                  final building = (_locations!['buildings'] as List).firstWhere((b) => b['name'] == v);
                  _selectedPredio = building['id'];
                  _updateAvailableRooms(_selectedPredio);
                });
              }),

              // Dropdown para Sala
              buildDropdown('Sala', _selectedSala, _availableRooms, (v) => setState(() => _selectedSala = v)),

              // Dropdown para Componentes
              buildDropdown('Monitor', _selectedMonitor, _components?['monitors'], (v) => setState(() => _selectedMonitor = v)),
              buildDropdown('Processador', _selectedProcessador, _components?['processors'], (v) => setState(() => _selectedProcessador = v)),
              buildDropdown('Armazenamento', _selectedArmazenamento, _components?['storage'], (v) => setState(() => _selectedArmazenamento = v)),
              buildDropdown('Memória', _selectedMemoria, _components?['memory'], (v) => setState(() => _selectedMemoria = v)),

              // Campos não obrigatórios
              buildTextField('Problema (se houver)', problemaController),
              buildTextField('Observações / Justificativa', observacaoController),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Alterar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
