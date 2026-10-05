import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_store.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  static Future<Map<String, String>> _headers({bool json = true}) async {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    final token = await TokenStore.getAccess();
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  static Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path')
        .replace(queryParameters: query);
    final r = await http
        .get(uri, headers: await _headers(json: false))
        .timeout(ApiConfig.timeout);
    return _handle(r);
  }

  static Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final r = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: await _headers(),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.timeout);
    return _handle(r);
  }

  static Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final r = await http
        .patch(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: await _headers(),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.timeout);
    return _handle(r);
  }

  static Future<dynamic> delete(String path) async {
    final r = await http
        .delete(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: await _headers(json: false),
        )
        .timeout(ApiConfig.timeout);
    return _handle(r);
  }

  static dynamic _handle(http.Response r) {
    final body = r.body.isEmpty ? '{}' : utf8.decode(r.bodyBytes);
    final decoded = jsonDecode(body);

    if (r.statusCode >= 200 && r.statusCode < 300) {
      return decoded;
    }

    final message = decoded is Map
        ? (decoded['detail'] ?? decoded.toString())
        : decoded.toString();
    throw ApiException(r.statusCode, message);
  }
}