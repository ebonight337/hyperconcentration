import 'package:flutter/material.dart';
import '../utils/app_backgrounds.dart';
import '../utils/app_theme.dart';
import '../services/storage_service.dart';

class BackgroundSelectionSheet extends StatefulWidget {
  final String currentBackgroundId;
  final Function(String) onBackgroundSelected;

  const BackgroundSelectionSheet({
    super.key,
    required this.currentBackgroundId,
    required this.onBackgroundSelected,
  });

  static void show(
    BuildContext context, {
    required String currentBackgroundId,
    required Function(String) onBackgroundSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackgroundSelectionSheet(
        currentBackgroundId: currentBackgroundId,
        onBackgroundSelected: onBackgroundSelected,
      ),
    );
  }

  @override
  State<BackgroundSelectionSheet> createState() =>
      _BackgroundSelectionSheetState();
}

class _BackgroundSelectionSheetState extends State<BackgroundSelectionSheet> {
  late String _selectedId;
  final StorageService _storage = StorageService.instance;
  late Future<List<AppBackground>> _backgroundsFuture;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.currentBackgroundId;
    _backgroundsFuture = AppBackground.getAll();
  }

  Future<void> _selectBackground(String id) async {
    setState(() {
      _selectedId = id;
    });

    // 保存
    await _storage.saveBackgroundId(id);

    // コールバック呼び出し
    widget.onBackgroundSelected(id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '背景を選択',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 220,
            child: FutureBuilder<List<AppBackground>>(
              future: _backgroundsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('背景が見つかりません'));
                }

                final backgrounds = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: backgrounds.length,
                  itemBuilder: (context, index) {
                    final background = backgrounds[index];
                    final isSelected = background.id == _selectedId;

                    return GestureDetector(
                      onTap: () => _selectBackground(background.id),
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? colors.accent
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: colors.accent.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 背景画像プレビュー
                              Image.asset(
                                background.path,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: background.color.withOpacity(0.2),
                                    child: Icon(
                                      background.icon,
                                      size: 48,
                                      color: background.color,
                                    ),
                                  );
                                },
                              ),

                              // 選択時のオーバーレイ
                              if (isSelected)
                                Container(
                                  color: colors.accent.withOpacity(0.2),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: colors.accent,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),

                              // ラベル
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.8),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        background.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        background.description,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 10,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
