import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/constants.dart';

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppConstants.accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'アプリ情報',
                style: AppConstants.sectionTitleStyle,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // アプリ名
          _buildInfoRow(
            label: 'アプリ名',
            value: '過集中サポート',
          ),
          
          const SizedBox(height: 12),
          
          // プロジェクト名
          _buildInfoRow(
            label: 'プロジェクト名',
            value: 'hyperconcentration',
          ),
          
          const SizedBox(height: 12),
          
          // バージョン
          _buildInfoRow(
            label: 'バージョン',
            value: '1.0.0',
          ),
          
          const SizedBox(height: 12),
          
          // ビルド番号
          _buildInfoRow(
            label: 'ビルド番号',
            value: '1',
          ),
          
          const SizedBox(height: 16),
          
          // 開発者情報
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.code,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Made with Flutter',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
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
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
