import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_stressless/api_client.dart';
import 'package:app_stressless/constants.dart';


class LiderNotifApi {
  static Future<List<Map<String, dynamic>>> listar(int idLider) async {
    final res = await ApiClient.get('/lider/$idLider/notificaciones');
    if (res.statusCode != 200) {
      throw Exception('GET notifs → ${res.statusCode}: ${res.body}');
    }
    return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> marcarLeida(int notifId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/notificacion/$notifId/leido'); // 👈 usa legacy
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (ApiClient.authToken != null) {
      headers['Authorization'] = 'Bearer ${ApiClient.authToken}';
    }

    final res = await http.put(uri, headers: headers); // 👈 sin body
    if (res.statusCode != 200) {
      throw Exception('PUT marcarLeida($notifId) → ${res.statusCode}: ${res.body}');
    }
  }
}
