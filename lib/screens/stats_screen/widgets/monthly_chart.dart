import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../utils/constants.dart';
import '../../../models/focus_session.dart';
import '../../../utils/app_theme.dart';

/// 過去30日間のグラフ
class MonthlyChart extends StatelessWidget {
  final List<FocusSession> sessions;

  const MonthlyChart({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.accent.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: colors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                '過去30日間',
                style: AppConstants.sectionTitleStyle.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: _buildChart(context)),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final colors = context.colors;
    final chartData = _prepareChartData();

    if (chartData.isEmpty || chartData.every((data) => data.minutes == 0)) {
      return Center(
        child: Text(
          'データがありません',
          style: TextStyle(color: colors.textTertiary, fontSize: 14),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (chartData.length - 1).toDouble(),
        minY: 0,
        maxY: _getMaxY(chartData),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => colors.surface,
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final data = chartData[spot.x.toInt()];
                return LineTooltipItem(
                  '${data.day}日\n${_formatMinutes(data.minutes)}',
                  TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                  // 5日ごとに表示
                  if (value.toInt() % 5 == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${chartData[value.toInt()].day}',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}分',
                  style: TextStyle(color: colors.textSecondary, fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getMaxY(chartData) / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: colors.divider, strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: chartData.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.minutes.toDouble(),
              );
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(colors: [colors.primary, colors.accent]),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: colors.accent,
                  strokeWidth: 2,
                  strokeColor: colors.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  colors.accent.withOpacity(0.2),
                  colors.accent.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_ChartData> _prepareChartData() {
    final now = DateTime.now();
    final data = <_ChartData>[];

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _formatDate(date);

      // その日のセッションを集計
      final dayMinutes = sessions
          .where((s) => _formatDate(s.date) == dateKey)
          .fold<int>(0, (sum, s) => sum + s.totalFocusMinutes);

      data.add(_ChartData(day: date.day, minutes: dayMinutes));
    }

    return data;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes}分';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '${hours}時間';
    }
    return '${hours}時間${mins}分';
  }

  double _getMaxY(List<_ChartData> data) {
    if (data.isEmpty) return 60;
    final maxMinutes = data
        .map((d) => d.minutes)
        .reduce((a, b) => a > b ? a : b);
    if (maxMinutes == 0) return 60;
    // 最大値の1.2倍を上限にする（余白を持たせる）
    return (maxMinutes * 1.2).ceilToDouble();
  }
}

class _ChartData {
  final int day;
  final int minutes;

  _ChartData({required this.day, required this.minutes});
}
