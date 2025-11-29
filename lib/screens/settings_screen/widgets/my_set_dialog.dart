import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../models/my_set.dart';

class MySetDialog extends StatefulWidget {
  final MySet? editingSet;

  const MySetDialog({super.key, this.editingSet});

  @override
  State<MySetDialog> createState() => _MySetDialogState();
}

class _MySetDialogState extends State<MySetDialog> {
  late TextEditingController _nameController;
  late double _workMinutes;
  late double _breakMinutes;
  late int _sets;

  bool get isEditing => widget.editingSet != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      _nameController = TextEditingController(text: widget.editingSet!.name);
      _workMinutes = widget.editingSet!.workMinutes.toDouble();
      _breakMinutes = widget.editingSet!.breakMinutes.toDouble();
      _sets = widget.editingSet!.sets;
    } else {
      _nameController = TextEditingController();
      _workMinutes = AppConstants.defaultWorkMinutes.toDouble();
      _breakMinutes = AppConstants.defaultBreakMinutes.toDouble();
      _sets = AppConstants.defaultSets;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('名前を入力してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final mySet = MySet(
      id: isEditing
          ? widget.editingSet!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      workMinutes: _workMinutes.toInt(),
      breakMinutes: _breakMinutes.toInt(),
      sets: _sets,
    );

    Navigator.of(context).pop(mySet);
  }

  String _formatTotalTime() {
    final totalMinutes = (_workMinutes + _breakMinutes) * _sets;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      return '${hours}時間${minutes.toInt()}分';
    }
    return '${minutes.toInt()}分';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppConstants.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // タイトル
              Text(
                isEditing ? 'マイセットを編集' : 'マイセットを追加',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // 名前入力
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '名前',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  hintText: '例: 短時間集中',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppConstants.primaryColor.withOpacity(0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppConstants.primaryColor.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppConstants.accentColor,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 作業時間
              _buildTimeSlider(
                title: '作業時間',
                value: _workMinutes,
                min: AppConstants.minWorkMinutes.toDouble(),
                max: AppConstants.maxWorkMinutes.toDouble(),
                onChanged: (value) {
                  setState(() {
                    _workMinutes = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // 休憩時間
              _buildTimeSlider(
                title: '休憩時間',
                value: _breakMinutes,
                min: 0.0, // 0分も選択可能
                max: AppConstants.maxBreakMinutes.toDouble(),
                onChanged: (value) {
                  setState(() {
                    _breakMinutes = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // セット数
              _buildSetSelector(),

              const SizedBox(height: 24),

              // 合計時間プレビュー
              Container(
                padding: const EdgeInsets.all(16),
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
                    const Icon(
                      Icons.access_time,
                      color: AppConstants.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '合計: ${_formatTotalTime()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.accentColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ボタン
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white.withOpacity(0.7),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('キャンセル'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${value.toInt()}分',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.accentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppConstants.accentColor,
            inactiveTrackColor: AppConstants.primaryColor.withOpacity(0.3),
            thumbColor: AppConstants.accentColor,
            overlayColor: AppConstants.accentColor.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: title == '作業時間'
                ? ((max - min) / 1).toInt()
                : ((max - min) / 5).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'セット数',
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // マイナスボタン
            IconButton(
              onPressed: _sets > AppConstants.minSets
                  ? () {
                      setState(() {
                        _sets--;
                      });
                    }
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: AppConstants.accentColor,
              iconSize: 32,
            ),

            const SizedBox(width: 16),

            // セット数表示
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppConstants.accentColor, width: 2),
              ),
              child: Text(
                '$_sets',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.accentColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(width: 16),

            // プラスボタン
            IconButton(
              onPressed: _sets < AppConstants.maxSets
                  ? () {
                      setState(() {
                        _sets++;
                      });
                    }
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              color: AppConstants.accentColor,
              iconSize: 32,
            ),
          ],
        ),
      ],
    );
  }
}
