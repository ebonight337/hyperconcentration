import 'package:flutter/material.dart';
import 'focus_screen.dart';
import '../utils/constants.dart';
import '../utils/app_theme.dart';
import '../services/storage_service.dart';
import '../models/my_set.dart';
import '../screens/settings_screen/widgets/my_set_dialog.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final StorageService _storage = StorageService.instance;
  
  // デフォルト値
  double _workMinutes = AppConstants.defaultWorkMinutes.toDouble();
  double _breakMinutes = AppConstants.defaultBreakMinutes.toDouble();
  int _sets = AppConstants.defaultSets;
  
  // マイセット関連
  List<MySet> _mySets = [];
  MySet? _selectedMySet;
  bool _isCustom = false; // 手動で変更された場合true
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// データを読み込む
  Future<void> _loadData() async {
    try {
      // マイセット一覧を取得
      final mySets = await _storage.getMySets();
      
      // 最後の設定を読み込む
      final settings = await _storage.getLastTimerSettings();
      
      setState(() {
        _mySets = mySets;
        _workMinutes = settings['workMinutes']!.toDouble();
        // 休憩時間を秒数から分に変換して補正
        _breakMinutes = _validateBreakMinutes(settings['breakSeconds']! / 60.0);
        _sets = settings['sets']!;
        
        // 最後の設定と一致するマイセットがあれば選択
        _selectedMySet = _findMatchingMySet();
        _isCustom = _selectedMySet == null;
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// 休憩時間の値を検証・補正
  double _validateBreakMinutes(double value) {
    if (value < AppConstants.minBreakMinutes) {
      return AppConstants.minBreakMinutes;
    } else if (value > AppConstants.maxBreakMinutes) {
      return AppConstants.maxBreakMinutes;
    }
    return value;
  }

  /// 現在の設定と一致するマイセットを探す
  MySet? _findMatchingMySet() {
    for (final mySet in _mySets) {
      if (mySet.workMinutes == _workMinutes.toInt() &&
          mySet.breakMinutes == _breakMinutes.toInt() &&
          mySet.sets == _sets) {
        return mySet;
      }
    }
    return null;
  }

  /// 設定を保存
  Future<void> _saveSettings() async {
    await _storage.saveLastTimerSettings(
      workMinutes: _workMinutes.toInt(),
      breakSeconds: (_breakMinutes * 60).toInt(), // 分を秒に変換
      sets: _sets,
    );
  }

  /// マイセットを選択
  void _selectMySet(MySet? mySet) {
    if (mySet == null) return;
    
    setState(() {
      _selectedMySet = mySet;
      _workMinutes = mySet.workMinutes.toDouble();
      // 休憩時間が範囲外の場合は補正
      _breakMinutes = _validateBreakMinutes(mySet.breakMinutes.toDouble());
      _sets = mySet.sets;
      _isCustom = false;
    });
    
    _saveSettings();
  }

  /// 設定が手動で変更された
  void _onManualChange() {
    setState(() {
      _isCustom = true;
      _selectedMySet = null;
    });
    _saveSettings();
  }

  /// マイセットを編集
  Future<void> _editMySet() async {
    if (_selectedMySet == null) return;
    
    final result = await showDialog<MySet>(
      context: context,
      builder: (context) => MySetDialog(editingSet: _selectedMySet),
    );

    if (result != null) {
      try {
        // 既存のセットを削除して新しいセットを追加
        await _storage.deleteMySet(_selectedMySet!.id);
        await _storage.addMySet(result);
        
        // マイセット一覧を再読み込み
        final mySets = await _storage.getMySets();
        
        setState(() {
          _mySets = mySets;
          _selectedMySet = result;
          _workMinutes = result.workMinutes.toDouble();
          // 休憩時間が範囲外の場合は補正
          _breakMinutes = _validateBreakMinutes(result.breakMinutes.toDouble());
          _sets = result.sets;
          _isCustom = false;
        });
        
        _saveSettings();
        
        if (mounted) {
          final colors = context.colors;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '「${result.name}」を更新しました',
                style: TextStyle(color: colors.textPrimary),
              ),
              backgroundColor: colors.surface,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          final colors = context.colors;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '更新に失敗しました: $e',
                style: TextStyle(color: colors.textPrimary),
              ),
              backgroundColor: colors.error,
            ),
          );
        }
      }
    }
  }

  /// 現在の設定を新しいマイセットとして保存
  Future<void> _saveAsNewMySet() async {
    if (_mySets.length >= 5) {
      final colors = context.colors;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'マイセットは最大5つまでです',
            style: TextStyle(color: colors.textPrimary),
          ),
          backgroundColor: colors.warning,
        ),
      );
      return;
    }

    final result = await showDialog<MySet>(
      context: context,
      builder: (context) => MySetDialog(
        editingSet: MySet(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: '',
          workMinutes: _workMinutes.toInt(),
          breakMinutes: _breakMinutes.toInt(),
          sets: _sets,
        ),
      ),
    );

    if (result != null) {
      try {
        await _storage.addMySet(result);
        
        // マイセット一覧を再読み込み
        final mySets = await _storage.getMySets();
        
        setState(() {
          _mySets = mySets;
          _selectedMySet = result;
          _isCustom = false;
        });
        
        if (mounted) {
          final colors = context.colors;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '「${result.name}」を保存しました',
                style: TextStyle(color: colors.textPrimary),
              ),
              backgroundColor: colors.surface,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          final colors = context.colors;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '保存に失敗しました: $e',
                style: TextStyle(color: colors.textPrimary),
              ),
              backgroundColor: colors.error,
            ),
          );
        }
      }
    }
  }

  void _startTimer() {
    // 開始時に設定を保存
    _saveSettings();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FocusScreen(
          workMinutes: _workMinutes.toInt(),
          breakSeconds: (_breakMinutes * 60).toInt(), // 秒数で渡す
          totalSets: _sets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: colors.accent,
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // タイトル
            Text(
              '集中モードを開始',
              style: textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 30),
            
            // マイセット選択
            _buildMySetSelector(),
            
            const SizedBox(height: 20),
            
            // 作業時間設定
            _buildTimeSection(
              title: '作業時間',
              value: _workMinutes,
              min: AppConstants.minWorkMinutes.toDouble(),
              max: AppConstants.maxWorkMinutes.toDouble(),
              onChanged: (value) {
                setState(() {
                  _workMinutes = value;
                });
                _onManualChange();
              },
            ),
            
            const SizedBox(height: 20),
            
            // 休憩時間設定
            _buildTimeSection(
              title: '休憩時間',
              value: _breakMinutes,
              min: AppConstants.minBreakMinutes,
              max: AppConstants.maxBreakMinutes,
              onChanged: (value) {
                setState(() {
                  _breakMinutes = value;
                });
                _onManualChange();
              },
            ),
            
            const SizedBox(height: 20),
            
            // セット数設定
            _buildSetSection(),
            
            const SizedBox(height: 20),
            
            // カスタム設定時の保存ボタン
            if (_isCustom && _mySets.length < 5)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: OutlinedButton.icon(
                  onPressed: _saveAsNewMySet,
                  icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                  label: const Text('現在の設定を保存'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.accent,
                    side: BorderSide(
                      color: colors.accent,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            
            // 開始ボタン
            _buildStartButton(),
            
            const SizedBox(height: 20),
            
            // ステータス表示
            _buildStatusDisplay(),
          ],
        ),
      ),
    );
  }

  // マイセット選択セクション
  Widget _buildMySetSelector() {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: colors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bookmark_outlined,
                color: colors.accent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'マイセット',
                style: textTheme.labelLarge?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              // ドロップダウン
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isCustom
                          ? colors.textSecondary.withOpacity(0.3)
                          : colors.accent.withOpacity(0.5),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _isCustom ? 'custom' : _selectedMySet?.id,
                      isExpanded: true,
                      dropdownColor: colors.surface,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: colors.textSecondary,
                      ),
                      items: [
                        ..._mySets.map((mySet) {
                          return DropdownMenuItem<String>(
                            value: mySet.id,
                            child: Text(
                              mySet.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                        DropdownMenuItem<String>(
                          value: 'custom',
                          child: Text(
                            'カスタム',
                            style: TextStyle(
                              color: colors.textTertiary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == 'custom') {
                          setState(() {
                            _isCustom = true;
                            _selectedMySet = null;
                          });
                        } else {
                          final mySet = _mySets.firstWhere((s) => s.id == value);
                          _selectMySet(mySet);
                        }
                      },
                    ),
                  ),
                ),
              ),
              
              // 編集ボタン（マイセット選択時のみ）
              if (!_isCustom && _selectedMySet != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _editMySet,
                  icon: const Icon(Icons.edit_outlined),
                  color: colors.accent,
                  tooltip: '編集',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 時間設定セクション
  Widget _buildTimeSection({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    
    // 休憩時間かどうかを判定
    final isBreakTime = title == '休憩時間';
    
    // 分割数を計算（休憩時間は30秒刻み、それ以外は5分刻み）
    final divisions = isBreakTime 
        ? ((max - min) / 0.5).toInt() // 30秒刻み
        : ((max - min) / 5).toInt();    // 5分刻み
    
    // 表示用のテキストを生成
    String getTimeText(double minutes) {
      if (isBreakTime && minutes < 1.0) {
        // 1分未満の場合は秒で表示
        return '${(minutes * 60).toInt()}秒';
      } else if (isBreakTime && minutes % 1 != 0) {
        // 小数点以下がある場合（例：1.5分）
        final mins = minutes.toInt();
        final secs = ((minutes - mins) * 60).toInt();
        return '${mins}分${secs}秒';
      } else {
        return '${value.toInt()}分';
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: colors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textTheme.headlineSmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  getTimeText(value),
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBreakTime && min < 1.0 ? '${(min * 60).toInt()}秒' : '${min.toInt()}分',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              Text(
                '${max.toInt()}分',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // セット数設定セクション
  Widget _buildSetSection() {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: colors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'セット数',
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
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
                        _onManualChange();
                      }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: colors.accent,
                iconSize: 36,
              ),
              
              const SizedBox(width: 20),
              
              // セット数表示
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: colors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.accent,
                    width: 2,
                  ),
                ),
                child: Text(
                  '$_sets',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colors.accent,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // プラスボタン
              IconButton(
                onPressed: _sets < AppConstants.maxSets
                    ? () {
                        setState(() {
                          _sets++;
                        });
                        _onManualChange();
                      }
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: colors.accent,
                iconSize: 36,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'セット',
              style: textTheme.labelMedium?.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 開始ボタン
  Widget _buildStartButton() {
    final colors = context.colors;
    final gradients = context.gradients;
    
    return Container(
      height: AppConstants.buttonHeight,
      decoration: BoxDecoration(
        gradient: gradients.button,
        borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          onTap: _startTimer,
          child: Center(
            child: Text(
              '開始する',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ステータス表示
  Widget _buildStatusDisplay() {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    
    final totalMinutes = (_workMinutes + _breakMinutes) * _sets;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    // 休憩時間の表示テキストを生成
    String getBreakTimeText() {
      if (_breakMinutes < 1.0) {
        return '${(_breakMinutes * 60).toInt()}秒';
      } else if (_breakMinutes % 1 != 0) {
        final mins = _breakMinutes.toInt();
        final secs = ((_breakMinutes - mins) * 60).toInt();
        return '${mins}分${secs}秒';
      } else {
        return '${_breakMinutes.toInt()}分';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: colors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '合計時間',
            style: textTheme.labelMedium?.copyWith(
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hours > 0 ? '${hours}時間 ${minutes.toInt()}分' : '${minutes.toInt()}分',
            style: textTheme.titleLarge?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusItem('作業', '${_workMinutes.toInt()}分', colors, textTheme),
              Container(
                height: 30,
                width: 1,
                color: colors.divider,
              ),
              _buildStatusItem('休憩', getBreakTimeText(), colors, textTheme),
              Container(
                height: 30,
                width: 1,
                color: colors.divider,
              ),
              _buildStatusItem('セット', '$_setsセット', colors, textTheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    String label, 
    String value, 
    AppThemeColors colors, 
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.labelLarge?.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
