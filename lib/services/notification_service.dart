import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../utils/constants.dart';
import 'storage_service.dart';

/// 通知サービス
class NotificationService {
  static final NotificationService instance = NotificationService._init();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final StorageService _storage = StorageService.instance;
  
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
      
      // Android通知チャネルを明示的に作成
      await _createNotificationChannel();
      
      _isInitialized = true;
      debugPrint('通知サービスの初期化完了');
    } catch (e) {
      debugPrint('通知サービスの初期化エラー: $e');
    }
  }

  /// Android通知チャネルを明示的に作成
  Future<void> _createNotificationChannel() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin == null) return;

    // デフォルトの効果音を取得
    final defaultSound = AppConstants.notificationSounds.first;
    
    // 通知チャネルを作成
    final channel = AndroidNotificationChannel(
      'focus_timer_v3',
      '集中タイマー',
      description: '集中タイマーの通知',
      importance: Importance.max,
      playSound: true,
      sound: defaultSound.androidResourceName != null
          ? RawResourceAndroidNotificationSound(defaultSound.androidResourceName!)
          : null,
      enableVibration: true,
    );

    await androidPlugin.createNotificationChannel(channel);
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

  /// 選択された効果音の情報を取得
  Future<NotificationSoundOption?> _getSelectedSound() async {
    final soundId = await _storage.getNotificationSoundId();
    try {
      return AppConstants.notificationSounds.firstWhere(
        (sound) => sound.id == soundId,
      );
    } catch (e) {
      // 見つからない場合はデフォルトを返す
      debugPrint('⚠️ 音声が見つからずデフォルトを使用: $e');
      return AppConstants.notificationSounds.first;
    }
  }

  /// 通知の詳細設定を作成（選択された効果音を使用）
  Future<NotificationDetails> _createNotificationDetails({
    required Int64List vibrationPattern,
    String? customSoundId,
  }) async {
    // カスタム効果音IDが指定されていればそれを使用、なければ保存された設定を使用
    final soundOption = customSoundId != null
        ? AppConstants.notificationSounds.firstWhere(
            (sound) => sound.id == customSoundId,
            orElse: () => AppConstants.notificationSounds.first,
          )
        : await _getSelectedSound();

    final androidDetails = AndroidNotificationDetails(
      'focus_timer_v3', // チャネルIDを変更（音声設定を反映させるため）
      '集中タイマー',
      channelDescription: '集中タイマーの通知',
      importance: Importance.max, // maxに変更（音を確実に鳴らす）
      priority: Priority.max, // maxに変更
      playSound: !soundOption!.isVibrationOnly,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      sound: soundOption.isVibrationOnly || soundOption.androidResourceName == null
          ? null
          : RawResourceAndroidNotificationSound(soundOption.androidResourceName!),
      // 通知音を正しく再生させる（アラームとして扱う）
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: !soundOption.isVibrationOnly,
      sound: soundOption.isVibrationOnly || soundOption.iosFileName == null
          ? null
          : soundOption.iosFileName,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// 作業時間終了の通知
  /// バイブレーション: 長い振動1回（800ms）
  Future<void> showWorkCompleteNotification() async {
    final details = await _createNotificationDetails(
      vibrationPattern: Int64List.fromList([0, 800]), // 長い振動1回
    );

    await _notifications.show(
      0,
      '作業時間終了',
      'お疲れさまでした。休憩しましょう。',
      details,
    );
  }

  /// 休憩時間終了の通知
  /// バイブレーション: 短い振動2回（300ms, 200ms休止, 300ms）
  Future<void> showBreakCompleteNotification() async {
    final details = await _createNotificationDetails(
      vibrationPattern: Int64List.fromList([0, 300, 200, 300]), // 短い振動2回
    );

    await _notifications.show(
      1,
      '休憩時間終了',
      '次のセッションを始めましょう。',
      details,
    );
  }

  /// 全セット完了の通知
  /// バイブレーション: 短い振動3回（特別感）
  Future<void> showAllSetsCompleteNotification() async {
    final details = await _createNotificationDetails(
      vibrationPattern: Int64List.fromList([0, 200, 100, 200, 100, 200]), // 短い振動3回
    );

    await _notifications.show(
      2,
      '全セット完了🎉',
      'お疲れさまでした！全セット完了です。',
      details,
    );
  }

  /// バックグラウンド時の定期通知
  /// バイブレーション: 短い振動1回（500ms）
  Future<void> showBackgroundReminderNotification(int remainingMinutes) async {
    final details = await _createNotificationDetails(
      vibrationPattern: Int64List.fromList([0, 500]), // 短い振動1回
    );

    await _notifications.show(
      3,
      '集中モード中です',
      'まだ集中時間中です！残り${remainingMinutes}分',
      details,
    );
  }

  /// テスト通知を送信（設定画面用）
  Future<void> showTestNotification(String? soundId) async {
    final details = await _createNotificationDetails(
      vibrationPattern: Int64List.fromList([0, 500]), // 短い振動1回
      customSoundId: soundId,
    );

    await _notifications.show(
      999, // テスト用のID
      'テスト通知',
      '選択した効果音が再生されます',
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
