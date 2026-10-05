class TradeStats {
  final int totalTrades;
  final int openTrades;
  final int closedTrades;
  final int wins;
  final int losses;
  final double winRate;
  final double totalPnl;
  final double avgPnl;
  final double avgWin;
  final double avgLoss;
  final double? bestTrade;
  final double? worstTrade;

  TradeStats({
    required this.totalTrades,
    required this.openTrades,
    required this.closedTrades,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.totalPnl,
    required this.avgPnl,
    required this.avgWin,
    required this.avgLoss,
    this.bestTrade,
    this.worstTrade,
  });

  factory TradeStats.fromJson(Map<String, dynamic> json) => TradeStats(
        totalTrades: json['total_trades'] ?? 0,
        openTrades: json['open_trades'] ?? 0,
        closedTrades: json['closed_trades'] ?? 0,
        wins: json['wins'] ?? 0,
        losses: json['losses'] ?? 0,
        winRate: double.tryParse(json['win_rate']?.toString() ?? '0') ?? 0,
        totalPnl: double.tryParse(json['total_pnl']?.toString() ?? '0') ?? 0,
        avgPnl: double.tryParse(json['avg_pnl']?.toString() ?? '0') ?? 0,
        avgWin: double.tryParse(json['avg_win']?.toString() ?? '0') ?? 0,
        avgLoss: double.tryParse(json['avg_loss']?.toString() ?? '0') ?? 0,
        bestTrade: json['best_trade'] != null
            ? double.tryParse(json['best_trade'].toString())
            : null,
        worstTrade: json['worst_trade'] != null
            ? double.tryParse(json['worst_trade'].toString())
            : null,
      );
}