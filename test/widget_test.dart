import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app_flutter/models/trade.dart';
import 'package:trading_app_flutter/models/price.dart';
import 'package:trading_app_flutter/models/stats.dart';

void main() {
  group('Trade model', () {
    test('fromJson парсит корректно', () {
      final trade = Trade.fromJson({
        'id': 1,
        'symbol': 'BTCUSDT',
        'side': 'buy',
        'status': 'closed',
        'entry_price': '50000',
        'exit_price': '52000',
        'quantity': '0.1',
        'pnl': '200',
        'commission': '0',
        'opened_at': '2026-10-05T12:00:00Z',
        'closed_at': '2026-10-05T14:00:00Z',
        'strategy': 'breakout',
        'tags': [],
        'notes': '',
        'emotion': '',
        'followed_plan': true,
        'source': 'mt5',
        'external_id': 'mt5-123',
      });
      expect(trade.id, 1);
      expect(trade.symbol, 'BTCUSDT');
      expect(trade.entryPrice, 50000);
      expect(trade.exitPrice, 52000);
      expect(trade.pnl, 200);
      expect(trade.isWin, true);
      expect(trade.isOpen, false);
    });

    test('fromJson обрабатывает null exit_price и pnl', () {
      final trade = Trade.fromJson({
        'id': 2,
        'symbol': 'ETHUSDT',
        'side': 'sell',
        'status': 'open',
        'entry_price': '3000',
        'exit_price': null,
        'quantity': '1',
        'pnl': null,
        'commission': '0',
        'opened_at': '2026-10-05T12:00:00Z',
        'closed_at': null,
        'strategy': '',
        'tags': [],
        'notes': '',
        'emotion': '',
        'followed_plan': true,
        'source': 'manual',
        'external_id': '',
      });
      expect(trade.exitPrice, isNull);
      expect(trade.pnl, isNull);
      expect(trade.isOpen, true);
      expect(trade.isWin, false);
      expect(trade.isLoss, false);
    });
  });

  group('Price model', () {
    test('fromJson парсит корректно', () {
      final price = Price.fromJson({
        'symbol': 'ETHUSDT',
        'price': '2699.84',
        'change_24h': '-0.11',
        'source': 'coingecko',
        'updated_at': '2026-10-06T00:00:00Z',
      });
      expect(price.symbol, 'ETHUSDT');
      expect(price.price, 2699.84);
      expect(price.change24h, -0.11);
      expect(price.isUp, false);
    });

    test('isUp = true при положительном изменении', () {
      final price = Price.fromJson({
        'symbol': 'BTCUSDT',
        'price': '85000',
        'change_24h': '2.5',
        'source': 'coingecko',
        'updated_at': '2026-10-06T00:00:00Z',
      });
      expect(price.isUp, true);
    });
  });

  group('TradeStats model', () {
    test('fromJson парсит корректно', () {
      final stats = TradeStats.fromJson({
        'total_trades': 11,
        'open_trades': 2,
        'closed_trades': 9,
        'wins': 4,
        'losses': 5,
        'win_rate': 44.4,
        'total_pnl': '449.55',
        'avg_pnl': '50',
        'avg_win': '1043.8',
        'avg_loss': '-745.1',
        'best_trade': '3555',
        'worst_trade': '-1926',
      });
      expect(stats.totalTrades, 11);
      expect(stats.openTrades, 2);
      expect(stats.closedTrades, 9);
      expect(stats.wins, 4);
      expect(stats.losses, 5);
      expect(stats.winRate, 44.4);
      expect(stats.totalPnl, 449.55);
    });
  });
}