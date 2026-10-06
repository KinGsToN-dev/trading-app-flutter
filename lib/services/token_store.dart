import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  static Future<void> save({
    required String access,
    required String refresh,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_accessKey, access);
    await p.setString(_refreshKey, refresh);
  }

  static Future<void> saveAccess(String access) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_accessKey, access);
  }

  static Future<String?> getAccess() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_accessKey);
  }

  static Future<String?> getRefresh() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_refreshKey);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_accessKey);
    await p.remove(_refreshKey);
  }

  static Future<bool> isLoggedIn() async {
    final t = await getAccess();
    return t != null && t.isNotEmpty;
  }
}