import 'package:flutter/material.dart';
import '../../../models/achievement.dart';
import '../../../utils/app_theme.dart';
import 'achievement_detail_dialog.dart';

/// 実績バッジウィジェット
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final int currentProgress;

  const AchievementBadge({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    required this.currentProgress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = achievement.getProgress(currentProgress);

    return InkWell(
      onTap: () {
        // タップ時に詳細ダイアログを表示
        AchievementDetailDialog.show(
          context: context,
          achievement: achievement,
          isUnlocked: isUnlocked,
          currentProgress: currentProgress,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isUnlocked ? colors.accent.withOpacity(0.1) : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked ? colors.accent.withOpacity(0.5) : colors.divider,
            width: 1.5,
          ),
          boxShadow: [
            if (isUnlocked)
              BoxShadow(
                color: colors.accent.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 利用可能な高さを計算
            final availableHeight = constraints.maxHeight;
            // 説明文を表示するかどうか判定（高さが十分ある場合のみ）
            final showDescription = availableHeight > 110;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // アイコン
                Flexible(
                  flex: 0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // グロー効果（解除済みの場合）
                      if (isUnlocked)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colors.accent.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      // アイコン本体
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isUnlocked ? colors.accent : colors.divider,
                        ),
                        child: Center(
                          child: Text(
                            achievement.icon,
                            style: TextStyle(
                              fontSize: 24,
                              color: isUnlocked
                                  ? Colors.white
                                  : colors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                      // ロックアイコン（未解除の場合）
                      if (!isUnlocked)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: colors.divider,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock,
                              size: 14,
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // タイトル
                Flexible(
                  child: Text(
                    achievement.title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isUnlocked
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isUnlocked
                          ? colors.textPrimary
                          : colors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 説明（高さが十分な場合のみ表示）
                if (showDescription) ...[
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 8,
                        color: isUnlocked
                            ? colors.textSecondary
                            : colors.textTertiary,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                // 進捗バー（未解除の場合）
                if (!isUnlocked) ...[
                  const SizedBox(height: 4),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: colors.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colors.accent.withOpacity(0.6),
                            ),
                            minHeight: 3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          achievement.getProgressText(currentProgress),
                          style: TextStyle(
                            fontSize: 8,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
