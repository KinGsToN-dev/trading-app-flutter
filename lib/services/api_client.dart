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

/// Callback, вызывается когда refresh-токен истёк —
/// нужно выкинуть пользователя на Login.
typedef LogoutCallback = void Function();

class ApiClient {
  /// Устанавливается извне (main.dart) — что делать при истечении refresh.
  static LogoutCallback? onUnauthorized;

  static Future<Map<String, String>> _headers({bool json = true}) async {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    final token = await TokenStore.getAccess();
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  static Future<dynamic> get(String path, {Map<String, String>? query}) async {
    return _withRetry(() async {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path')
          .replace(queryParameters: query);
      return http
          .get(uri, headers: await _headers(json: false))
          .timeout(ApiConfig.timeout);
    });
  }

  static Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    return _withRetry(() async {
      return http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: await _headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
    });
  }

  static Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    return _withRetry(() async {
      return http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: await _headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
    });
  }

  static Future<dynamic> delete(String path) async {
    return _withRetry(() async {
      return http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: await _headers(json: false),
          )
          .timeout(ApiConfig.timeout);
    });
  }

  /// Выполняет запрос, при 401 пытается обновить токен и повторить запрос.
  static Future<dynamic> _withRetry(
      Future<http.Response> Function() request) async {
    var response = await request();

    if (response.statusCode != 401) {
      return _handle(response);
    }

    // Пробуем обновить токен
    final newAccess = await _tryRefresh();
    if (newAccess == null) {
      // Refresh истёк — уведомляем приложение
      onUnauthorized?.call();
      return _handle(response);
    }

    // Повторяем запрос с новым токеном
    response = await request();
    return _handle(response);
  }

  /// Вызывает AuthService.refreshAccess, но через late-import,
  /// чтобы не было циклической зависимости.
  static Future<String?> _tryRefresh() async {
    // Импорт AuthService внутри функции — обход цикличности
    // ignore: avoid_dynamic_calls
    try {
      final authService = await _loadAuthService();
      return await authService();
    } catch (_) {
      return null;
    }
  }

  static Future<Future<String?> Function()> _loadAuthService() async {
    // Разрываем цикл: используем динамический вызов.
    // Проще: продублировать логику refresh здесь.
    final refresh = await TokenStore.getRefresh();
    if (refresh == null || refresh.isEmpty) return () async => null;

    return () async {
      try {
        final r = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/auth/refresh/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh': refresh}),
        ).timeout(ApiConfig.timeout);

        if (r.statusCode != 200) return null;

        final data = jsonDecode(utf8.decode(r.bodyBytes));
        final newAccess = data['access'] as String?;
        if (newAccess == null) return null;

        await TokenStore.saveAccess(newAccess);

        final newRefresh = data['refresh'] as String?;
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await TokenStore.save(access: newAccess, refresh: newRefresh);
        }

        return newAccess;
      } catch (_) {
        return null;
      }
    };
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