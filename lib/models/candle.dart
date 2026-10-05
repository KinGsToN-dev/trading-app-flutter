class Candle {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory Candle.fromJson(Map<String, dynamic> json) => Candle(
        timestamp: DateTime.parse(json['timestamp']),
        open: double.parse(json['open'].toString()),
        high: double.parse(json['high'].toString()),
        low: double.parse(json['low'].toString()),
        close: double.parse(json['close'].toString()),
        volume: double.tryParse(json['volume']?.toString() ?? '0') ?? 0,
      );

  bool get isUp => close >= open;
}