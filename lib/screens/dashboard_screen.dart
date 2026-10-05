import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/stats.dart';
import '../models/trade.dart';
import '../services/trades_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/trade_tile.dart';
import 'trade_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TradeStats? _stats;
  List<Trade> _recentTrades = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        TradesService.stats(),
        TradesService.list(ordering: '-opened_at'),
      ]);
      final stats = results[0] as TradeStats;
      final trades = results[1] as List<Trade>;
      setState(() {
        _stats = stats;
        _recentTrades = trades.take(5).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
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

    final stats = _stats!;
    final pnlPositive = stats.totalPnl >= 0;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Главная карточка — PnL
          Card(
            color: pnlPositive
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Общий PnL',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${pnlPositive ? '+' : ''}${stats.totalPnl.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: pnlPositive ? Colors.green : Colors.red,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${stats.closedTrades} закрытых сделок',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Сетка метрик
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.6,
            children: [
              StatCard(
                title: 'Win Rate',
                value: '${stats.winRate.toStringAsFixed(1)}%',
                icon: Icons.percent,
                color: stats.winRate >= 50 ? Colors.green : Colors.orange,
                subtitle: '${stats.wins}W / ${stats.losses}L',
              ),
              StatCard(
                title: 'Всего сделок',
                value: '${stats.totalTrades}',
                icon: Icons.list_alt,
                color: Colors.blue,
                subtitle: '${stats.openTrades} открытых',
              ),
              StatCard(
                title: 'Средний Win',
                value: stats.avgWin.toStringAsFixed(1),
                icon: Icons.trending_up,
                color: Colors.green,
              ),
              StatCard(
                title: 'Средний Loss',
                value: stats.avgLoss.toStringAsFixed(1),
                icon: Icons.trending_down,
                color: Colors.red,
              ),
            ],
          ),

          // Лучшая/худшая сделка
          if (stats.bestTrade != null || stats.worstTrade != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (stats.bestTrade != null)
                  Expanded(
                    child: StatCard(
                      title: 'Лучшая',
                      value: '+${stats.bestTrade!.toStringAsFixed(2)}',
                      icon: Icons.emoji_events,
                      color: Colors.amber,
                    ),
                  ),
                if (stats.bestTrade != null && stats.worstTrade != null)
                  const SizedBox(width: 8),
                if (stats.worstTrade != null)
                  Expanded(
                    child: StatCard(
                      title: 'Худшая',
                      value: stats.worstTrade!.toStringAsFixed(2),
                      icon: Icons.warning_amber,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ],

          // Последние сделки
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Последние сделки',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          if (_recentTrades.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Пока нет сделок'),
              ),
            )
          else
            ..._recentTrades.map(
              (t) => TradeTile(
                trade: t,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TradeDetailScreen(tradeId: t.id),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}