import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppConstants.cardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStreakItem(
            icon: Icons.local_fire_department,
            label: '連続達成',
            value: '${currentStreak}日',
            color: currentStreak > 0 ? Colors.orange : Colors.grey,
          ),
          Container(
            height: 50,
            width: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildStreakItem(
            icon: Icons.emoji_events,
            label: '最高記録',
            value: '${maxStreak}日',
            color: AppConstants.accentColor,
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
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}
