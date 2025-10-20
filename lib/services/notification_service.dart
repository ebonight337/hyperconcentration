import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// 通知サービス
class NotificationService {
  static final NotificationService instance = NotificationService._init();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;

  NotificationService._init();

  /// 通知サービスを初期化
  Future<void> init() async {
    if (_isInitialized) return;

    // Android設定
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS設定
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      // Android 13以降では通知権限のリクエストが必要
      await _requestPermissions();
      
      _isInitialized = true;
      debugPrint('通知サービスの初期化完了');
    } catch (e) {
      debugPrint('通知サービスの初期化エラー: $e');
    }
  }

  /// 通知権限をリクエスト
  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// 通知がタップされた時の処理
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('通知がタップされました: ${response.payload}');
    // 必要に応じてアプリ内の特定画面に遷移する処理を追加
  }

  /// 作業時間終了の通知
  Future<void> showWorkCompleteNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'focus_timer',
      '集中タイマー',
      channelDescription: '集中タイマーの通知',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '作業時間終了',
      'お疲れさまでした。休憩しましょう。',
      details,
    );
  }

  /// 休憩時間終了の通知
  Future<void> showBreakCompleteNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'focus_timer',
      '集中タイマー',
      channelDescription: '集中タイマーの通知',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      '休憩時間終了',
      '次のセッションを始めましょう。',
      details,
    );
  }

  /// 全セット完了の通知
  Future<void> showAllSetsCompleteNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'focus_timer',
      '集中タイマー',
      channelDescription: '集中タイマーの通知',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2,
      '全セット完了',
      'お疲れさまでした！全セット完了です。',
      details,
    );
  }

  /// バックグラウンド時の定期通知
  Future<void> showBackgroundReminderNotification(int remainingMinutes) async {
    const androidDetails = AndroidNotificationDetails(
      'focus_reminder',
      '集中リマインダー',
      channelDescription: 'バックグラウンド時のリマインダー通知',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ongoing: true, // 通知を消せないようにする
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      3,
      '集中モード中です',
      'まだ集中時間中です！残り${remainingMinutes}分',
      details,
    );
  }

  /// 通知をキャンセル
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// すべての通知をキャンセル
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
