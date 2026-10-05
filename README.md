# 📱 Trading Assistant — Flutter Client

Мобильное и веб-приложение для [Trading Assistant](https://github.com/KinGsToN-dev/trading-assistant) — трейдинг-журнала на Django.

## ✨ Возможности

- 🔐 **Аутентификация** — JWT (access + refresh), сохранение сессии
- 🏠 **Дашборд** — статистика (Win Rate, PnL, средние), последние сделки
- 📝 **Журнал сделок** — список с поиском, фильтрами (open/closed), сортировкой
- 📄 **Детали сделки** — все поля: цены, время, PnL, MT5 ID, заметки
- 📈 **Рыночные данные** — цены крипты (CoinGecko) и форекса (MT5)
- 📊 **Свечные графики** — `fl_chart`, таймфреймы 1Д / 7Д / 30Д / 1Г
- ⚙️ **Settings** — привязка Telegram, переключатели уведомлений
- 🌙 **Тёмная тема**

## 🏗️ Стек

| Слой | Технологии |
|---|---|
| Framework | Flutter 3.47, Dart 3.13 |
| HTTP | `http` |
| State | `setState` + сервисы |
| Хранение | `shared_preferences` |
| Графики | `fl_chart` |
| Навигация | `MaterialPageRoute` |

## 🚀 Быстрый старт

### Предварительно

Убедитесь, что backend работает:

```bash
cd trading-assistant/backend
python manage.py runserver
API будет доступен на http://127.0.0.1:8000.

Запуск Flutter
bash
flutter pub get
flutter run -d chrome
Приложение откроется в Chrome по адресу http://localhost:XXXXX.

Логин
Используйте credentials вашего суперюзера (создаётся через python manage.py createsuperuser).

📁 Структура
text
lib/
├── config/
│   └── api_config.dart        # URL backend
├── models/                    # User, Trade, Price, Candle, Stats
├── services/                  # API-клиент + сервисы
│   ├── token_store.dart       # JWT в shared_preferences
│   ├── api_client.dart        # HTTP + JWT + обработка ошибок
│   ├── auth_service.dart
│   ├── trades_service.dart
│   ├── market_service.dart
│   └── notifications_service.dart
├── screens/                   # 8 экранов
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_shell.dart        # Bottom Navigation
│   ├── dashboard_screen.dart
│   ├── trades_screen.dart
│   ├── trade_detail_screen.dart
│   ├── market_screen.dart
│   ├── market_detail_screen.dart
│   └── settings_screen.dart
├── widgets/                   # переиспользуемые
│   ├── loading_overlay.dart
│   ├── app_button.dart
│   ├── stat_card.dart
│   ├── trade_tile.dart
│   ├── price_card.dart
│   └── candle_chart.dart
├── theme/
│   └── app_theme.dart         # светлая + тёмная
└── main.dart
🔧 Конфигурация API
В lib/config/api_config.dart укажите URL вашего backend:

dart
static const String baseUrl = 'http://127.0.0.1:8000';
Локально: http://127.0.0.1:8000

Android-эмулятор: http://10.0.2.2:8000

Реальное устройство: http://<IP_ПК>:8000

Продакшен: публичный URL backend (Render)

📄 Связанные проекты
Backend: trading-assistant — Django + PostgreSQL + MT5 + Telegram

📄 Лицензия
MIT