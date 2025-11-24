import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../utils/app_theme.dart';
import '../../../models/focus_session.dart';

/// 過去7日間のグラフ
class WeeklyChart extends StatelessWidget {
  final List<FocusSession> sessions;

  const WeeklyChart({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gradients = context.gradients;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradients.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              Icon(Icons.bar_chart, color: colors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                '過去7日間',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: _buildChart(colors)),
        ],
      ),
    );
  }

  Widget _buildChart(AppThemeColors colors) {
    final chartData = _prepareChartData();

    if (chartData.isEmpty || chartData.every((data) => data.minutes == 0)) {
      return Center(
        child: Text(
          'データがありません',
          style: TextStyle(color: colors.textDisabled, fontSize: 14),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(chartData),
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => colors.surface,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final data = chartData[group.x.toInt()];
              return BarTooltipItem(
                '${data.label}\n${_formatMinutes(data.minutes)}',
                TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: colors.textPrimary,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      chartData[value.toInt()].label,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
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
        barGroups: chartData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.minutes.toDouble(),
                gradient: LinearGradient(
                  colors: [colors.primary, colors.accent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<_ChartData> _prepareChartData() {
    final now = DateTime.now();
    final data = <_ChartData>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _formatDate(date);

      // その日のセッションを集計
      final dayMinutes = sessions
          .where((s) => _formatDate(s.date) == dateKey)
          .fold<int>(0, (sum, s) => sum + s.totalFocusMinutes);

      data.add(_ChartData(label: _getDayLabel(date), minutes: dayMinutes));
    }

    return data;
  }

  String _getDayLabel(DateTime date) {
    const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    return weekdays[date.weekday % 7];
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
  final String label;
  final int minutes;

  _ChartData({required this.label, required this.minutes});
}
