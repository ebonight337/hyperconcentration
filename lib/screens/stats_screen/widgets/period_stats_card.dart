import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppConstants.cardDecoration,
      child: Column(
        children: [
          _buildStatRow('今週', formatMinutes(weekMinutes)),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          _buildStatRow('今月', formatMinutes(monthMinutes)),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          _buildStatRow(
            '累計',
            formatMinutes(totalMinutes),
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlight ? 18 : 16,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: isHighlight
                ? AppConstants.accentColor
                : Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}
