import 'dart:convert';
import 'package:http/http.dart' as http;

class MachineService {
  final String _baseUrl = 'https://crc-inventory-j85z.onrender.com';

  /// Verifica a senha mestra no backend.
  Future<bool> verifyMasterPassword(String password) async {
    final uri = Uri.parse('$_baseUrl/verify-master-password');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Erro ao verificar senha: $e');
      return false;
    }
  }
  
  /// --- MÉTODO MODIFICADO PARA CONTORNAR O CACHE ---
  /// Busca máquinas. Pode filtrar para trazer apenas as com chamados em aberto.
  ///
  /// [onlyWithIssues]: Se for true, busca na rota /maquinas/chamados.
  /// Se for false (padrão), busca as últimas máquinas atualizadas na rota /maquinas.
  Future<List<Map<String, dynamic>>> getLastMachines({bool onlyWithIssues = false}) async {
    // Define o endpoint com base no parâmetro
    final String endpoint = onlyWithIssues ? '/maquinas/chamados' : '/maquinas';
    final uri = Uri.parse('$_baseUrl$endpoint');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        // Mensagem de erro mais específica
        final errorMsg = onlyWithIssues ? 'Falha ao buscar os chamados.' : 'Falha ao buscar últimas máquinas.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // A função getMachineIssues() foi removida.

  /// Adiciona uma nova máquina.
  Future<void> addMachine(Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/maquinas');
    final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    if (response.statusCode != 201) throw Exception('Falha ao cadastrar a máquina.');
  }

  /// Busca máquinas por patrimônio parcial.
  Future<List<Map<String, dynamic>>> getByPatrimonioParcial(String patrimonio) async {
    final uri = Uri.parse('$_baseUrl/maquinas?patrimonio=$patrimonio');
    final response = await http.get(uri);
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    throw Exception('Falha ao buscar máquinas.');
  }

  /// Busca máquinas por prédio.
  Future<List<Map<String, dynamic>>> getMachinesByBuilding(String buildingName) async {
    final uri = Uri.parse('$_baseUrl/maquinas/por-predio?nome=$buildingName');
    final response = await http.get(uri);
    if (response.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    throw Exception('Falha ao carregar máquinas do prédio.');
  }

  /// Deleta uma máquina pelo ID.
  Future<void> deleteMachine(String id) async {
    final uri = Uri.parse('$_baseUrl/maquinas/$id');
    final response = await http.delete(uri);
    if (response.statusCode != 200) throw Exception('Falha ao excluir a máquina.');
  }

  /// Atualiza uma máquina.
  Future<Map<String, dynamic>> updateMachine(String id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/maquinas/$id');
    final response = await http.put(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Falha ao atualizar a máquina.');
  }

  /// Busca os locais (prédios e salas).
  Future<Map<String, dynamic>> getLocations() async {
    final uri = Uri.parse('$_baseUrl/locations');
    final response = await http.get(uri);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Falha ao carregar locais.');
  }

  /// Busca os componentes (processador, memória, etc.).
  Future<Map<String, dynamic>> getComponents() async {
    final uri = Uri.parse('$_baseUrl/components');
    final response = await http.get(uri);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Falha ao carregar componentes.');
  }
}
