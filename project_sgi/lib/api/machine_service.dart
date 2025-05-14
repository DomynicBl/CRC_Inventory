import 'dart:convert';
import 'package:http/http.dart' as http;

class MachineService {
  // troque essa URL pela sua do Render, sem “/api” extra
  static const String baseUrl = 'https://crc-inventory.onrender.com/maquinas';

  Future<void> addMachine(Map<String, dynamic> data) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (resp.statusCode != 201) {
      throw Exception('Erro ao cadastrar: ${resp.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getLastMachines() async {
    final resp = await http.get(Uri.parse(baseUrl));
    if (resp.statusCode != 200) {
      throw Exception('Erro ao buscar máquinas: ${resp.body}');
    }
    final List<dynamic> list = jsonDecode(resp.body);
    return list.cast<Map<String, dynamic>>();
  }

  // Adicione este método à sua classe MachineService:
  Future<void> deleteMachine(String id) async {
    final resp = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode != 200) {
      throw Exception('Erro ao excluir: ${resp.body}');
    }
  }

  /// Atualiza a máquina com o ID passado
  Future<void> updateMachine(String id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/$id');
    final response = await http.put(
      uri,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar máquina: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getByPatrimonioParcial(
    String prefix,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl?patrimonio=$prefix'),
    );
    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }
}
