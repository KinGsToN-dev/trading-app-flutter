import 'dart:async';
import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../services/trades_service.dart';
import '../widgets/trade_tile.dart';
import 'trade_detail_screen.dart';

class TradesScreen extends StatefulWidget {
  const TradesScreen({super.key});

  @override
  State<TradesScreen> createState() => _TradesScreenState();
}

class _TradesScreenState extends State<TradesScreen> {
  List<Trade> _trades = [];
  bool _loading = true;
  String? _error;
  final _searchController = TextEditingController();
  Timer? _debounce;
  String? _statusFilter;   // null, 'open', 'closed'
  String _ordering = '-opened_at';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final trades = await TradesService.list(
        status: _statusFilter,
        search: _searchController.text.trim(),
        ordering: _ordering,
      );
      setState(() {
        _trades = trades;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Сортировка',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            for (final e in {
              '-opened_at': 'Сначала новые',
              'opened_at': 'Сначала старые',
              '-pnl': 'По PnL ↓',
              'pnl': 'По PnL ↑',
              'symbol': 'По символу',
            }.entries)
              RadioListTile<String>(
                value: e.key,
                groupValue: _ordering,
                title: Text(e.value),
                onChanged: (v) {
                  Navigator.pop(context);
                  setState(() => _ordering = v!);
                  _load();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Поиск + Фильтры
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Поиск по символу и заметкам...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _load();
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<String?>(
                      segments: const [
                        ButtonSegment(value: null, label: Text('Все')),
                        ButtonSegment(value: 'open', label: Text('Открытые')),
                        ButtonSegment(value: 'closed', label: Text('Закрытые')),
                      ],
                      selected: {_statusFilter},
                      onSelectionChanged: (s) {
                        setState(() => _statusFilter = s.first);
                        _load();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _showSortMenu,
                    icon: const Icon(Icons.sort),
                    tooltip: 'Сортировка',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Список
        Expanded(
          child: _loading
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
                  : _trades.isEmpty
                      ? const Center(child: Text('Сделок не найдено'))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            itemCount: _trades.length,
                            itemBuilder: (context, i) => TradeTile(
                              trade: _trades[i],
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TradeDetailScreen(tradeId: _trades[i].id),
                                  ),
                                );
                                _load();
                              },
                            ),
                          ),
                        ),
        ),
      ],
    );
  }
}