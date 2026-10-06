import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/candle.dart';

class CandleChart extends StatelessWidget {
  final List<Candle> candles;
  final Color lineColor;

  const CandleChart({
    super.key,
    required this.candles,
    this.lineColor = Colors.green,
  });

  /// Возвращает количество десятичных знаков в зависимости от диапазона.
  int _decimalsFor(double range) {
    if (range < 0.001) return 6;
    if (range < 0.01) return 5;
    if (range < 0.1) return 4;
    if (range < 1) return 3;
    if (range < 10) return 2;
    if (range < 100) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return const Center(child: Text('Нет данных'));
    }

    // Строим line chart по close prices
    final spots = <FlSpot>[];
    for (var i = 0; i < candles.length; i++) {
      spots.add(FlSpot(i.toDouble(), candles[i].close));
    }

    final minY = candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    final maxY = candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    final padding = range * 0.1;
    final decimals = _decimalsFor(range);
    final step = range / 5;

    final isUp = candles.last.close >= candles.first.open;
    final color = isUp ? Colors.green : Colors.red;

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: step,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.1),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 70, // больше места для 5-6 знаков
              interval: step,   // шаг сетки по оси Y
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    value.toStringAsFixed(decimals),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= candles.length) {
                  return const SizedBox.shrink();
                }
                final c = candles[idx];
                final stepCount = (candles.length / 5).ceil();
                if (idx % stepCount != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${c.timestamp.day}.${c.timestamp.month}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [color.withOpacity(0.6), color],
            ),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final c = candles[spot.x.toInt()];
                return LineTooltipItem(
                  '${c.timestamp.day}.${c.timestamp.month} ${c.timestamp.hour}:00\n'
                  '${c.close.toStringAsFixed(decimals)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}