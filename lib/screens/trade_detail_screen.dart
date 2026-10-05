import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trade.dart';
import '../services/trades_service.dart';

class TradeDetailScreen extends StatefulWidget {
  final int tradeId;
  const TradeDetailScreen({super.key, required this.tradeId});

  @override
  State<TradeDetailScreen> createState() => _TradeDetailScreenState();
}

class _TradeDetailScreenState extends State<TradeDetailScreen> {
  Trade? _trade;
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
      final trade = await TradesService.detail(widget.tradeId);
      setState(() {
        _trade = trade;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_trade?.symbol ?? 'Сделка'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                            onPressed: _load,
                            child: const Text('Повторить')),
                      ],
                    ),
                  ),
                )
              : _buildContent(context, _trade!),
    );
  }

  Widget _buildContent(BuildContext context, Trade t) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final isBuy = t.side == 'buy';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Заголовок
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  isBuy ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 40,
                  color: isBuy ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 8),
                Text(
                  '${t.symbol} • ${t.side.toUpperCase()}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.isOpen ? 'Открыта' : 'Закрыта',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: t.isOpen ? Colors.orange : Colors.grey,
                  ),
                ),
                if (t.pnl != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${t.pnl! >= 0 ? '+' : ''}${t.pnl!.toStringAsFixed(2)}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: t.pnl! >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  Text('PnL', style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Детали
        _section('Цены', [
          _row('Вход', t.entryPrice.toStringAsFixed(2)),
          if (t.exitPrice != null) _row('Выход', t.exitPrice!.toStringAsFixed(2)),
          _row('Объём', t.quantity.toStringAsFixed(4)),
          _row('Комиссия', t.commission.toStringAsFixed(2)),
        ]),

        _section('Время', [
          _row('Открыта', dateFormat.format(t.openedAt.toLocal())),
          if (t.closedAt != null)
            _row('Закрыта', dateFormat.format(t.closedAt!.toLocal())),
        ]),

        _section('Источник', [
          _row('Тип', t.source == 'mt5' ? 'MetaTrader 5' : 'Вручную'),
          if (t.externalId.isNotEmpty)
            _row('External ID', t.externalId),
        ]),

        if (t.strategy.isNotEmpty || t.notes.isNotEmpty || t.emotion.isNotEmpty)
          _section('Метаданные', [
            if (t.strategy.isNotEmpty) _row('Стратегия', t.strategy),
            if (t.emotion.isNotEmpty) _row('Эмоция', t.emotion),
            _row('Следовал плану', t.followedPlan ? 'Да' : 'Нет'),
            if (t.tags.isNotEmpty) _row('Теги', t.tags.join(', ')),
          ]),

        if (t.notes.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Заметки',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(t.notes),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}