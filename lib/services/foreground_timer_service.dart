import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Foreground Serviceでタイマーを管理するサービス
class ForegroundTimerService {
  static final ForegroundTimerService instance = ForegroundTimerService._init();

  ForegroundTimerService._init();

  /// Foreground Serviceを初期化
  Future<void> init() async {
    // Foreground Taskの設定
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'focus_timer_foreground_v2',
        channelName: '集中タイマー（実行中）',
        channelDescription: '集中モード実行中の通知',
        channelImportance: NotificationChannelImportance.DEFAULT,
        priority: NotificationPriority.DEFAULT,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000), // 1秒ごとに実行
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  /// Foreground Serviceを開始
  Future<bool> startService({
    required int workSeconds,
    required int breakSeconds,
    required int currentSet,
    required int totalSets,
    required bool isWorkTime,
  }) async {
    debugPrint('🚀 startService呼び出し');

    // タスクデータを保存
    final timerData = {
      'workSeconds': workSeconds,
      'breakSeconds': breakSeconds,
      'currentSet': currentSet,
      'totalSets': totalSets,
      'isWorkTime': isWorkTime,
      'remainingSeconds': isWorkTime ? workSeconds : breakSeconds,
      'phaseEndTime': DateTime.now()
          .add(Duration(seconds: isWorkTime ? workSeconds : breakSeconds))
          .millisecondsSinceEpoch,
      'lastBackgroundNotificationTime': 0,
    };

    debugPrint('💾 データ保存: $timerData');
    await FlutterForegroundTask.saveData(
      key: 'timerData',
      value: jsonEncode(timerData),
    );

    // Foreground Serviceを開始
    debugPrint('🚀 Foreground Service開始呼び出し...');
    final result = await FlutterForegroundTask.startService(
      notificationTitle: '集中モード実行中',
      notificationText: _getNotificationText(
        isWorkTime: isWorkTime,
        currentSet: currentSet,
        totalSets: totalSets,
        remainingSeconds: isWorkTime ? workSeconds : breakSeconds,
      ),
      callback: startCallback,
    );

    debugPrint('📡 startService結果: $result');
    return result != null;
  }

  /// Foreground Serviceを停止
  Future<bool> stopService() async {
    final result = await FlutterForegroundTask.stopService();
    return result == true;
  }

  /// サービスが実行中かチェック
  Future<bool> isRunning() async {
    return await FlutterForegroundTask.isRunningService;
  }

  /// 通知テキストを生成
  static String _getNotificationText({
    required bool isWorkTime,
    required int currentSet,
    required int totalSets,
    required int remainingSeconds,
  }) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final status = isWorkTime ? '作業中' : '休憩中';
    return '$status (セット$currentSet/$totalSets) - 残り$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Foreground Taskのコールバック（isolateで実行される）
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(FocusTimerTaskHandler());
}

/// Foreground Taskのハンドラー
class FocusTimerTaskHandler extends TaskHandler {
  int _remainingSeconds = 0;
  int _workSeconds = 0;
  int _breakSeconds = 0;
  int _currentSet = 0;
  int _totalSets = 0;
  bool _isWorkTime = true;
  DateTime? _phaseEndTime;
  int _lastBackgroundNotificationTime = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('🚀 Foreground Task開始 (starter: ${starter.name})');

    // データが保存されるまで少し待つ
    await Future.delayed(const Duration(milliseconds: 500));

    // 最初のデータを読み込む
    await _handleTimerTick();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // エラーハンドリング付きで実行
    _handleTimerTick().catchError((error) {
      debugPrint('❌ onRepeatEventエラー: $error');
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    debugPrint('🛑 Foreground Task終了');
  }

  /// タイマーのティック処理
  Future<void> _handleTimerTick() async {
    try {
      // データを取得（リトライ付き）
      Map<String, dynamic>? data;
      for (int i = 0; i < 5; i++) {
        final String? dataStr = await FlutterForegroundTask.getData<String>(
          key: 'timerData',
        );
        if (dataStr != null && dataStr.isNotEmpty) {
          try {
            data = jsonDecode(dataStr) as Map<String, dynamic>;
            debugPrint('✅ データ取得完了 (試行${i + 1}/5)');
            break;
          } catch (e) {
            debugPrint('❌ JSONデコードエラー: $e');
          }
        }
        debugPrint('⚠️ データがnullまたは空 - リトライ ${i + 1}/5');
        await Future.delayed(const Duration(milliseconds: 200));
      }

      if (data == null) {
        debugPrint('❌ データが取得できませんでした（5回リトライ後）');
        return;
      }

      // 初回またはデータが変更された場合に更新
      if (_phaseEndTime == null ||
          data['phaseEndTime'] != _phaseEndTime?.millisecondsSinceEpoch) {
        _workSeconds = data['workSeconds'] ?? 0;
        _breakSeconds = data['breakSeconds'] ?? 0;
        _currentSet = data['currentSet'] ?? 1;
        _totalSets = data['totalSets'] ?? 1;
        _isWorkTime = data['isWorkTime'] ?? true;
        _phaseEndTime = DateTime.fromMillisecondsSinceEpoch(
          data['phaseEndTime'] ?? DateTime.now().millisecondsSinceEpoch,
        );
        _lastBackgroundNotificationTime =
            data['lastBackgroundNotificationTime'] ?? 0;
        debugPrint(
          '🔄 フェーズ情報更新: セット$_currentSet/$_totalSets, ${_isWorkTime ? "作業" : "休憩"}',
        );
      }

      // 現在時刻と終了予定時刻の差分で残り時間を計算
      final now = DateTime.now();
      final remaining = _phaseEndTime!.difference(now).inSeconds;

      if (remaining > 0) {
        _remainingSeconds = remaining;

        // 通知を更新
        await FlutterForegroundTask.updateService(
          notificationTitle: '集中モード実行中',
          notificationText: ForegroundTimerService._getNotificationText(
            isWorkTime: _isWorkTime,
            currentSet: _currentSet,
            totalSets: _totalSets,
            remainingSeconds: _remainingSeconds,
          ),
        );

        // ✅ UIにデータを送信（これが重要！）
        FlutterForegroundTask.sendDataToMain({
          'type': 'update',
          'remainingSeconds': _remainingSeconds,
          'isWorkTime': _isWorkTime,
          'currentSet': _currentSet,
        });

        // バックグラウンド通知（1分ごと）
        final currentMinute = now.millisecondsSinceEpoch ~/ 60000;
        if (_lastBackgroundNotificationTime != currentMinute) {
          _lastBackgroundNotificationTime = currentMinute;

          // データを更新
          final updatedData = Map<String, dynamic>.from(data);
          updatedData['lastBackgroundNotificationTime'] =
              _lastBackgroundNotificationTime;
          await FlutterForegroundTask.saveData(
            key: 'timerData',
            value: jsonEncode(updatedData),
          );

          debugPrint('🔔 1分経過 - バックグラウンド通知');
        }
      } else {
        // タイマー完了
        debugPrint('⏰ タイマー完了!');
        await _handleTimerComplete();
      }
    } catch (e) {
      debugPrint('❌ Foreground Task エラー: $e');
    }
  }

  /// タイマー完了時の処理
  Future<void> _handleTimerComplete() async {
    if (_isWorkTime) {
      // 作業時間終了
      debugPrint('✅ 作業時間終了');

      if (_breakSeconds == 0) {
        // 休憩時間が0分の場合はスキップ
        if (_currentSet < _totalSets) {
          // 次のセットへ
          await _moveToNextPhase(
            isWork: true,
            duration: _workSeconds,
            incrementSet: true,
          );

          FlutterForegroundTask.sendDataToMain({
            'event': 'nextSet',
            'currentSet': _currentSet,
            'isWorkTime': _isWorkTime,
            'remainingSeconds': _remainingSeconds,
          });
        } else {
          // 全セット完了
          FlutterForegroundTask.sendDataToMain({'event': 'allComplete'});
          await FlutterForegroundTask.stopService();
        }
      } else {
        // 休憩時間へ
        await _moveToNextPhase(
          isWork: false,
          duration: _breakSeconds,
          incrementSet: false,
        );

        FlutterForegroundTask.sendDataToMain({
          'type': 'update',
          'event': 'breakStart',
          'isWorkTime': _isWorkTime,
          'remainingSeconds': _remainingSeconds,
          'currentSet': _currentSet,
        });
      }
    } else {
      // 休憩時間終了
      debugPrint('✅ 休憩時間終了');

      if (_currentSet < _totalSets) {
        // 次のセットへ
        await _moveToNextPhase(
          isWork: true,
          duration: _workSeconds,
          incrementSet: true,
        );

        FlutterForegroundTask.sendDataToMain({
          'type': 'update',
          'event': 'nextSet',
          'currentSet': _currentSet,
          'isWorkTime': _isWorkTime,
          'remainingSeconds': _remainingSeconds,
        });
      } else {
        // 全セット完了
        FlutterForegroundTask.sendDataToMain({'event': 'allComplete'});
        await FlutterForegroundTask.stopService();
      }
    }
  }

  /// 次のフェーズに移行
  Future<void> _moveToNextPhase({
    required bool isWork,
    required int duration,
    required bool incrementSet,
  }) async {
    _isWorkTime = isWork;
    if (incrementSet) {
      _currentSet++;
    }
    _phaseEndTime = DateTime.now().add(Duration(seconds: duration));
    _remainingSeconds = duration;

    // データを更新
    await FlutterForegroundTask.saveData(
      key: 'timerData',
      value: jsonEncode({
        'workSeconds': _workSeconds,
        'breakSeconds': _breakSeconds,
        'currentSet': _currentSet,
        'totalSets': _totalSets,
        'isWorkTime': _isWorkTime,
        'remainingSeconds': _remainingSeconds,
        'phaseEndTime': _phaseEndTime!.millisecondsSinceEpoch,
        'lastBackgroundNotificationTime': _lastBackgroundNotificationTime,
      }),
    );

    // 通知を更新
    await FlutterForegroundTask.updateService(
      notificationTitle: '集中モード実行中',
      notificationText: ForegroundTimerService._getNotificationText(
        isWorkTime: _isWorkTime,
        currentSet: _currentSet,
        totalSets: _totalSets,
        remainingSeconds: _remainingSeconds,
      ),
    );
  }
}
