import 'package:flutter/material.dart';
import '../models/candle.dart';
import '../models/price.dart';
import '../services/market_service.dart';
import '../widgets/candle_chart.dart';

class MarketDetailScreen extends StatefulWidget {
  final String symbol;
  const MarketDetailScreen({super.key, required this.symbol});

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen> {
  Price? _price;
  List<Candle> _candles = [];
  bool _loading = true;
  String? _error;
  String _interval = '1h';

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Умное форматирование цены: 2 знака для BTC, 4 для EURUSD, 6 для DOGE.
  String _formatPrice(double p) {
    if (p >= 1000) return p.toStringAsFixed(2);
    if (p >= 100) return p.toStringAsFixed(2);
    if (p >= 10) return p.toStringAsFixed(3);
    if (p >= 1) return p.toStringAsFixed(5);
    return p.toStringAsFixed(6);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        MarketService.price(widget.symbol),
        MarketService.candles(widget.symbol, interval: _interval, limit: 500),
      ]);
      setState(() {
        _price = results[0] as Price;
        _candles = results[1] as List<Candle>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _reloadCandles(String interval) async {
    setState(() {
      _interval = interval;
      _loading = true;
    });
    try {
      final candles = await MarketService.candles(
        widget.symbol,
        interval: interval,
        limit: 500,
      );
      setState(() {
        _candles = candles;
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
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
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_price != null) _buildPriceHeader(_price!, theme),
                    const SizedBox(height: 16),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: '1h', label: Text('1H')),
                        ButtonSegment(value: '4h', label: Text('4H')),
                        ButtonSegment(value: '1d', label: Text('1D')),
                      ],
                      selected: {_interval},
                      onSelectionChanged: (s) => _reloadCandles(s.first),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          height: 300,
                          child: _candles.isEmpty
                              ? const Center(child: Text('Нет свечей'))
                              : CandleChart(candles: _candles),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Статистика',
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const Divider(),
                            if (_candles.isNotEmpty) ...[
                              _row('Свечей', '${_candles.length}'),
                              _row(
                                'Максимум',
                                _formatPrice(_candles
                                    .map((c) => c.high)
                                    .reduce((a, b) => a > b ? a : b)),
                              ),
                              _row(
                                'Минимум',
                                _formatPrice(_candles
                                    .map((c) => c.low)
                                    .reduce((a, b) => a < b ? a : b)),
                              ),
                              _row(
                                'Изменение',
                                '${((_candles.last.close - _candles.first.open) / _candles.first.open * 100).toStringAsFixed(2)}%',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPriceHeader(Price p, ThemeData theme) {
    final isUp = p.isUp;
    final color = isUp ? Colors.green : Colors.red;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _formatPrice(p.price),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
                    color: color, size: 16),
                Text(
                  '${isUp ? '+' : ''}${p.change24h.toStringAsFixed(2)}% (24ч)',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Источник: ${p.source}',
              style: theme.textTheme.bodySmall,
            ),
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