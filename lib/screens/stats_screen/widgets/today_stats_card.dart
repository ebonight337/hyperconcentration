import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

/// 今日の集中時間カード
class TodayStatsCard extends StatelessWidget {
  final int minutes;
  final String Function(int) formatMinutes;

  const TodayStatsCard({
    super.key,
    required this.minutes,
    required this.formatMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gradients = context.gradients;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: gradients.button,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '今日の集中時間',
            style: TextStyle(
              fontSize: 16,
              color: colors.textPrimary.withOpacity(0.8),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            formatMinutes(minutes),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
