import 'package:flutter/material.dart';

/// アプリのテーマを管理するクラス
class AppTheme {
  /// 利用可能なテーマのリスト
  static const List<ThemeOption> availableThemes = [
    ThemeOption(
      id: 'ocean_night',
      name: '夜の海',
      description: '深海の静寂と深さ',
    ),
    // 将来的に追加予定
    // ThemeOption(
    //   id: 'forest',
    //   name: '静かな森',
    //   description: '森の静けさと落ち着き',
    // ),
  ];

  /// テーマIDからThemeDataを取得
  static ThemeData getTheme(String themeId) {
    switch (themeId) {
      case 'ocean_night':
        return _oceanNightTheme;
      default:
        return _oceanNightTheme;
    }
  }

  /// テーマIDからAppThemeColorsを取得
  static AppThemeColors getColors(String themeId) {
    switch (themeId) {
      case 'ocean_night':
        return _oceanNightColors;
      default:
        return _oceanNightColors;
    }
  }

  /// テーマIDからAppThemeGradientsを取得
  static AppThemeGradients getGradients(String themeId) {
    switch (themeId) {
      case 'ocean_night':
        return _oceanNightGradients;
      default:
        return _oceanNightGradients;
    }
  }

  // ========================================
  // 夜の海テーマ
  // ========================================

  /// 夜の海テーマのカラーセット
  static const AppThemeColors _oceanNightColors = AppThemeColors(
    background: Color(0xFF000000),
    surface: Color(0xFF0A1929),
    primary: Color(0xFF1E4D7B),
    accent: Color(0xFF2C7DA0),
    darkAccent: Color(0xFF0A2540),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xB3FFFFFF), // 70%
    textTertiary: Color(0x99FFFFFF), // 60%
    textDisabled: Color(0x66FFFFFF), // 40%
    divider: Color(0x3DFFFFFF), // 24%
    error: Color(0xFFEF4444),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
  );

  /// 夜の海テーマのグラデーション
  static const AppThemeGradients _oceanNightGradients = AppThemeGradients(
    background: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF000814),
        Color(0xFF001D3D),
        Color(0xFF003566),
      ],
    ),
    button: LinearGradient(
      colors: [Color(0xFF1E4D7B), Color(0xFF2C7DA0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    card: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0A1929),
        Color(0xFF0F2638),
      ],
    ),
  );

  /// 夜の海テーマのThemeData
  static final ThemeData _oceanNightTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _oceanNightColors.background,
    
    // カラースキーム
    colorScheme: ColorScheme.dark(
      primary: _oceanNightColors.primary,
      secondary: _oceanNightColors.accent,
      surface: _oceanNightColors.surface,
      background: _oceanNightColors.background,
      error: _oceanNightColors.error,
      onPrimary: _oceanNightColors.textPrimary,
      onSecondary: _oceanNightColors.textPrimary,
      onSurface: _oceanNightColors.textPrimary,
      onBackground: _oceanNightColors.textPrimary,
      onError: _oceanNightColors.textPrimary,
    ),
    
    // テキストテーマ
    textTheme: TextTheme(
      // 大見出し（画面タイトル等）
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: _oceanNightColors.textPrimary,
        letterSpacing: 0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: _oceanNightColors.textPrimary,
        letterSpacing: 0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: _oceanNightColors.textPrimary,
        letterSpacing: 0.5,
      ),
      
      // 見出し
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: _oceanNightColors.textPrimary,
        letterSpacing: 0.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _oceanNightColors.textPrimary,
        letterSpacing: 0.25,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _oceanNightColors.textPrimary,
        letterSpacing: 0.25,
      ),
      
      // タイトル
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: _oceanNightColors.textPrimary,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _oceanNightColors.textPrimary,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _oceanNightColors.textPrimary,
        letterSpacing: 0.1,
      ),
      
      // 本文
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: _oceanNightColors.textSecondary,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: _oceanNightColors.textSecondary,
        letterSpacing: 0.25,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: _oceanNightColors.textSecondary,
        letterSpacing: 0.4,
        height: 1.5,
      ),
      
      // ラベル
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _oceanNightColors.textSecondary,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _oceanNightColors.textSecondary,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: _oceanNightColors.textTertiary,
        letterSpacing: 0.5,
      ),
    ),
    
    // AppBarテーマ
    appBarTheme: AppBarTheme(
      backgroundColor: _oceanNightColors.background,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _oceanNightColors.textPrimary,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(
        color: _oceanNightColors.textPrimary,
      ),
    ),
    
    // タブバーテーマ
    tabBarTheme: TabBarThemeData(
      indicatorColor: _oceanNightColors.accent,
      labelColor: _oceanNightColors.accent,
      unselectedLabelColor: _oceanNightColors.textTertiary,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.5,
      ),
    ),
    
    // カードテーマ
    cardTheme: CardThemeData(
      color: _oceanNightColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _oceanNightColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // ElevatedButtonテーマ
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _oceanNightColors.primary,
        foregroundColor: _oceanNightColors.textPrimary,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    // OutlinedButtonテーマ
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _oceanNightColors.textSecondary,
        side: BorderSide(
          color: _oceanNightColors.textSecondary.withOpacity(0.3),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    // TextButtonテーマ
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _oceanNightColors.accent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    // ダイアログテーマ
    dialogTheme: DialogThemeData(
      backgroundColor: _oceanNightColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _oceanNightColors.textPrimary,
        letterSpacing: 0.15,
      ),
      contentTextStyle: TextStyle(
        fontSize: 14,
        color: _oceanNightColors.textSecondary,
        letterSpacing: 0.25,
        height: 1.5,
      ),
    ),
    
    // Dividerテーマ
    dividerTheme: DividerThemeData(
      color: _oceanNightColors.divider,
      thickness: 1,
      space: 16,
    ),
    
    // IconTheme
    iconTheme: IconThemeData(
      color: _oceanNightColors.textSecondary,
      size: 24,
    ),
    
    // Sliderテーマ
    sliderTheme: SliderThemeData(
      activeTrackColor: _oceanNightColors.accent,
      inactiveTrackColor: _oceanNightColors.primary.withOpacity(0.3),
      thumbColor: _oceanNightColors.accent,
      overlayColor: _oceanNightColors.accent.withOpacity(0.2),
      valueIndicatorColor: _oceanNightColors.accent,
      valueIndicatorTextStyle: TextStyle(
        color: _oceanNightColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // Switchテーマ
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _oceanNightColors.accent;
        }
        return _oceanNightColors.textTertiary;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _oceanNightColors.accent.withOpacity(0.5);
        }
        return _oceanNightColors.primary.withOpacity(0.3);
      }),
    ),
  );
}

/// テーマ選択肢
class ThemeOption {
  final String id;
  final String name;
  final String description;

  const ThemeOption({
    required this.id,
    required this.name,
    required this.description,
  });
}

/// テーマのカラーセット
class AppThemeColors {
  final Color background;
  final Color surface;
  final Color primary;
  final Color accent;
  final Color darkAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color divider;
  final Color error;
  final Color success;
  final Color warning;

  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.primary,
    required this.accent,
    required this.darkAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.divider,
    required this.error,
    required this.success,
    required this.warning,
  });
}

/// テーマのグラデーションセット
class AppThemeGradients {
  final LinearGradient background;
  final LinearGradient button;
  final LinearGradient card;

  const AppThemeGradients({
    required this.background,
    required this.button,
    required this.card,
  });
}

/// BuildContextからテーマカラーを取得する拡張
extension ThemeExtension on BuildContext {
  /// 現在のテーマのカラーを取得
  AppThemeColors get colors {
    // TODO: 将来的にはStorageServiceから現在のテーマIDを取得
    return AppTheme.getColors('ocean_night');
  }
  
  /// 現在のテーマのグラデーションを取得
  AppThemeGradients get gradients {
    // TODO: 将来的にはStorageServiceから現在のテーマIDを取得
    return AppTheme.getGradients('ocean_night');
  }
}
