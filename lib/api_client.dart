// lib/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_stressless/constants.dart';

class ApiClient {
  /// Activa logs de requests/responses
  static bool debug = true;

  /// Guarda el token aquí (opcional si lo guardas en ApiConfig)
  static String? authToken;

  static String get _base => ApiConfig.baseUrl;

  static Map<String, String> _headers({Map<String, String>? extra}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    final t = authToken ?? ApiConfig.authToken;
    if (t != null && t.trim().isNotEmpty) {
      h['Authorization'] = 'Bearer $t';
    }
    if (extra != null) h.addAll(extra);
    return h;
  }

  static void _logReq(String method, Uri url, Map<String, String> headers, [Object? body]) {
    if (!debug) return;
    final token = headers['Authorization'];
    final masked = token == null ? 'null' : '${token.substring(0, token.length.clamp(0, 20))}... (len=${token.length})';
    print('🛰️ [API $method] $url');
    print('🧾 headers: ${Map.from(headers)..update("Authorization", (_) => masked, ifAbsent: () => masked)}');
    if (body != null) print('📦 body: $body');
  }

  static void _logRes(http.Response res) {
    if (!debug) return;
    print('✅ [API RES] ${res.request?.method} ${res.request?.url} -> ${res.statusCode}');
    print('🔎 body: ${res.body}');
  }

  static Future<http.Response> get(String path, {Map<String, String>? extraHeaders}) async {
    final uri = Uri.parse('$_base$path');
    final headers = _headers(extra: extraHeaders);
    _logReq('GET', uri, headers);
    final res = await http.get(uri, headers: headers);
    _logRes(res);
    return res;
  }

  static Future<http.Response> post(String path, Object body, {Map<String, String>? extraHeaders}) async {
    final uri = Uri.parse('$_base$path');
    final headers = _headers(extra: extraHeaders);
    final b = jsonEncode(body);
    _logReq('POST', uri, headers, b);
    final res = await http.post(uri, headers: headers, body: b);
    _logRes(res);
    return res;
  }

  static Future<http.Response> patch(String path, [Object? body, Map<String, String>? extraHeaders]) async {
    final uri = Uri.parse('$_base$path');
    final headers = _headers(extra: extraHeaders);
    final b = body == null ? null : jsonEncode(body);
    _logReq('PATCH', uri, headers, b);
    final res = await http.patch(uri, headers: headers, body: b);
    _logRes(res);
    return res;
  }

  static Future<http.Response> delete(String path, {Map<String, String>? extraHeaders}) async {
    final uri = Uri.parse('$_base$path');
    final headers = _headers(extra: extraHeaders);
    _logReq('DELETE', uri, headers);
    final res = await http.delete(uri, headers: headers);
    _logRes(res);
    return res;
  }

  static Future<http.Response> put(String path, {Map<String, String>? extraHeaders, Object? body}) async {
    final uri = Uri.parse('$_base$path');
    final headers = _headers(extra: extraHeaders);
    _logReq('PUT', uri, headers, body);
    final res = await http.put(uri, headers: headers, body: body == null ? null : jsonEncode(body));
    _logRes(res);
    return res;
  }
}
