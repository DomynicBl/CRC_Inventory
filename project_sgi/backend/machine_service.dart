import 'dart:convert';
import 'package:http/http.dart' as http;

class MachineService {
  final String _baseUrl = 'https://crc-inventory-j85z.onrender.com';

  Future<List<Map<String, dynamic>>> getByPatrimonioParcial(String patrimonio) async {
    final uri = Uri.parse('$_baseUrl/maquinas?patrimonio=$patrimonio');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao buscar máquinas por patrimônio.');
    }
  }

  Future<List<Map<String, dynamic>>> getMachinesByBuilding(String buildingName) async {
    final uri = Uri.parse('$_baseUrl/maquinas/por-predio?nome=$buildingName');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar máquinas do prédio.');
    }
  }

  // --- FUNÇÃO ADICIONADA ---
  Future<void> deleteMachine(String id) async {
    final uri = Uri.parse('$_baseUrl/maquinas/$id');
    final response = await http.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Falha ao excluir a máquina.');
    }
  }

  // --- FUNÇÃO ADICIONADA (PARA FORMULÁRIO DE EDIÇÃO) ---
  Future<Map<String, dynamic>> updateMachine(String id, Map<String, dynamic> machineData) async {
    final uri = Uri.parse('$_baseUrl/maquinas/$id');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(machineData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao atualizar a máquina.');
    }
  }

  // --- FUNÇÃO PARA O FUTURO (VALIDAÇÃO DE LOCAIS) ---
  Future<Map<String, dynamic>> getLocations() async {
    final uri = Uri.parse('$_baseUrl/locations');
     final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar locais.');
    }
  }
}
