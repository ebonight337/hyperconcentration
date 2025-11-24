import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/app_theme.dart';

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gradients = context.gradients;

    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(Icons.info_outline, color: colors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'アプリ情報',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // アプリ名
          _buildInfoRow(label: 'アプリ名', value: 'DeepFlow', colors: colors),

          const SizedBox(height: 12),

          // 製作者
          _buildInfoRow(
            label: 'プロジェクト名',
            value: 'Hyperconcentration',
            colors: colors,
          ),

          const SizedBox(height: 12),

          // バージョン
          _buildInfoRow(label: 'バージョン', value: '1.0.0', colors: colors),

          const SizedBox(height: 12),

          // ビルド番号
          _buildInfoRow(label: 'ビルド番号', value: '1', colors: colors),

          const SizedBox(height: 16),

          // 開発者情報
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.code, color: colors.textSecondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Created by えぼし',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // コピーライト
          Center(
            child: Text(
              '© 2025 Hyperconcentration',
              style: TextStyle(fontSize: 11, color: colors.textDisabled),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required AppThemeColors colors,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
