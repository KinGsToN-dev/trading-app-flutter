/// Конфигурация API.
/// ВАЖНО: при деплое замените на публичный URL backend.
class ApiConfig {
  // Публичный URL backend на Render
  static const String baseUrl = 'https://trading-assistant-backend-hih7.onrender.com';

  // 30 сек — Render Free засыпает, первый запрос медленный
  static const Duration timeout = Duration(seconds: 30);
}