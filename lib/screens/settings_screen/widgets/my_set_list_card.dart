import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../models/my_set.dart';
import '../../../services/storage_service.dart';
import 'my_set_dialog.dart';

class MySetListCard extends StatefulWidget {
  final VoidCallback onSetApplied;

  const MySetListCard({super.key, required this.onSetApplied});

  @override
  State<MySetListCard> createState() => _MySetListCardState();
}

class _MySetListCardState extends State<MySetListCard> {
  final StorageService _storage = StorageService.instance;

  List<MySet> _mySets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMySets();
  }

  Future<void> _loadMySets() async {
    setState(() {
      _isLoading = true;
    });

    final sets = await _storage.getMySets();

    setState(() {
      _mySets = sets;
      _isLoading = false;
    });
  }

  Future<void> _addMySet() async {
    if (_mySets.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('マイセットは最大5つまでです'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showDialog<MySet>(
      context: context,
      builder: (context) => const MySetDialog(),
    );

    if (result != null) {
      try {
        await _storage.addMySet(result);
        await _loadMySets();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '「${result.name}」を追加しました',
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
              content: Text('追加に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editMySet(MySet mySet) async {
    final result = await showDialog<MySet>(
      context: context,
      builder: (context) => MySetDialog(editingSet: mySet),
    );

    if (result != null) {
      try {
        // 既存のセットを削除して新しいセットを追加
        await _storage.deleteMySet(mySet.id);
        await _storage.addMySet(result);
        await _loadMySets();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '「${result.name}」を更新しました',
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
              content: Text('更新に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteMySet(MySet mySet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(
          '削除確認',
          style: TextStyle(color: context.colors.textPrimary),
        ),
        content: Text(
          '「${mySet.name}」を削除しますか?',
          style: TextStyle(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storage.deleteMySet(mySet.id);
        await _loadMySets();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '「${mySet.name}」を削除しました',
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

  Future<void> _applyMySet(MySet mySet) async {
    // タイマー画面の設定に反映
    await _storage.saveLastTimerSettings(
      workMinutes: mySet.workMinutes,
      breakSeconds: mySet.breakMinutes * 60, // 分を秒に変換
      sets: mySet.sets,
    );

    widget.onSetApplied();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '「${mySet.name}」を適用しました',
            style: TextStyle(color: context.colors.textPrimary),
          ),
          backgroundColor: context.colors.surface,
        ),
      );
    }
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bookmark_outlined, color: colors.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'マイセット',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '${_mySets.length}/5',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(color: colors.accent),
              ),
            )
          else if (_mySets.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'マイセットがありません',
                  style: TextStyle(color: colors.textDisabled, fontSize: 14),
                ),
              ),
            )
          else
            ...List.generate(_mySets.length, (index) {
              final mySet = _mySets[index];
              return _buildMySetItem(mySet, colors);
            }),

          const SizedBox(height: 12),

          // 追加ボタン
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _mySets.length < 5 ? _addMySet : null,
              icon: const Icon(Icons.add),
              label: const Text('マイセットを追加'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.accent,
                side: BorderSide(
                  color: _mySets.length < 5
                      ? colors.accent
                      : colors.textDisabled,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMySetItem(MySet mySet, AppThemeColors colors) {
    final isDefault = mySet.id == 'default';
    final totalMinutes = (mySet.workMinutes + mySet.breakMinutes) * mySet.sets;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final totalTimeText = hours > 0 ? '${hours}時間${minutes}分' : '${minutes}分';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'デフォルト',
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isDefault) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mySet.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            '${mySet.workMinutes}分作業・${mySet.breakMinutes}分休憩・${mySet.sets}セット',
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),

          const SizedBox(height: 4),

          Text(
            '合計: $totalTimeText',
            style: TextStyle(fontSize: 12, color: colors.textTertiary),
          ),

          const SizedBox(height: 12),

          // アクションボタン
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 適用ボタン
              TextButton.icon(
                onPressed: () => _applyMySet(mySet),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('適用'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),

              // 編集ボタン
              TextButton.icon(
                onPressed: () => _editMySet(mySet),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('編集'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),

              // 削除ボタン（デフォルト以外）
              if (!isDefault)
                TextButton.icon(
                  onPressed: () => _deleteMySet(mySet),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('削除'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
