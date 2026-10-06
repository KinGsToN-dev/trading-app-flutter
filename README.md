# 📱 Trading Assistant — Flutter Client

![Flutter Tests](https://github.com/KinGsToN-dev/trading-app-flutter/actions/workflows/tests.yml/badge.svg)

Flutter-приложение для [Trading Assistant](https://github.com/KinGsToN-dev/trading-assistant) — трейдинг-журнала на Django.

**🌐 Демо:** https://trading-assistant-almaz.web.app

**🔐 Тестовый аккаунт:** `admin@gmail.com` / `admin12345`

## ✨ Возможности

- 🔐 **JWT-аутентификация** с auto-refresh
- 🏠 **Dashboard** — статистика (Win Rate, PnL, avg), последние сделки
- 📝 **Trades** — список с поиском, фильтрами, сортировкой
- 📄 **Trade Detail** — все поля сделки
- 📈 **Market** — 10 символов (6 крипты + EURUSD, GBPUSD, USDJPY, XAUUSD)
- 📊 **Графики свечей** — `fl_chart`, таймфреймы 1H / 4H / 1D
- ⚙️ **Settings** — привязка Telegram, переключатели уведомлений
- 🌙 **Светлая и тёмная тема**

## 🏗️ Стек

- **Flutter 3.47** + Dart 3.13
- **fl_chart** — графики
- **http** — API-запросы
- **shared_preferences** — хранение JWT
- **go_router** — навигация

## 🚀 Быстрый старт

```bash
flutter pub get
flutter run -d chrome
⚠️ Backend должен работать. URL настраивается в lib/config/api_config.dart.

📁 Структура
text
lib/
├── config/api_config.dart
├── models/         # User, Trade, Price, Candle, Stats
├── services/       # API-клиент, Auth, Trades, Market, Notifications
├── screens/        # 8 экранов
├── widgets/        # LoadingOverlay, AppButton, StatCard, TradeTile, PriceCard, CandleChart
├── theme/
└── main.dart
🧪 Тесты
bash
flutter test
📄 Связанные проекты
Backend: trading-assistant

📄 Лицензия
MIT

text

---

## 🏷️ Шаг 5: Topics на GitHub (5 минут)

### Для `trading-assistant`:

1. Откройте https://github.com/KinGsToN-dev/trading-assistant
2. Справа от названия — **⚙️ шестерёнка** (Settings)
3. **Topics:**
django, python, rest-api, jwt, postgresql, flutter, trading, trading-journal,
meta-trader-5, mt5, telegram-bot, biquote, binance, ci-cd, github-actions,
full-stack, render, firebase, drf, ai-trading

text
4. **Description:**
AI-ассистент трейдера: Django + PostgreSQL + JWT + MT5 + Biquote + Telegram

text
5. **Website:** `https://trading-assistant-backend-hih7.onrender.com/api/docs/`

### Для `trading-app-flutter`:

1. Откройте https://github.com/KinGsToN-dev/trading-app-flutter
2. **Settings → Topics:**
flutter, dart, trading, mobile, web, jwt, fl-chart, firebase-hosting,
trading-app, crypto, forex, rest-api, django, full-stack

text
3. **Description:**
Flutter client for Trading Assistant: Dashboard, Trades, Market with charts

text
4. **Website:** `https://trading-assistant-almaz.web.app`

---