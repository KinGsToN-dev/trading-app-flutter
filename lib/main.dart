import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/token_store.dart';
import 'services/api_client.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

void main() {
  // Подписываемся на события 401 — если refresh истёк, кидаем на Login
  ApiClient.onUnauthorized = _handleUnauthorized;
  runApp(const MyApp());
}

/// Глобальный ключ для навигации из любого места.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void _handleUnauthorized() {
  // Очищаем токены
  TokenStore.clear();
  // Кидаем на Login
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trading Assistant',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: darkMode ? AppTheme.dark : AppTheme.light,
      home: const _Bootstrap(),
    );
  }
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final logged = await TokenStore.isLoggedIn();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => logged ? const MainShell() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}