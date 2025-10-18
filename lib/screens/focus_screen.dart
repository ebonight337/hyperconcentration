import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/constants.dart';
import '../utils/motivational_messages.dart';
import '../widgets/ripple_effect.dart';

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

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin {
  late int _remainingSeconds;
  late int _currentSet;
  late bool _isWorkTime;
  Timer? _timer;
  
  // 波紋エフェクト用
  final List<RippleController> _ripples = [];
  
  // ランダムメッセージ
  late String _currentMessage;

  @override
  void initState() {
    super.initState();
    _currentSet = 1;
    _isWorkTime = true;
    _remainingSeconds = widget.workMinutes * 60;
    _currentMessage = MotivationalMessages.getRandomMessage();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _handleTimerComplete();
        }
      });
    });
  }

  void _handleTimerComplete() {
    if (_isWorkTime) {
      // 作業時間終了
      if (widget.breakMinutes == 0) {
        // 休憩時間が0分の場合は休憩をスキップ
        if (_currentSet < widget.totalSets) {
          // 次のセットへ
          setState(() {
            _currentSet++;
            _remainingSeconds = widget.workMinutes * 60;
            _currentMessage = MotivationalMessages.getRandomMessage();
          });
        } else {
          // 全セット完了
          _timer?.cancel();
          _showCompletionDialog();
        }
      } else {
        // 休憩時間へ
        setState(() {
          _isWorkTime = false;
          _remainingSeconds = widget.breakMinutes * 60;
          _currentMessage = MotivationalMessages.getRandomBreakMessage();
        });
      }
    } else {
      // 休憩時間終了
      if (_currentSet < widget.totalSets) {
        // 次のセットへ
        setState(() {
          _currentSet++;
          _isWorkTime = true;
          _remainingSeconds = widget.workMinutes * 60;
          _currentMessage = MotivationalMessages.getRandomMessage();
        });
      } else {
        // 全セット完了
        _timer?.cancel();
        _showCompletionDialog();
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        title: const Text(
          'お疲れさまでした',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Text(
          '全セット完了です。\n${MotivationalMessages.getRandomCompletionMessage()}',
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
          '途中停止すると連続達成日数がリセットされます。',
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
              Navigator.of(context).pop();
              Navigator.of(context).pop();
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

  @override
  void dispose() {
    _timer?.cancel();
    for (var ripple in _ripples) {
      ripple.controller.dispose();
    }
    super.dispose();
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
