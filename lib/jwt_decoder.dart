import 'dart:convert';

Map<String, dynamic>? decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = base64Url.normalize(parts[1]);
    final jsonStr = utf8.decode(base64Url.decode(payload));
    return json.decode(jsonStr) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}
