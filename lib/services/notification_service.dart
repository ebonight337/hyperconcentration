import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

import 'package:audioplayers/audioplayers.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

/// 通知サービス
class NotificationService {
  static final NotificationService instance = NotificationService._init();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final StorageService _storage = StorageService.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isInitialized = false;

  NotificationService._init();

  /// 通知サービスを初期化
  Future<void> init() async {
    if (_isInitialized) return;

    // Android設定
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

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

      // AudioPlayerの初期設定（アラームとして再生）
      await _audioPlayer.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.alarm, // アラームとして扱い、マナーモードを回避
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback, // マナーモードでも再生
            options: {
              AVAudioSessionOptions.duckOthers,
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ),
      );

      _isInitialized = true;
      debugPrint('通知サービスの初期化完了');
    } catch (e) {
      debugPrint('通知サービスの初期化エラー: $e');
    }
  }

  /// Android通知チャネルを明示的に作成
  Future<void> _createNotificationChannel() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    // 通知チャネルを作成
    // 音はaudioplayersで鳴らすため、通知チャネル自体の音はOFFにするかデフォルトにする
    // ここでは振動のみ有効にし、音は別途再生する方針
    const channel = AndroidNotificationChannel(
      'focus_timer_v3',
      '集中タイマー',
      description: '集中タイマーの通知',
      importance: Importance.max,
      playSound: false, // 通知自体の音は鳴らさない（audioplayersで鳴らすため）
      enableVibration: true,
    );

    await androidPlugin.createNotificationChannel(channel);
  }

  /// 通知権限をリクエスト
  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
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

  /// 効果音を再生（マナーモードでも鳴る）
  Future<void> _playSound(String? soundId) async {
    try {
      // 指定がない場合は設定から取得
      final soundOption = soundId != null
          ? AppConstants.notificationSounds.firstWhere(
              (sound) => sound.id == soundId,
              orElse: () => AppConstants.notificationSounds.first,
            )
          : await _getSelectedSound();

      if (soundOption == null || soundOption.isVibrationOnly) return;

      // ファイル名を決定（iOS/Android共通で assets/audio/notifications/ 配下を使用）
      // audioplayersは assets プレフィックスを自動付与しない場合があるため確認が必要だが、
      // AssetSource は 'assets/' をルートとする相対パスを指定する仕様
      // ここでは 'audio/notifications/filename' を指定

      final fileName = soundOption.iosFileName; // iOSファイル名を共通で使用（拡張子付き）
      if (fileName == null) return;

      final source = AssetSource('audio/notifications/$fileName');

      // 既存の再生を停止してから再生
      await _audioPlayer.stop();

      // 音量を最大に設定（端末のシステム音量が反映される）
      await _audioPlayer.setVolume(1.0);

      await _audioPlayer.play(source);
    } catch (e) {
      debugPrint('音声再生エラー: $e');
    }
  }

  /// 通知の詳細設定を作成
  NotificationDetails _createNotificationDetails({
    required Int64List vibrationPattern,
  }) {
    final androidDetails = AndroidNotificationDetails(
      'focus_timer_v3',
      '集中タイマー',
      channelDescription: '集中タイマーの通知',
      importance: Importance.max,
      priority: Priority.max,
      playSound: false, // 通知自体の音はOFF
      enableVibration: true,
      vibrationPattern: vibrationPattern,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false, // 通知自体の音はOFF
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// 作業時間終了の通知
  /// バイブレーション: 長い振動1回（800ms）
  Future<void> showWorkCompleteNotification() async {
    await _playSound(null); // 設定された音を再生

    final details = _createNotificationDetails(
      vibrationPattern: Int64List.fromList([0, 800]), // 長い振動1回
    );

    await _notifications.show(0, '作業時間終了', 'お疲れさまでした。休憩しましょう。', details);
  }

  /// 休憩時間終了の通知
  /// バイブレーション: 短い振動2回（300ms, 200ms休止, 300ms）
  Future<void> showBreakCompleteNotification() async {
    await _playSound(null); // 設定された音を再生

    final details = _createNotificationDetails(
      vibrationPattern: Int64List.fromList([0, 300, 200, 300]), // 短い振動2回
    );

    await _notifications.show(1, '休憩時間終了', '次のセッションを始めましょう。', details);
  }

  /// 全セット完了の通知
  /// バイブレーション: 短い振動3回（特別感）
  Future<void> showAllSetsCompleteNotification() async {
    await _playSound(null); // 設定された音を再生

    final details = _createNotificationDetails(
      vibrationPattern: Int64List.fromList([
        0,
        200,
        100,
        200,
        100,
        200,
      ]), // 短い振動3回
    );

    await _notifications.show(2, '全セット完了🎉', 'お疲れさまでした！全セット完了です。', details);
  }

  /// バックグラウンド時の定期通知
  /// バイブレーション: 短い振動1回（500ms）
  Future<void> showBackgroundReminderNotification(int remainingMinutes) async {
    // 定期通知では音を鳴らさない（うるさいため）

    final details = _createNotificationDetails(
      vibrationPattern: Int64List.fromList([0, 500]), // 短い振動1回
    );

    await _notifications.show(
      3,
      '集中モード中です',
      'まだ集中時間中です！残り$remainingMinutes分',
      details,
    );
  }

  /// テスト通知を送信（設定画面用）
  Future<void> showTestNotification(String? soundId) async {
    await _playSound(soundId); // 指定された音を再生

    final details = _createNotificationDetails(
      vibrationPattern: Int64List.fromList([0, 500]), // 短い振動1回
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
