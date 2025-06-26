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
  final _formKey = GlobalKey<FormState>();
  final _service = MachineService();
  
  late Map<String, dynamic> _formData;
  
  Map<String, dynamic>? _locations;
  Map<String, dynamic>? _components;
  List<String> _availableRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _formData = Map.from(widget.machine);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final locData = await _service.getLocations();
      final compData = await _service.getComponents();
      setState(() {
        _locations = locData;
        _components = compData;
        // Valida os dados da máquina contra as listas carregadas
        _sanitizeFormData();
        _updateAvailableRooms(_formData['predio']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar opções: $e')));
    }
  }

  /// --- LÓGICA DE CORREÇÃO ---
  /// Verifica se os valores atuais do formulário existem nas listas de opções.
  /// Se não existirem, define-os como nulos para evitar o crash.
  void _sanitizeFormData() {
    if (_components != null) {
      _formData['monitor'] = _validateSelection(_formData['monitor'], _components!['monitors']);
      _formData['processador'] = _validateSelection(_formData['processador'], _components!['processors']);
      _formData['armazenamento'] = _validateSelection(_formData['armazenamento'], _components!['storage']);
      _formData['memoria'] = _validateSelection(_formData['memoria'], _components!['memory']);
    }
    if (_locations != null) {
      final buildingIds = (_locations!['buildings'] as List).map((b) => b['id'].toString()).toList();
      _formData['predio'] = _validateSelection(_formData['predio'], buildingIds);
    }
  }

  String? _validateSelection(String? currentValue, List<dynamic>? availableItems) {
    if (currentValue == null || availableItems == null) return null;
    // Se o valor atual não está na lista de opções válidas, retorna nulo.
    if (availableItems.any((item) => item.toString() == currentValue)) {
      return currentValue;
    }
    return null;
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
    _formData['sala'] = _validateSelection(_formData['sala'], _availableRooms);
    setState(() {});
  }
  
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _service.updateMachine(widget.machine['_id'], _formData);
        if (mounted) Navigator.of(context).pop(true);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao alterar: $e')));
      }
    }
  }

  Widget _buildDropdown(String label, String? value, List<dynamic>? items, void Function(String?)? onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
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
      appBar: AppBar(title: const Text('Alterar Máquina')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(initialValue: _formData['nome'], decoration: InputDecoration(labelText: 'Nome da máquina'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null, onSaved: (v) => _formData['nome'] = v),
              const SizedBox(height: 16),
              TextFormField(initialValue: _formData['patrimonio'], decoration: InputDecoration(labelText: 'Patrimônio', counterText: ""), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], maxLength: 11, validator: (v) { if (v!.isEmpty) return 'Campo obrigatório'; if (v.length != 11) return 'Patrimônio deve ter 11 dígitos'; return null; }, onSaved: (v) => _formData['patrimonio'] = v),
              const SizedBox(height: 16),
              _buildDropdown('Prédio', _formData['predio'], _locations?['buildings']?.map((b) => b['id']).toList(), (v) => setState(() => _updateAvailableRooms(v))),
              const SizedBox(height: 16),
              _buildDropdown('Sala', _formData['sala'], _availableRooms, (v) => setState(() => _formData['sala'] = v)),
              const SizedBox(height: 16),
              _buildDropdown('Monitor', _formData['monitor'], _components?['monitors'], (v) => setState(() => _formData['monitor'] = v)),
              const SizedBox(height: 16),
              _buildDropdown('Processador', _formData['processador'], _components?['processors'], (v) => setState(() => _formData['processador'] = v)),
              const SizedBox(height: 16),
              _buildDropdown('Armazenamento', _formData['armazenamento'], _components?['storage'], (v) => setState(() => _formData['armazenamento'] = v)),
              const SizedBox(height: 16),
              _buildDropdown('Memória', _formData['memoria'], _components?['memory'], (v) => setState(() => _formData['memoria'] = v)),
              const SizedBox(height: 16),
              TextFormField(initialValue: _formData['problema'], decoration: InputDecoration(labelText: 'Problema (se houver)'), onSaved: (v) => _formData['problema'] = v),
              const SizedBox(height: 16),
              TextFormField(initialValue: _formData['observacoes'], decoration: InputDecoration(labelText: 'Observações'), onSaved: (v) => _formData['observacoes'] = v),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submitForm, child: const Text('Alterar')),
            ],
          ),
        ),
      ),
    );
  }
}
