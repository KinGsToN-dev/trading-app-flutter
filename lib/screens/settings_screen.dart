import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/notifications_service.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/app_button.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? _user;
  Map<String, dynamic>? _settings;
  bool _loading = true;
  String? _error;
  final _chatIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _chatIdController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        AuthService.me(),
        NotificationsService.getSettings(),
      ]);
      setState(() {
        _user = results[0] as User;
        _settings = results[1] as Map<String, dynamic>;
        _chatIdController.text = _settings!['telegram_chat_id'] ?? '';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _linkTelegram() async {
    final chatId = _chatIdController.text.trim();
    if (chatId.isEmpty) {
      _snack('Введите chat_id');
      return;
    }
    setState(() => _loading = true);
    try {
      await NotificationsService.linkTelegram(chatId);
      _snack('Telegram привязан! Проверьте сообщение в боте.');
      await _load();
    } catch (e) {
      _snack('Ошибка: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _unlinkTelegram() async {
    setState(() => _loading = true);
    try {
      await NotificationsService.unlinkTelegram();
      _chatIdController.clear();
      _snack('Telegram отвязан');
      await _load();
    } catch (e) {
      _snack('Ошибка: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _sendTest() async {
    setState(() => _loading = true);
    try {
      await NotificationsService.sendTest();
      _snack('Тестовое уведомление отправлено!');
    } catch (e) {
      _snack('Ошибка: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateToggle(String key, bool value) async {
    try {
      await NotificationsService.updateSettings({key: value});
      setState(() {
        _settings![key] = value;
      });
    } catch (e) {
      _snack('Ошибка: $e');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Выйти?'),
        content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Нет')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Да')),
        ],
      ),
    );
    if (ok != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Повторить')),
            ],
          ),
        ),
      );
    }

    final s = _settings!;
    final hasChatId = (s['telegram_chat_id'] ?? '').toString().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Профиль
        Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                (_user!.username.isNotEmpty ? _user!.username[0] : '?')
                    .toUpperCase(),
              ),
            ),
            title: Text(_user!.username),
            subtitle: Text(_user!.email),
          ),
        ),
        const SizedBox(height: 16),

        // Telegram
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.telegram, color: Color(0xFF229ED9)),
                    const SizedBox(width: 8),
                    Text('Telegram',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (hasChatId)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('✓ Привязан',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _chatIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ваш Telegram chat_id',
                    helperText: 'Узнать: @userinfobot в Telegram',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: hasChatId ? 'Обновить' : 'Привязать',
                        icon: Icons.link,
                        onPressed: _linkTelegram,
                      ),
                    ),
                    if (hasChatId) ...[
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: _unlinkTelegram,
                        icon: const Icon(Icons.link_off),
                        tooltip: 'Отвязать',
                      ),
                    ],
                  ],
                ),
                if (hasChatId) ...[
                  const SizedBox(height: 8),
                  AppButton(
                    text: 'Тестовое уведомление',
                    icon: Icons.send,
                    outlined: true,
                    onPressed: _sendTest,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Настройки уведомлений
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Уведомления',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Новые сделки'),
                  subtitle: const Text('При открытии / закрытии'),
                  value: s['notify_new_trade'] ?? true,
                  onChanged: (v) => _updateToggle('notify_new_trade', v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('TP / SL'),
                  subtitle: const Text('Достижение уровней'),
                  value: s['notify_tp_sl'] ?? true,
                  onChanged: (v) => _updateToggle('notify_tp_sl', v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Утренний дайджест'),
                  subtitle: const Text('Статистика за день'),
                  value: s['notify_daily_digest'] ?? true,
                  onChanged: (v) => _updateToggle('notify_daily_digest', v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Logout
        OutlinedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text('Выйти', style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}