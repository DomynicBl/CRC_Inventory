import 'dart:convert';
import 'package:http/http.dart' as http;

class MachineService {
  // --- URL CORRETA ---
  // A URL do seu backend no Render já está configurada aqui.
  final String _baseUrl = 'https://crc-inventory-j85z.onrender.com';

  /// Busca máquinas cujo patrimônio comece com o valor fornecido.
  Future<List<Map<String, dynamic>>> getByPatrimonioParcial(String patrimonio) async {
    final uri = Uri.parse('$_baseUrl/maquinas?patrimonio=$patrimonio');
    
    try {
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data.cast<Map<String, dynamic>>().toList();
        } else {
          print('Erro na API (getByPatrimonioParcial): ${response.statusCode}');
          print('Corpo da resposta: ${response.body}');
          throw Exception('Falha ao buscar máquinas por patrimônio.');
        }

    } catch (e) {
        print('Erro em getByPatrimonioParcial: $e');
        throw Exception('Não foi possível conectar ao servidor.');
    }
  }

  /// Busca todas as máquinas de um determinado prédio.
  /// Esta é a função que o popup do mapa usa.
  Future<List<Map<String, dynamic>>> getMachinesByBuilding(String buildingName) async {
    final uri = Uri.parse('$_baseUrl/maquinas/por-predio?nome=$buildingName');
    
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>().toList();
      } else {
        // Log para depuração em caso de erro
        print('Erro na API (getMachinesByBuilding): ${response.statusCode}');
        print('Corpo da resposta: ${response.body}');
        throw Exception('Falha ao carregar máquinas do prédio.');
      }
    } catch (e) {
      // Captura erros de rede ou outros problemas
      print('Erro em getMachinesByBuilding: $e');
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }
}
