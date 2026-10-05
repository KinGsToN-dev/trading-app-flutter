class Price {
  final String symbol;
  final double price;
  final double change24h;
  final String source;
  final DateTime updatedAt;

  Price({
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.source,
    required this.updatedAt,
  });

  factory Price.fromJson(Map<String, dynamic> json) => Price(
        symbol: json['symbol'] ?? '',
        price: double.parse(json['price'].toString()),
        change24h: double.tryParse(json['change_24h']?.toString() ?? '0') ?? 0,
        source: json['source'] ?? '',
        updatedAt: DateTime.parse(json['updated_at']),
      );

  bool get isUp => change24h >= 0;
}