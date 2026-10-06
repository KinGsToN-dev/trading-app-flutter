import '../models/price.dart';
import '../models/candle.dart';
import 'api_client.dart';

class MarketService {
  static Future<List<Price>> watchlist() async {
    final data = await ApiClient.get('/api/market/watchlist/');
    return (data as List).map((j) => Price.fromJson(j)).toList();
  }

  static Future<Price> price(String symbol) async {
    final data = await ApiClient.get('/api/market/$symbol/');
    return Price.fromJson(data);
  }

  static Future<List<Candle>> candles(
  String symbol, {
  String interval = '1h',
  int limit = 500,
}) async {
  final data = await ApiClient.get(
    '/api/market/$symbol/candles/',
    query: {'interval': interval, 'limit': limit.toString()},
  );
  return (data as List).map((j) => Candle.fromJson(j)).toList();
}
}