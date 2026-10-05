import 'api_client.dart';

class NotificationsService {
  static Future<Map<String, dynamic>> getSettings() async {
    final data = await ApiClient.get('/api/notifications/settings/');
    return Map<String, dynamic>.from(data);
  }

  static Future<Map<String, dynamic>> updateSettings(
      Map<String, dynamic> patch) async {
    final data = await ApiClient.patch('/api/notifications/settings/', body: patch);
    return Map<String, dynamic>.from(data);
  }

  static Future<void> linkTelegram(String chatId) async {
    await ApiClient.post('/api/notifications/telegram/link/',
        body: {'chat_id': chatId});
  }

  static Future<void> unlinkTelegram() async {
    await ApiClient.post('/api/notifications/telegram/unlink/');
  }

  static Future<void> sendTest() async {
    await ApiClient.post('/api/notifications/test/');
  }
}