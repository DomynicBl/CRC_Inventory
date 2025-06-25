import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
    static const String _baseUrl = "https://crc-inventory.onrender.com";

  Future<bool> verifyMasterPassword(String password) async {
    try {
      final response = await http.post(
        // Aponta para a nova rota que criamos no backend
        Uri.parse('$_baseUrl/verify-master-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print("Erro ao verificar senha: $e");
      return false;
    }
  }
}