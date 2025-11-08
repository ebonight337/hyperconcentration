import 'package:flutter/material.dart';

// ============================================================
// 重要: 色やスタイルは AppTheme (app_theme.dart) を使用してください！
// このファイルは通知音設定など、テーマ以外の定数に使用します。
// ============================================================

/// 通知音のオプション
class NotificationSoundOption {
  final String id;
  final String displayName;
  final String description;
  final String? androidResourceName; // Android rawリソース名（拡張子なし）
  final String? iosFileName; // iOSファイル名（拡張子あり）
  final bool isVibrationOnly;

  const NotificationSoundOption({
    required this.id,
    required this.displayName,
    required this.description,
    this.androidResourceName,
    this.iosFileName,
    this.isVibrationOnly = false,
  });
}

/// アプリ全体で使用する定数を管理（テーマ以外）
/// 
/// 注意: 色やスタイルは app_theme.dart の AppTheme を使用してください！
/// 使用例:
///   final colors = context.colors;
///   final gradients = context.gradients;
///   final textTheme = Theme.of(context).textTheme;
class AppConstants {
  // ============================================================
  // 色・スタイル関連は非推奨です
  // app_theme.dart の AppTheme を使用してください
  // ============================================================
  
  @Deprecated('context.colors を使用してください')
  static const Color backgroundColor = Color(0xFF000000);
  
  @Deprecated('context.colors を使用してください')
  static const Color surfaceColor = Color(0xFF0A1929);
  
  @Deprecated('context.colors を使用してください')
  static const Color primaryColor = Color(0xFF1E4D7B);
  
  @Deprecated('context.colors を使用してください')
  static const Color accentColor = Color(0xFF2C7DA0);
  
  @Deprecated('context.colors を使用してください')
  static const Color darkTeal = Color(0xFF0A2540);
  
  @Deprecated('context.colors を使用してください')
  static const Color unselectedLabelColor = Color(0xFF4A5568);
  
  @Deprecated('context.gradients を使用してください')
  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF000814),
      Color(0xFF001D3D),
      Color(0xFF003566),
    ],
  );
  
  @Deprecated('context.gradients を使用してください')
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF1E4D7B), Color(0xFF2C7DA0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  @Deprecated('Theme.of(context).textTheme を使用してください')
  static TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white.withOpacity(0.9),
  );
  
  @Deprecated('Theme.of(context).textTheme を使用してください')
  static TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white.withOpacity(0.9),
  );
  
  @Deprecated('Theme.of(context).textTheme を使用してください')
  static TextStyle labelStyle = TextStyle(
    fontSize: 14,
    color: Colors.white.withOpacity(0.6),
  );
  
  @Deprecated('Theme.of(context).textTheme を使用してください')
  static TextStyle valueStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppConstants.accentColor,
  );
  
  @Deprecated('テーマを使用してください')
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: primaryColor.withOpacity(0.3),
      width: 1,
    ),
  );
  
  @Deprecated('テーマを使用してください')
  static BoxDecoration buttonDecoration = BoxDecoration(
    gradient: buttonGradient,
    borderRadius: BorderRadius.circular(35),
    boxShadow: [
      BoxShadow(
        color: accentColor.withOpacity(0.4),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  // ============================================================
  // タイマー設定（テーマ非依存）
  // ============================================================
  
  /// タイマー設定範囲
  static const int minWorkMinutes = 5;
  static const int maxWorkMinutes = 120;
  static const double minBreakMinutes = 0.5; // 30秒
  static const double maxBreakMinutes = 5.0; // 5分
  static const int minSets = 1;
  static const int maxSets = 100;
  
  /// デフォルト値
  static const int defaultWorkMinutes = 25;
  static const int defaultBreakMinutes = 5;
  static const int defaultSets = 3;
  
  // ============================================================
  // サイズ定数（テーマ非依存）
  // ============================================================
  
  static const double defaultPadding = 24.0;
  static const double defaultBorderRadius = 16.0;
  static const double buttonBorderRadius = 35.0;
  static const double buttonHeight = 70.0;
  
  // 通知音の選択肢リスト（拡張性を考慮）
  static const List<NotificationSoundOption> notificationSounds = [
    NotificationSoundOption(
      id: 'clock',
      displayName: '柱時計の鐘',
      description: '落ち着いた鐘の音',
      androidResourceName: 'notification_clock',
      iosFileName: 'notification_clock.mp3',
    ),
    NotificationSoundOption(
      id: 'cuckoo',
      displayName: '鳩時計',
      description: 'かわいい鳩の声',
      androidResourceName: 'notification_cuckoo',
      iosFileName: 'notification_cuckoo.mp3',
    ),
    NotificationSoundOption(
      id: 'vibration_only',
      displayName: 'バイブレーションのみ',
      description: '音なし・振動のみ',
      isVibrationOnly: true,
    ),
    // 今後、ここに新しい音声を追加できます！
    // NotificationSoundOption(
    //   id: 'male_voice',
    //   displayName: '男性音声',
    //   description: '落ち着いた男性の声',
    //   androidResourceName: 'notification_male',
    //   iosFileName: 'notification_male.mp3',
    // ),
  ];
  
  // デフォルトの通知音ID
  static const String defaultNotificationSoundId = 'clock';
}
