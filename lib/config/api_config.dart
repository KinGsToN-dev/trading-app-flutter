/// Конфигурация API.
/// ВАЖНО: при деплое замените на публичный URL backend.
class ApiConfig {
  // Локальная разработка: backend на том же ПК
  // Web: http://127.0.0.1:8000
  // Android-эмулятор: http://10.0.2.2:8000
  // Реальное устройство: http://<IP_ПК>:8000
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Таймаут запросов
  static const Duration timeout = Duration(seconds: 15);
}