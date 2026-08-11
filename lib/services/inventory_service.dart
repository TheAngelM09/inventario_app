import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory_item.dart';

class InventoryService {
  static const String baseUrl = 'http://192.168.3.232/InvBar/api';

  Future<int> login(String ciResponsible) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: ({
          'ci_responsible': ciResponsible,
        }),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {

        if (responseData['success'] == true || responseData['status'] == 'success') {
          final responsibleData = responseData['data'];
          return responsibleData['id'];
        } else {
          String message = responseData['message'] ?? responseData['msg'] ?? "Responsable no Encontrado";
          throw Exception(message);
        }
      } else {
        throw Exception(responseData['message']);
      }
    } on http.ClientException {
      throw Exception("Error de conexión con el servidor.");
    } catch (e) {
      rethrow;
    }
  }

  Future<List<InventoryItem>> fetchAll(String idResponsible) async {
    final response = await http.get(Uri.parse('$baseUrl/getAll?id_responsible=$idResponsible')).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((data) => InventoryItem.fromJson(data)).toList();
      } catch (e) {
        throw Exception('El servidor envió un formato inválido (HTML/Error PHP).');
      }
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateRecord({
    required int id,
    required int diff,
    required String reason,
    String? status,
  }) async {
    final Map<String, dynamic> body = {
      'id': id,
      'unit_diff': diff,
      'reason': reason,
    };
    if (status != null) {
      body['status'] = status;
    }

    final response = await http.post(Uri.parse('$baseUrl/verify'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    ).timeout(const Duration(seconds: 5));

    try {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['mensaje'] ?? 'Error de servidor al actualizar');
      }
    } catch (e) {
      throw Exception('El servidor respondió con un error técnico (HTML).');
    }
  }
}
