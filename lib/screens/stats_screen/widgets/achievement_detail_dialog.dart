import 'package:flutter/material.dart';
import '../../../models/achievement.dart';
import '../../../utils/constants.dart';

/// 実績詳細ダイアログ
class AchievementDetailDialog extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final int currentProgress;

  const AchievementDetailDialog({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    required this.currentProgress,
  });

  /// ダイアログを表示
  static void show({
    required BuildContext context,
    required Achievement achievement,
    required bool isUnlocked,
    required int currentProgress,
  }) {
    showDialog(
      context: context,
      builder: (context) => AchievementDetailDialog(
        achievement: achievement,
        isUnlocked: isUnlocked,
        currentProgress: currentProgress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = achievement.getProgress(currentProgress);
    final progressPercentage = (progress * 100).toInt();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked
                ? AppConstants.accentColor.withOpacity(0.5)
                : Colors.white.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            if (isUnlocked)
              BoxShadow(
                color: AppConstants.accentColor.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // アイコン（大きく表示）
            Stack(
              alignment: Alignment.center,
              children: [
                // グロー効果（解除済みの場合）
                if (isUnlocked)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.accentColor.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                // アイコン本体
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked
                        ? AppConstants.accentColor.withOpacity(0.3)
                        : Colors.black.withOpacity(0.5),
                    border: Border.all(
                      color: isUnlocked
                          ? AppConstants.accentColor
                          : Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      achievement.icon,
                      style: TextStyle(
                        fontSize: 48,
                        color: isUnlocked
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
                // ロックアイコン（未解除の場合）
                if (!isUnlocked)
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock,
                        size: 24,
                        color: Colors.white70,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // ステータスバッジ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? AppConstants.accentColor.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isUnlocked
                      ? AppConstants.accentColor
                      : Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                isUnlocked ? '✨ 達成済み' : '🔒 未解除',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? AppConstants.accentColor
                      : Colors.white.withOpacity(0.6),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // タイトル
            Text(
              achievement.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isUnlocked
                    ? Colors.white
                    : Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // 実績タイプ
            Text(
              _getAchievementTypeText(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // 説明（全文表示）
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // 進捗情報
            if (!isUnlocked) ...[
              // 進捗バー
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '進捗',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        '$progressPercentage%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppConstants.accentColor,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.getProgressText(currentProgress),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ] else ...[
              // 達成日時（将来的に実装予定）
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppConstants.accentColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppConstants.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'おめでとうございます！',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 閉じるボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUnlocked
                      ? AppConstants.accentColor
                      : Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '閉じる',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAchievementTypeText() {
    switch (achievement.type) {
      case AchievementType.cumulative:
        return '🏆 達成型 - 累計記録';
      case AchievementType.streak:
        return '📅 継続型 - 連続記録';
      case AchievementType.daily:
        return '⚡ チャレンジ型 - 1日の記録';
    }
  }
}
