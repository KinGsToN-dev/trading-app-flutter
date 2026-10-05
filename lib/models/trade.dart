class Trade {
  final int id;
  final String symbol;
  final String side;       // buy / sell
  final String status;     // open / closed
  final double entryPrice;
  final double? exitPrice;
  final double quantity;
  final double? pnl;
  final double commission;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String strategy;
  final List<String> tags;
  final String notes;
  final String emotion;
  final bool followedPlan;
  final String source;      // manual / mt5
  final String externalId;

  Trade({
    required this.id,
    required this.symbol,
    required this.side,
    required this.status,
    required this.entryPrice,
    this.exitPrice,
    required this.quantity,
    this.pnl,
    required this.commission,
    required this.openedAt,
    this.closedAt,
    required this.strategy,
    required this.tags,
    required this.notes,
    required this.emotion,
    required this.followedPlan,
    required this.source,
    required this.externalId,
  });

  factory Trade.fromJson(Map<String, dynamic> json) => Trade(
        id: json['id'],
        symbol: json['symbol'] ?? '',
        side: json['side'] ?? 'buy',
        status: json['status'] ?? 'open',
        entryPrice: double.parse(json['entry_price'].toString()),
        exitPrice: json['exit_price'] != null
            ? double.tryParse(json['exit_price'].toString())
            : null,
        quantity: double.parse(json['quantity'].toString()),
        pnl: json['pnl'] != null ? double.tryParse(json['pnl'].toString()) : null,
        commission: double.tryParse(json['commission']?.toString() ?? '0') ?? 0,
        openedAt: DateTime.parse(json['opened_at']),
        closedAt: json['closed_at'] != null ? DateTime.tryParse(json['closed_at']) : null,
        strategy: json['strategy'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        notes: json['notes'] ?? '',
        emotion: json['emotion'] ?? '',
        followedPlan: json['followed_plan'] ?? true,
        source: json['source'] ?? 'manual',
        externalId: json['external_id'] ?? '',
      );

  bool get isOpen => status == 'open';
  bool get isWin => pnl != null && pnl! > 0;
  bool get isLoss => pnl != null && pnl! < 0;
}