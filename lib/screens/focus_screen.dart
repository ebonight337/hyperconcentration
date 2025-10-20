import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/constants.dart';
import '../utils/motivational_messages.dart';
import '../widgets/ripple_effect.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/focus_session.dart';

class FocusScreen extends StatefulWidget {
  final int workMinutes;
  final int breakMinutes;
  final int totalSets;

  const FocusScreen({
    super.key,
    required this.workMinutes,
    required this.breakMinutes,
    required this.totalSets,
  });

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late int _remainingSeconds;
  late int _currentSet;
  late bool _isWorkTime;
  Timer? _timer;
  Timer? _backgroundNotificationTimer;
  
  // バックグラウンド対応：終了予定時刻
  late DateTime _currentPhaseEndTime;
  
  // バックグラウンド検知用
  DateTime? _backgroundStartTime;
  int _totalBackgroundSeconds = 0;
  
  // セッション記録用
  late DateTime _sessionStartTime;
  int _completedWorkSets = 0; // 完了した作業セット数
  final StorageService _storage = StorageService.instance;
  final NotificationService _notificationService = NotificationService.instance;
  
  // 波紋エフェクト用
  final List<RippleController> _ripples = [];
  
  // ランダムメッセージ
  late String _currentMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _sessionStartTime = DateTime.now();
    _currentSet = 1;
    _isWorkTime = true;
    _currentMessage = MotivationalMessages.getRandomMessage();
    
    // 初期フェーズの終了予定時刻を設定
    _currentPhaseEndTime = DateTime.now().add(Duration(minutes: widget.workMinutes));
    _remainingSeconds = widget.workMinutes * 60;
    
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _backgroundNotificationTimer?.cancel();
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
    
    // バックグラウンド時の定期通知を開始（1分ごと）
    _startBackgroundNotifications();
    
    debugPrint('バックグラウンドに移行: ${_backgroundStartTime}');
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
    
    // バックグラウンド通知を停止
    _stopBackgroundNotifications();
    _notificationService.cancelAllNotifications();
  }

  /// バックグラウンド時間を表示
  void _showBackgroundTimeMessage(int seconds) {
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
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: AppConstants.surfaceColor,
      ),
    );
  }

  /// バックグラウンド時の定期通知を開始
  void _startBackgroundNotifications() {
    _backgroundNotificationTimer?.cancel();
    
    // 1分ごとに通知を送信
    _backgroundNotificationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final remainingMinutes = (_remainingSeconds / 60).ceil();
      _notificationService.showBackgroundReminderNotification(remainingMinutes);
    });
    
    // 最初の通知をすぐに送信
    final remainingMinutes = (_remainingSeconds / 60).ceil();
    _notificationService.showBackgroundReminderNotification(remainingMinutes);
  }

  /// バックグラウンド通知を停止
  void _stopBackgroundNotifications() {
    _backgroundNotificationTimer?.cancel();
    _backgroundNotificationTimer = null;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // 終了予定時刻との差分で残り時間を計算（バックグラウンド対応）
        final now = DateTime.now();
        final remaining = _currentPhaseEndTime.difference(now).inSeconds;
        
        if (remaining > 0) {
          _remainingSeconds = remaining;
        } else {
          // 時間切れ
          _remainingSeconds = 0;
          _handleTimerComplete();
        }
      });
    });
  }

  void _handleTimerComplete() {
    if (_isWorkTime) {
      // 作業時間終了 - 完了セット数をカウント
      _completedWorkSets++;
      
      // 通知を送信
      _notificationService.showWorkCompleteNotification();
      
      if (widget.breakMinutes == 0) {
        // 休憩時間が0分の場合は休憩をスキップ
        if (_currentSet < widget.totalSets) {
          // 次のセットへ
          _setNextPhase(
            isWork: true,
            duration: widget.workMinutes,
            message: MotivationalMessages.getRandomMessage(),
          );
          setState(() {
            _currentSet++;
          });
        } else {
          // 全セット完了
          _timer?.cancel();
          _notificationService.showAllSetsCompleteNotification();
          _saveSessionAndShowCompletion(wasInterrupted: false);
        }
      } else {
        // 休憩時間へ
        _setNextPhase(
          isWork: false,
          duration: widget.breakMinutes,
          message: MotivationalMessages.getRandomBreakMessage(),
        );
      }
    } else {
      // 休憩時間終了
      _notificationService.showBreakCompleteNotification();
      
      if (_currentSet < widget.totalSets) {
        // 次のセットへ
        _setNextPhase(
          isWork: true,
          duration: widget.workMinutes,
          message: MotivationalMessages.getRandomMessage(),
        );
        setState(() {
          _currentSet++;
        });
      } else {
        // 全セット完了
        _timer?.cancel();
        _notificationService.showAllSetsCompleteNotification();
        _saveSessionAndShowCompletion(wasInterrupted: false);
      }
    }
  }

  /// 次のフェーズに移行（終了予定時刻を更新）
  void _setNextPhase({
    required bool isWork,
    required int duration,
    required String message,
  }) {
    setState(() {
      _isWorkTime = isWork;
      _currentMessage = message;
      // 新しい終了予定時刻を設定
      _currentPhaseEndTime = DateTime.now().add(Duration(minutes: duration));
      _remainingSeconds = duration * 60;
    });
  }

  /// セッションを保存して完了ダイアログを表示
  Future<void> _saveSessionAndShowCompletion({required bool wasInterrupted}) async {
    // 集中時間を計算（作業時間のみ）
    final totalFocusMinutes = _completedWorkSets * widget.workMinutes;
    
    // セッションデータを作成
    final session = FocusSession(
      date: _sessionStartTime,
      workMinutes: widget.workMinutes,
      breakMinutes: widget.breakMinutes,
      completedSets: _completedWorkSets,
      totalSets: widget.totalSets,
      totalFocusMinutes: totalFocusMinutes,
      wasInterrupted: wasInterrupted,
    );

    try {
      // データを保存
      await _storage.saveSession(session);
      
      // デバッグ：バックグラウンド時間を記録
      if (_totalBackgroundSeconds > 0) {
        debugPrint('総バックグラウンド時間: ${_totalBackgroundSeconds}秒');
      }
    } catch (e) {
      // エラーがあっても続行（ダイアログは表示する）
      debugPrint('セッション保存エラー: $e');
    }

    // 完了ダイアログを表示
    if (mounted) {
      _showCompletionDialog(wasInterrupted: wasInterrupted);
    }
  }

  void _showCompletionDialog({required bool wasInterrupted}) {
    final message = wasInterrupted
        ? '途中で停止しました。\n完了したセット: $_completedWorkSets / ${widget.totalSets}'
        : '全セット完了です。\n${MotivationalMessages.getRandomCompletionMessage()}';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        title: Text(
          wasInterrupted ? '停止しました' : 'お疲れさまでした',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        title: const Text(
          '⚠️ 本当に停止しますか？',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '途中停止しても、同じ日に再度達成すれば連続は継続します。',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('戻る'),
          ),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              _stopBackgroundNotifications();
              _notificationService.cancelAllNotifications();
              Navigator.of(context).pop(); // ダイアログを閉じる
              // 途中停止として記録
              _saveSessionAndShowCompletion(wasInterrupted: true);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
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
    return Scaffold(
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
                    decoration: const BoxDecoration(
                      gradient: AppConstants.oceanGradient,
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
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 2,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // セット数表示
                  Text(
                    'セット $_currentSet / ${widget.totalSets}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.7),
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
                          style: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                            shadows: [
                              Shadow(
                                color: AppConstants.accentColor,
                                blurRadius: 30,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '残り時間',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.6),
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
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
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
                        foregroundColor: Colors.white.withOpacity(0.7),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
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
    );
  }
}
