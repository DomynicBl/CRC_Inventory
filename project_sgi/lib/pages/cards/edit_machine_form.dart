import 'dart:convert';
import 'package:http/http.dart' as http;

class MachineService {
  final String _baseUrl = 'https://crc-inventory-j85z.onrender.com';

  /// Busca máquinas por patrimônio (busca parcial)
  Future<List<Map<String, dynamic>>> getByPatrimonioParcial(String patrimonio) async {
    final uri = Uri.parse('$_baseUrl/maquinas?patrimonio=$patrimonio');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Falha ao buscar máquinas.');
  }

  /// Busca todas as máquinas de um prédio específico
  Future<List<Map<String, dynamic>>> getMachinesByBuilding(String buildingName) async {
    final uri = Uri.parse('$_baseUrl/maquinas/por-predio?nome=$buildingName');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Falha ao carregar máquinas do prédio.');
  }

  /// Exclui uma máquina pelo seu ID
  Future<void> deleteMachine(String id) async {
    final uri = Uri.parse('$_baseUrl/maquinas/$id');
    final response = await http.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Falha ao excluir a máquina.');
    }
  }

  /// Atualiza os dados de uma máquina
  Future<Map<String, dynamic>> updateMachine(String id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/maquinas/$id');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Falha ao atualizar a máquina.');
  }

  /// Busca os dados de locais (prédios e salas)
  Future<Map<String, dynamic>> getLocations() async {
    final uri = Uri.parse('$_baseUrl/locations');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Falha ao carregar locais.');
  }

  /// Busca os componentes pré-definidos (CPU, RAM, etc.)
  Future<Map<String, dynamic>> getComponents() async {
    final uri = Uri.parse('$_baseUrl/components');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Falha ao carregar componentes.');
  }
}
