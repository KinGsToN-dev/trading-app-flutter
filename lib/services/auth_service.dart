import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'token_store.dart';

class AuthService {
  static Future<User> login(String email, String password) async {
    final data = await ApiClient.post('/api/auth/login/', body: {
      'email': email,
      'password': password,
    });
    await TokenStore.save(
      access: data['access'],
      refresh: data['refresh'],
    );
    return me();
  }

  static Future<User> register(
      String email, String username, String password) async {
    final data = await ApiClient.post('/api/auth/register/', body: {
      'email': email,
      'username': username,
      'password': password,
      'password2': password,
    });
    await TokenStore.save(
      access: data['access'],
      refresh: data['refresh'],
    );
    return me();
  }

  static Future<User> me() async {
    final data = await ApiClient.get('/api/auth/me/');
    return User.fromJson(data);
  }

  static Future<void> logout() async {
    try {
      final refresh = await TokenStore.getRefresh();
      if (refresh != null) {
        await ApiClient.post('/api/auth/logout/', body: {'refresh': refresh});
      }
    } catch (_) {}
    await TokenStore.clear();
  }

  /// Обновляет access-токен через refresh-токен.
  /// Возвращает новый access или null, если refresh истёк.
  static Future<String?> refreshAccess() async {
    final refresh = await TokenStore.getRefresh();
    if (refresh == null || refresh.isEmpty) return null;

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

      // Если сервер выдал новый refresh (ROTATE_REFRESH_TOKENS), сохраняем его
      final newRefresh = data['refresh'] as String?;
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await TokenStore.save(access: newAccess, refresh: newRefresh);
      }

      return newAccess;
    } catch (_) {
      return null;
    }
  }
}