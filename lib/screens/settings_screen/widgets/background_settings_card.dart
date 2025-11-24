import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/app_backgrounds.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/background_selection_sheet.dart';

class BackgroundSettingsCard extends StatefulWidget {
  const BackgroundSettingsCard({super.key});

  @override
  State<BackgroundSettingsCard> createState() => _BackgroundSettingsCardState();
}

class _BackgroundSettingsCardState extends State<BackgroundSettingsCard> {
  final StorageService _storage = StorageService.instance;
  late String _currentBackgroundId;

  @override
  void initState() {
    super.initState();
    _loadCurrentBackground();
  }

  void _loadCurrentBackground() {
    setState(() {
      _currentBackgroundId = _storage.getBackgroundId();
    });
  }

  void _openSelectionSheet() {
    BackgroundSelectionSheet.show(
      context,
      currentBackgroundId: _currentBackgroundId,
      onBackgroundSelected: (newId) {
        setState(() {
          _currentBackgroundId = newId;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<AppBackground>(
      future: AppBackground.fromId(_currentBackgroundId),
      builder: (context, snapshot) {
        final currentBackground =
            snapshot.data ?? AppBackground.defaultBackground;

        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.image, color: colors.accent),
                ),
                title: Text(
                  '背景設定',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  '集中画面の背景を変更します',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),

              const Divider(height: 1),

              InkWell(
                onTap: _openSelectionSheet,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // プレビュー画像
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.divider, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset(
                            currentBackground.path,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: currentBackground.color.withOpacity(0.2),
                                child: Icon(
                                  currentBackground.icon,
                                  color: currentBackground.color,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentBackground.name,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            Text(
                              currentBackground.description,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Icon(Icons.chevron_right, color: colors.textTertiary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
