import '../models/trade.dart';
import '../models/stats.dart';
import 'api_client.dart';

class TradesService {
  static Future<List<Trade>> list({
    String? symbol,
    String? status,
    String? search,
    String ordering = '-opened_at',
  }) async {
    final query = <String, String>{'ordering': ordering};
    if (symbol != null && symbol.isNotEmpty) query['symbol'] = symbol;
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final data = await ApiClient.get('/api/trades/', query: query);
    final results = data['results'] as List;
    return results.map((j) => Trade.fromJson(j)).toList();
  }

  static Future<Trade> detail(int id) async {
    final data = await ApiClient.get('/api/trades/$id/');
    return Trade.fromJson(data);
  }

  static Future<TradeStats> stats() async {
    final data = await ApiClient.get('/api/trades/stats/');
    return TradeStats.fromJson(data);
  }

  static Future<Trade> create(Map<String, dynamic> body) async {
    final data = await ApiClient.post('/api/trades/', body: body);
    return Trade.fromJson(data);
  }

  static Future<Trade> update(int id, Map<String, dynamic> body) async {
    final data = await ApiClient.patch('/api/trades/$id/', body: body);
    return Trade.fromJson(data);
  }

  static Future<void> delete(int id) async {
    await ApiClient.delete('/api/trades/$id/');
  }
}