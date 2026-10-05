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
}