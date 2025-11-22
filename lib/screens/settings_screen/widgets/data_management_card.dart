import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../services/storage_service.dart';
import '../../../models/achievement.dart';

class DataManagementCard extends StatefulWidget {
  const DataManagementCard({super.key});

  @override
  State<DataManagementCard> createState() => _DataManagementCardState();
}

class _DataManagementCardState extends State<DataManagementCard> {
  final StorageService _storage = StorageService.instance;

  int _totalMinutes = 0;
  int _currentStreak = 0;
  int _unlockedAchievements = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _storage.getStats();

      setState(() {
        _totalMinutes = stats.totalFocusMinutes;
        _currentStreak = stats.currentStreak;
        _unlockedAchievements = stats.unlockedAchievements.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanOldData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(
          '古いデータを削除',
          style: TextStyle(color: context.colors.textPrimary),
        ),
        content: Text(
          '1年以上前のセッションデータを削除します。\nよろしいですか?',
          style: TextStyle(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storage.cleanOldData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '古いデータを削除しました',
                style: TextStyle(color: context.colors.textPrimary),
              ),
              backgroundColor: context.colors.surface,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('削除に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _resetAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'データリセット',
              style: TextStyle(color: context.colors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '本当に全データをリセットしますか?',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'この操作は取り消せません。',
              style: TextStyle(
                color: Colors.red.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '削除される内容:',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...[
              '✓ 全てのセッション履歴',
              '✓ 統計データ（累計時間、連続日数）',
              '✓ 解除済み実績',
              '✓ マイセット（デフォルトは残る）',
              '✓ 設定情報',
            ].map(
              (item) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Text(
                  item,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withOpacity(0.1),
            ),
            child: const Text('リセットする'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storage.resetAllData();
        await _loadStats();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '全データをリセットしました',
                style: TextStyle(color: context.colors.textPrimary),
              ),
              backgroundColor: context.colors.surface,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('リセットに失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
              Icon(Icons.storage_outlined, color: colors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'データ管理',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // データ概要
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(color: colors.accent),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    '累計集中時間',
                    _formatMinutes(_totalMinutes),
                    colors,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow('連続達成日数', '$_currentStreak日', colors),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    '解除済み実績',
                    '$_unlockedAchievements/${Achievements.all.length}個',
                    colors,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // 古いデータ削除ボタン
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _cleanOldData,
              icon: const Icon(Icons.cleaning_services_outlined, size: 18),
              label: const Text('1年以上前のデータを削除'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 全データリセットボタン
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetAllData,
              icon: const Icon(Icons.delete_forever_outlined, size: 18),
              label: const Text('全データをリセット'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, AppThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
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
