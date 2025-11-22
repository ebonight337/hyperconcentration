import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'dart:async';
import '../utils/app_theme.dart';
import '../utils/motivational_messages.dart';
import '../widgets/ripple_effect.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/achievement_service.dart';
import '../services/foreground_timer_service.dart';
import '../models/focus_session.dart';
import '../models/achievement.dart';

class FocusScreen extends StatefulWidget {
  final int workMinutes;
  final int breakSeconds; // 休憩時間は秒数で受け取る
  final int totalSets;

  const FocusScreen({
    super.key,
    required this.workMinutes,
    required this.breakSeconds,
    required this.totalSets,
  });

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late int _remainingSeconds;
  late int _currentSet;
  late bool _isWorkTime;
  
  // バックグラウンド検知用
  DateTime? _backgroundStartTime;
  int _totalBackgroundSeconds = 0;
  
  // セッション記録用
  late DateTime _sessionStartTime;
  int _completedWorkSets = 0;
  final StorageService _storage = StorageService.instance;
  final NotificationService _notificationService = NotificationService.instance;
  final AchievementService _achievementService = AchievementService();
  final ForegroundTimerService _foregroundTimerService = ForegroundTimerService.instance;
  
  // 波紋エフェクト用
  final List<RippleController> _ripples = [];
  
  // ランダムメッセージ
  late String _currentMessage;
  
  // 完了時のループ通知用
  Timer? _completionNotificationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _sessionStartTime = DateTime.now();
    _currentSet = 1;
    _isWorkTime = true;
    _currentMessage = MotivationalMessages.getRandomMessage();
    _remainingSeconds = widget.workMinutes * 60;
    
    // Foreground Taskからのデータを受け取るコールバックを登録
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    
    _initForegroundService();
  }
  
  /// Foreground Taskからのデータを受信
  void _onReceiveTaskData(dynamic data) {
    debugPrint('✅ Foreground Taskからデータ受信: $data');
    if (data is Map) {
      _handleForegroundMessage(data);
    }
  }

  /// Foreground Serviceを初期化して開始
  Future<void> _initForegroundService() async {
    // Foreground Taskの初期化
    await _foregroundTimerService.init();
    
    // Foreground Serviceを開始
    final started = await _foregroundTimerService.startService(
      workSeconds: widget.workMinutes * 60,
      breakSeconds: widget.breakSeconds, // すでに秒数
      currentSet: _currentSet,
      totalSets: widget.totalSets,
      isWorkTime: _isWorkTime,
    );
    
    if (!started) {
      debugPrint('❌ Foreground Service開始失敗');
      if (mounted) {
        final colors = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('バックグラウンド動作の開始に失敗しました'),
            backgroundColor: colors.error,
          ),
        );
      }
    } else {
      debugPrint('✅ Foreground Service開始成功');
      // WithForegroundTaskを使うので、ここではlistenしない
    }
  }

  /// Foreground Serviceをクリーンアップ
  Future<void> _cleanupForegroundService() async {
    await _foregroundTimerService.stopService();
  }

  /// Foreground Serviceからのメッセージを処理
  void _handleForegroundMessage(Map message) {
    if (!mounted) {
      debugPrint('⚠️ mountedではないためスキップ');
      return;
    }

    debugPrint('📨 メッセージ処理開始: $message');

    setState(() {
      // 残り時間を更新
      if (message.containsKey('remainingSeconds')) {
        final oldSeconds = _remainingSeconds;
        _remainingSeconds = message['remainingSeconds'];
        debugPrint('⏱️ 残り時間更新: $oldSeconds -> $_remainingSeconds');
      }
      
      // 作業/休憩状態を更新
      if (message.containsKey('isWorkTime')) {
        final wasWorkTime = _isWorkTime;
        _isWorkTime = message['isWorkTime'];
        
        // 状態が変わった場合、メッセージも更新
        if (wasWorkTime != _isWorkTime) {
          _currentMessage = _isWorkTime
              ? MotivationalMessages.getRandomMessage()
              : MotivationalMessages.getRandomBreakMessage();
          debugPrint('🔄 状態変更: ${wasWorkTime ? "作業" : "休憩"} -> ${_isWorkTime ? "作業" : "休憩"}');
        }
      }
      
      // セット数を更新
      if (message.containsKey('currentSet')) {
        final oldSet = _currentSet;
        _currentSet = message['currentSet'];
        if (oldSet != _currentSet) {
          debugPrint('🔢 セット更新: $oldSet -> $_currentSet');
        }
      }
    });

    // イベントを処理
    if (message.containsKey('event')) {
      final event = message['event'];
      debugPrint('🎉 イベント受信: $event');
      
      switch (event) {
        case 'nextSet':
          // 次のセットへ（休憩時間終了）
          _completedWorkSets++;
          _notificationService.showBreakCompleteNotification();
          break;
          
        case 'breakStart':
          // 休憩開始（作業時間終了）
          _notificationService.showWorkCompleteNotification();
          break;
          
        case 'allComplete':
          // 全セット完了
          _completedWorkSets++;
          _startCompletionNotificationLoop();
          _cleanupForegroundService();
          _saveSessionAndShowCompletion(wasInterrupted: false);
          break;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    // Foreground Taskのコールバックを解除
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    
    // 完了通知ループをキャンセル
    _completionNotificationTimer?.cancel();
    
    _cleanupForegroundService();
    _notificationService.cancelAllNotifications();
    
    for (var ripple in _ripples) {
      ripple.controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // バックグラウンドに移行
        _onAppBackgrounded();
        break;
      case AppLifecycleState.resumed:
        // フォアグラウンドに復帰
        _onAppResumed();
        break;
      default:
        break;
    }
  }

  /// アプリがバックグラウンドに移行した時
  void _onAppBackgrounded() {
    _backgroundStartTime = DateTime.now();
    debugPrint('バックグラウンドに移行: $_backgroundStartTime');
  }

  /// アプリがフォアグラウンドに復帰した時
  void _onAppResumed() {
    if (_backgroundStartTime != null) {
      final backgroundDuration = DateTime.now().difference(_backgroundStartTime!).inSeconds;
      _totalBackgroundSeconds += backgroundDuration;
      
      debugPrint('フォアグラウンドに復帰: ${backgroundDuration}秒間離れていました');
      
      // バックグラウンド時間を表示
      if (mounted && backgroundDuration > 5) {
        _showBackgroundTimeMessage(backgroundDuration);
      }
      
      _backgroundStartTime = null;
    }
    
    // 通知をクリア
    _notificationService.cancelAllNotifications();
  }

  /// バックグラウンド時間を表示
  void _showBackgroundTimeMessage(int seconds) {
    final colors = context.colors;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    String message;
    if (minutes > 0) {
      message = '${minutes}分${remainingSeconds}秒間離れていました';
    } else {
      message = '${remainingSeconds}秒間離れていました';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: colors.textPrimary),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: colors.surface,
      ),
    );
  }

  /// 完了通知のループを開始
  void _startCompletionNotificationLoop() {
    // 最初の通知をすぐに送信
    _notificationService.showAllSetsCompleteNotification();
    
    // 5秒ごとに通知をループ
    _completionNotificationTimer?.cancel();
    _completionNotificationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _notificationService.showAllSetsCompleteNotification();
        debugPrint('🔔 完了通知を再送信');
      },
    );
    
    debugPrint('🔁 完了通知ループ開始 (1秒ごと)');
  }
  
  /// 完了通知のループを停止
  void _stopCompletionNotificationLoop() {
    _completionNotificationTimer?.cancel();
    _completionNotificationTimer = null;
    _notificationService.cancelAllNotifications();
    debugPrint('⛔ 完了通知ループ停止');
  }

  /// セッションを保存して完了ダイアログを表示
  Future<void> _saveSessionAndShowCompletion({required bool wasInterrupted}) async {
    // 集中時間を計算（作業時間のみ）
    final totalFocusMinutes = _completedWorkSets * widget.workMinutes;
    
    // セッションデータを作成
    final session = FocusSession(
      date: _sessionStartTime,
      workMinutes: widget.workMinutes,
      breakMinutes: (widget.breakSeconds / 60).round(), // 秒数を分に変換
      completedSets: _completedWorkSets,
      totalSets: widget.totalSets,
      totalFocusMinutes: totalFocusMinutes,
      wasInterrupted: wasInterrupted,
    );

    List<Achievement> newAchievements = [];
    
    try {
      // データを保存
      await _storage.saveSession(session);
      
      // 実績判定（途中停止でない場合のみ）
      if (!wasInterrupted) {
        newAchievements = await _achievementService.checkAchievements(session);
      }
      
      // デバッグ：バックグラウンド時間を記録
      if (_totalBackgroundSeconds > 0) {
        debugPrint('総バックグラウンド時間: ${_totalBackgroundSeconds}秒');
      }
      
      // 新しい実績があればログ出力
      if (newAchievements.isNotEmpty) {
        debugPrint('🏆 新しい実績解除: ${newAchievements.map((a) => a.title).join(", ")}');
      }
    } catch (e) {
      // エラーがあっても続行（ダイアログは表示する）
      debugPrint('セッション保存エラー: $e');
    }

    // 完了ダイアログを表示
    if (mounted) {
      _showCompletionDialog(
        wasInterrupted: wasInterrupted,
        newAchievements: newAchievements,
      );
    }
  }

  void _showCompletionDialog({
    required bool wasInterrupted,
    List<Achievement> newAchievements = const [],
  }) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    
    final message = wasInterrupted
        ? '途中で停止しました。\n完了したセット: $_completedWorkSets / ${widget.totalSets}'
        : '全セット完了です。\n${MotivationalMessages.getRandomCompletionMessage()}';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          wasInterrupted ? '停止しました' : 'お疲れさまでした',
          style: textTheme.titleLarge?.copyWith(color: colors.textPrimary),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            // 新しい実績があれば表示
            if (newAchievements.isNotEmpty) ...[
              const SizedBox(height: 20),
              Divider(color: colors.divider),
              const SizedBox(height: 12),
              Text(
                '🏆 新しい実績を解除！',
                style: textTheme.titleMedium?.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ...newAchievements.map((achievement) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      achievement.title,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
            ]
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _stopCompletionNotificationLoop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showStopDialog() {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          '⚠️ 本当に停止しますか？',
          style: textTheme.titleLarge?.copyWith(color: colors.textPrimary),
        ),
        content: Text(
          '途中停止しても、同じ日に再度達成すれば連続は継続します。',
          style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('戻る'),
          ),
          TextButton(
            onPressed: () async {
              await _cleanupForegroundService();
              _notificationService.cancelAllNotifications();
              
              if (mounted) {
                Navigator.of(context).pop(); // ダイアログを閉じる
                // 途中停止として記録
                await _saveSessionAndShowCompletion(wasInterrupted: true);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: colors.error,
            ),
            child: const Text('停止する'),
          ),
        ],
      ),
    );
  }

  void _addRipple(Offset position) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _ripples.removeWhere((r) => r.controller == controller);
        });
        controller.dispose();
      }
    });

    setState(() {
      _ripples.add(RippleController(
        position: position,
        controller: controller,
      ));
    });
    
    controller.forward();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gradients = context.gradients;
    final textTheme = Theme.of(context).textTheme;
    
    // WithForegroundTaskでラップ（バージョン8.x系ではaddTaskDataCallbackでデータ受信）
    return WithForegroundTask(
      child: WillPopScope(
      onWillPop: () async {
        _showStopDialog();
        return false;
      },
      child: Scaffold(
        body: GestureDetector(
          onTapDown: (details) {
            _addRipple(details.localPosition);
          },
          child: Stack(
            children: [
              // 背景画像
              Positioned.fill(
                child: Image.asset(
                  'assets/images/backgrounds/ocean_background.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: gradients.background,
                      ),
                    );
                  },
                ),
              ),
              
              // 暗いオーバーレイ
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
              
              // 波紋エフェクト
              RippleEffect(ripples: _ripples),
              
              // コンテンツ
              Center(
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    const SizedBox(height: 60),
                    
                    // ステータス表示
                    Text(
                      _isWorkTime ? '作業中' : '休憩中',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        color: colors.textPrimary.withOpacity(0.9),
                        letterSpacing: 2,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // セット数表示
                    Text(
                      'セット $_currentSet / ${widget.totalSets}',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // タイマー表示
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Text(
                            _formatTime(_remainingSeconds),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: colors.accent,
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '残り時間',
                            textAlign: TextAlign.center,
                            style: textTheme.labelLarge?.copyWith(
                              color: colors.textTertiary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // 励ましメッセージ
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _currentMessage,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.textSecondary,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // 停止ボタン
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: OutlinedButton(
                        onPressed: _showStopDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textSecondary,
                          side: BorderSide(
                            color: colors.textSecondary.withOpacity(0.3),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          '停止',
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
