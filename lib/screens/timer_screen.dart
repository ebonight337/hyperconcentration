import 'package:flutter/material.dart';
import 'focus_screen.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';

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
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLastSettings();
  }

  /// 最後の設定を読み込む
  Future<void> _loadLastSettings() async {
    try {
      final settings = await _storage.getLastTimerSettings();
      setState(() {
        _workMinutes = settings['workMinutes']!.toDouble();
        _breakMinutes = settings['breakMinutes']!.toDouble();
        _sets = settings['sets']!;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 設定を保存
  Future<void> _saveSettings() async {
    await _storage.saveLastTimerSettings(
      workMinutes: _workMinutes.toInt(),
      breakMinutes: _breakMinutes.toInt(),
      sets: _sets,
    );
  }

  void _startTimer() {
    // 開始時に設定を保存
    _saveSettings();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FocusScreen(
          workMinutes: _workMinutes.toInt(),
          breakMinutes: _breakMinutes.toInt(),
          totalSets: _sets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppConstants.accentColor,
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
              style: AppConstants.titleStyle,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
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
                _saveSettings(); // 設定を保存
              },
            ),
            
            const SizedBox(height: 30),
            
            // 休憩時間設定
            _buildTimeSection(
              title: '休憩時間',
              value: _breakMinutes,
              min: AppConstants.minBreakMinutes.toDouble(),
              max: AppConstants.maxBreakMinutes.toDouble(),
              onChanged: (value) {
                setState(() {
                  _breakMinutes = value;
                });
                _saveSettings(); // 設定を保存
              },
            ),
            
            const SizedBox(height: 30),
            
            // セット数設定
            _buildSetSection(),
            
            const SizedBox(height: 50),
            
            // 開始ボタン
            _buildStartButton(),
            
            const SizedBox(height: 30),
            
            // ステータス表示
            _buildStatusDisplay(),
          ],
        ),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppConstants.sectionTitleStyle,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${value.toInt()}分',
                  style: AppConstants.valueStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppConstants.accentColor,
              inactiveTrackColor: AppConstants.primaryColor.withOpacity(0.3),
              thumbColor: AppConstants.accentColor,
              overlayColor: AppConstants.accentColor.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) / 5).toInt(),
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${min.toInt()}分',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              Text(
                '${max.toInt()}分',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'セット数',
            style: AppConstants.sectionTitleStyle,
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
                        _saveSettings(); // 設定を保存
                      }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppConstants.accentColor,
                iconSize: 36,
              ),
              
              const SizedBox(width: 20),
              
              // セット数表示
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppConstants.accentColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  '$_sets',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.accentColor,
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
                        _saveSettings(); // 設定を保存
                      }
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: AppConstants.accentColor,
                iconSize: 36,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'セット',
              style: AppConstants.labelStyle,
            ),
          ),
        ],
      ),
    );
  }

  // 開始ボタン
  Widget _buildStartButton() {
    return Container(
      height: AppConstants.buttonHeight,
      decoration: AppConstants.buttonDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          onTap: _startTimer,
          child: const Center(
            child: Text(
              '開始する',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
    final totalMinutes = (_workMinutes + _breakMinutes) * _sets;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '合計時間',
            style: AppConstants.labelStyle,
          ),
          const SizedBox(height: 8),
          Text(
            hours > 0 ? '${hours}時間 ${minutes.toInt()}分' : '${minutes.toInt()}分',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusItem('作業', '${_workMinutes.toInt()}分'),
              Container(
                height: 30,
                width: 1,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildStatusItem('休憩', '${_breakMinutes.toInt()}分'),
              Container(
                height: 30,
                width: 1,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildStatusItem('セット', '$_setsセット'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
