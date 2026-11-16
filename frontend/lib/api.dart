import 'dart:convert';

import 'package:http/http.dart' as http;

/// Base URL of the Python backend.
/// Override at build time:  flutter run -d chrome --dart-define=API_URL=http://localhost:8000
/// When the Flutter build is served by the backend itself, leave it empty (same origin).
const String apiBase = String.fromEnvironment('API_URL', defaultValue: '');

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class Api {
  static Uri _u(String path) => Uri.parse('$apiBase$path');

  static Future<Map<String, dynamic>> fetchSite() async {
    final res = await http.get(_u('/api/site'));
    if (res.statusCode != 200) {
      throw ApiException('Could not load event details (${res.statusCode}).');
    }
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> body) =>
      _post('/api/register', body);

  static Future<Map<String, dynamic>> contact(Map<String, dynamic> body) =>
      _post('/api/contact', body);

  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      _u(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data as Map<String, dynamic>;
    }
    throw ApiException(_errorText(data));
  }

  static String _errorText(dynamic data) {
    final detail = data is Map ? data['detail'] : null;
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      final field = (first['loc'] as List?)?.last ?? '';
      final msg = (first['msg'] ?? 'Invalid input').toString().replaceFirst('Value error, ', '');
      return field.toString().isEmpty ? msg : '$field: $msg';
    }
    return 'Something went wrong. Please try again.';
  }
}
