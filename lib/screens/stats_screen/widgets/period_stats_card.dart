import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

/// 週・月・累計統計カード
class PeriodStatsCard extends StatelessWidget {
  final int weekMinutes;
  final int monthMinutes;
  final int totalMinutes;
  final String Function(int) formatMinutes;

  const PeriodStatsCard({
    super.key,
    required this.weekMinutes,
    required this.monthMinutes,
    required this.totalMinutes,
    required this.formatMinutes,
  });

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
        children: [
          _buildStatRow('今週', formatMinutes(weekMinutes), colors),
          const SizedBox(height: 16),
          Divider(color: colors.divider),
          const SizedBox(height: 16),
          _buildStatRow('今月', formatMinutes(monthMinutes), colors),
          const SizedBox(height: 16),
          Divider(color: colors.divider),
          const SizedBox(height: 16),
          _buildStatRow(
            '累計',
            formatMinutes(totalMinutes),
            colors,
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, AppThemeColors colors, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlight ? 18 : 16,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            color: colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: isHighlight
                ? colors.accent
                : colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
