import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../services/storage_service.dart';
import '../../../main.dart';

class ThemeSelectionCard extends StatelessWidget {
  const ThemeSelectionCard({super.key});

  Future<void> _changeTheme(BuildContext context, String themeId) async {
    // 設定を保存
    await StorageService.instance.saveThemeId(themeId);

    // アプリ全体のテーマを更新
    HyperConcentrationApp.themeNotifier.value = themeId;
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeId = HyperConcentrationApp.themeNotifier.value;

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
              Icon(Icons.palette_outlined, color: colors.accent, size: 24),
              const SizedBox(width: 12),
              Text(
                'テーマ設定',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // テーマ一覧
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AppTheme.availableThemes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final theme = AppTheme.availableThemes[index];
              final isSelected = theme.id == currentThemeId;

              return _buildThemeOption(context, theme, isSelected, colors);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeOption theme,
    bool isSelected,
    AppThemeColors appColors,
  ) {
    // プレビュー用の色を取得
    final colors = AppTheme.getColors(theme.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _changeTheme(context, theme.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? appColors.accent.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? appColors.accent
                  : appColors.textDisabled.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // カラープレビュー
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: appColors.divider, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),
              Icon(Icons.check_circle, color: appColors.accent, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
