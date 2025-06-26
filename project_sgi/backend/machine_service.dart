import 'dart:convert';
import 'package:http/http.dart' as http;

class MachineService {
  final String _baseUrl = 'https://crc-inventory-j85z.onrender.com';

  // --- FUNÇÃO DE LOGIN QUE ESTAVA FALTANDO ---
  /// Verifica a senha mestra no backend.
  Future<bool> verifyMasterPassword(String password) async {
    final uri = Uri.parse('$_baseUrl/verify-master-password');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password}),
      );
      // Se a resposta for 200 (OK), significa que a senha estava correta.
      // Se for 401 (Unauthorized), a senha estava incorreta.
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      // Qualquer outro status é tratado como falha.
      return false;
    } catch (e) {
      // Erro de conexão ou outro problema.
      print('Erro ao verificar senha: $e');
      return false;
    }
  }

  // --- TODOS OS OUTROS MÉTODOS QUE JÁ TINHAMOS ---

  Future<List<Map<String, dynamic>>> getLastMachines() async {
    final uri = Uri.parse('$_baseUrl/maquinas');
    final response = await http.get(uri);
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    throw Exception('Falha ao buscar últimas máquinas.');
  }
  
  Future<void> addMachine(Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/maquinas');
    final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    if (response.statusCode != 201) throw Exception('Falha ao cadastrar a máquina.');
  }

  Future<List<Map<String, dynamic>>> getByPatrimonioParcial(String patrimonio) async {
    final uri = Uri.parse('$_baseUrl/maquinas?patrimonio=$patrimonio');
    final response = await http.get(uri);
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    throw Exception('Falha ao buscar máquinas.');
  }

  Future<List<Map<String, dynamic>>> getMachinesByBuilding(String buildingName) async {
    final uri = Uri.parse('$_baseUrl/maquinas/por-predio?nome=$buildingName');
    final response = await http.get(uri);
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    throw Exception('Falha ao carregar máquinas do prédio.');
  }

  Future<void> deleteMachine(String id) async {
    final uri = Uri.parse('$_baseUrl/maquinas/$id');
    final response = await http.delete(uri);
    if (response.statusCode != 200) throw Exception('Falha ao excluir a máquina.');
  }

  Future<Map<String, dynamic>> updateMachine(String id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/maquinas/$id');
    final response = await http.put(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Falha ao atualizar a máquina.');
  }

  Future<Map<String, dynamic>> getLocations() async {
    final uri = Uri.parse('$_baseUrl/locations');
    final response = await http.get(uri);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Falha ao carregar locais.');
  }

  Future<Map<String, dynamic>> getComponents() async {
    final uri = Uri.parse('$_baseUrl/components');
    final response = await http.get(uri);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Falha ao carregar componentes.');
  }
}
