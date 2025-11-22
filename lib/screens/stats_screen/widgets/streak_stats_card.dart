import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

/// 連続達成日数カード
class StreakStatsCard extends StatelessWidget {
  final int currentStreak;
  final int maxStreak;

  const StreakStatsCard({
    super.key,
    required this.currentStreak,
    required this.maxStreak,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStreakItem(
            icon: Icons.local_fire_department,
            label: '連続達成',
            value: '${currentStreak}日',
            color: currentStreak > 0 ? colors.warning : colors.textDisabled,
            textColor: colors.textPrimary,
            subTextColor: colors.textSecondary,
          ),
          Container(
            height: 50,
            width: 1,
            color: colors.divider,
          ),
          _buildStreakItem(
            icon: Icons.emoji_events,
            label: '最高記録',
            value: '${maxStreak}日',
            color: colors.accent,
            textColor: colors.textPrimary,
            subTextColor: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 36,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: subTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
