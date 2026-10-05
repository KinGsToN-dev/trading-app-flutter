import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trade.dart';

class TradeTile extends StatelessWidget {
  final Trade trade;
  final VoidCallback? onTap;

  const TradeTile({super.key, required this.trade, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBuy = trade.side == 'buy';
    final sideColor = isBuy ? Colors.green : Colors.red;
    final dateFormat = DateFormat('dd.MM.yy HH:mm');

    // PnL цвет
    Color pnlColor = theme.colorScheme.onSurface;
    if (trade.pnl != null) {
      pnlColor = trade.pnl! >= 0 ? Colors.green : Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Иконка BUY/SELL
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sideColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isBuy ? Icons.arrow_upward : Icons.arrow_downward,
                  color: sideColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Основная информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          trade.symbol,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: trade.isOpen
                                ? Colors.orange.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            trade.isOpen ? 'OPEN' : 'CLOSED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: trade.isOpen
                                  ? Colors.orange[700]
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                        if (trade.source == 'mt5') ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.auto_mode,
                              size: 12, color: Colors.purple),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Вход: ${trade.entryPrice.toStringAsFixed(2)}'
                      '${trade.exitPrice != null ? ' → ${trade.exitPrice!.toStringAsFixed(2)}' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(trade.openedAt.toLocal()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // PnL
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (trade.pnl != null)
                    Text(
                      '${trade.pnl! >= 0 ? '+' : ''}${trade.pnl!.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: pnlColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      '—',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (trade.strategy.isNotEmpty)
                    Text(
                      trade.strategy,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}