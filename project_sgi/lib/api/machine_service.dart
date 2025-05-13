import 'dart:convert';
import 'package:http/http.dart' as http;

class MachineService {
  static const String baseUrl = 'http://192.168.0.105:3000/api/machines';

  Future<void> addMachine(Map<String, dynamic> machineData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(machineData),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao adicionar máquina: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getLastMachines({int limit = 10}) async {
    final response = await http.get(Uri.parse('$baseUrl?limit=$limit'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar máquinas: ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }
}
