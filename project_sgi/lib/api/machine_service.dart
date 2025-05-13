import 'dart:convert';
import 'package:http/http.dart' as http;

class MachineService {
  // troque essa URL pela sua do Render, sem “/api” extra
  static const String baseUrl = 'https://crc-inventory.onrender.com';

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
}
