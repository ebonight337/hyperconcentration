import 'package:flutter/material.dart';

/// アプリ全体で使用する定数を管理
class AppConstants {
  // カラー定数
  static const Color backgroundColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF0A1929);
  static const Color primaryColor = Color(0xFF1E4D7B);
  static const Color accentColor = Color(0xFF2C7DA0);
  static const Color darkTeal = Color(0xFF0A2540);
  static const Color unselectedLabelColor = Color(0xFF4A5568);
  
  // グラデーション
  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF000814),
      Color(0xFF001D3D),
      Color(0xFF003566),
    ],
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF1E4D7B), Color(0xFF2C7DA0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // テキストスタイル
  static TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white.withOpacity(0.9),
  );
  
  static TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white.withOpacity(0.9),
  );
  
  static TextStyle labelStyle = TextStyle(
    fontSize: 14,
    color: Colors.white.withOpacity(0.6),
  );
  
  static TextStyle valueStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppConstants.accentColor,
  );
  
  // サイズ定数
  static const double defaultPadding = 24.0;
  static const double defaultBorderRadius = 16.0;
  static const double buttonBorderRadius = 35.0;
  static const double buttonHeight = 70.0;
  
  // タイマー設定範囲
  static const int minWorkMinutes = 5;
  static const int maxWorkMinutes = 120;
  static const int minBreakMinutes = 0;
  static const int maxBreakMinutes = 60;
  static const int minSets = 1;
  static const int maxSets = 100;
  
  // デフォルト値
  static const int defaultWorkMinutes = 25;
  static const int defaultBreakMinutes = 5;
  static const int defaultSets = 3;
  
  // ボックスデコレーション（共通）
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(defaultBorderRadius),
    border: Border.all(
      color: primaryColor.withOpacity(0.3),
      width: 1,
    ),
  );
  
  static BoxDecoration buttonDecoration = BoxDecoration(
    gradient: buttonGradient,
    borderRadius: BorderRadius.circular(buttonBorderRadius),
    boxShadow: [
      BoxShadow(
        color: accentColor.withOpacity(0.4),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
