import 'package:flutter/material.dart';

/// アプリのテーマを管理するクラス
class AppTheme {
  /// 利用可能なテーマのリスト
  static const List<ThemeOption> availableThemes = [
    ThemeOption(
      id: 'ocean_night',
      name: 'ダークブルー',
      description: '深海の静寂と深さ',
    ),
    ThemeOption(
      id: 'deep_blue',
      name: 'ライトブルー',
      description: '爽やかな水色の集中空間',
    ),
    ThemeOption(
      id: 'minimal_white',
      name: 'ホワイト',
      description: '清潔感のある明るい空間',
    ),
  ];

  /// テーマIDからThemeDataを取得
  static ThemeData getTheme(String themeId) {
    switch (themeId) {
      case 'ocean_night':
        return _createTheme(
          baseTheme: ThemeData.dark(),
          colors: _oceanNightColors,
          gradients: _oceanNightGradients,
        );
      case 'deep_blue':
        return _createTheme(
          baseTheme: ThemeData.light(), // ライトブルーは明るいテーマベースに変更
          colors: _deepBlueColors,
          gradients: _deepBlueGradients,
        );
      case 'minimal_white':
        return _createTheme(
          baseTheme: ThemeData.light(),
          colors: _minimalWhiteColors,
          gradients: _minimalWhiteGradients,
        );
      default:
        return _createTheme(
          baseTheme: ThemeData.dark(),
          colors: _oceanNightColors,
          gradients: _oceanNightGradients,
        );
    }
  }

  /// テーマIDからAppThemeColorsを取得
  static AppThemeColors getColors(String themeId) {
    switch (themeId) {
      case 'ocean_night':
        return _oceanNightColors;
      case 'deep_blue':
        return _deepBlueColors;
      case 'minimal_white':
        return _minimalWhiteColors;
      default:
        return _oceanNightColors;
    }
  }

  /// テーマIDからAppThemeGradientsを取得
  static AppThemeGradients getGradients(String themeId) {
    switch (themeId) {
      case 'ocean_night':
        return _oceanNightGradients;
      case 'deep_blue':
        return _deepBlueGradients;
      case 'minimal_white':
        return _minimalWhiteGradients;
      default:
        return _oceanNightGradients;
    }
  }

  /// 共通のThemeData作成メソッド
  static ThemeData _createTheme({
    required ThemeData baseTheme,
    required AppThemeColors colors,
    required AppThemeGradients gradients,
  }) {
    return baseTheme.copyWith(
      scaffoldBackgroundColor: colors.background,
      
      // 拡張テーマを追加
      extensions: [
        colors,
        gradients,
      ],
      
      // カラースキーム
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: colors.primary,
        secondary: colors.accent,
        surface: colors.surface,
        background: colors.background,
        error: colors.error,
        onPrimary: colors.textPrimary,
        onSecondary: colors.textPrimary,
        onSurface: colors.textPrimary,
        onBackground: colors.textPrimary,
        onError: colors.textPrimary,
        brightness: baseTheme.brightness,
      ),
      
      // テキストテーマ
      textTheme: baseTheme.textTheme.copyWith(
        // 大見出し
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
          letterSpacing: 0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
          letterSpacing: 0.5,
        ),
        
        // 見出し
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
          letterSpacing: 0.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
          letterSpacing: 0.25,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
          letterSpacing: 0.25,
        ),
        
        // タイトル
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
          letterSpacing: 0.1,
        ),
        
        // 本文
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: colors.textSecondary,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: colors.textSecondary,
          letterSpacing: 0.25,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: colors.textSecondary,
          letterSpacing: 0.4,
          height: 1.5,
        ),
        
        // ラベル
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colors.textSecondary,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors.textSecondary,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: colors.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
      
      // AppBarテーマ
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
          letterSpacing: 0.15,
        ),
        iconTheme: IconThemeData(
          color: colors.textPrimary,
        ),
      ),
      
      // タブバーテーマ
      tabBarTheme: TabBarThemeData(
        indicatorColor: colors.accent,
        labelColor: colors.accent,
        unselectedLabelColor: colors.textTertiary,
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
        color: colors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // ElevatedButtonテーマ
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.textPrimary,
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
          foregroundColor: colors.textSecondary,
          side: BorderSide(
            color: colors.textSecondary.withOpacity(0.3),
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
          foregroundColor: colors.accent,
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
        backgroundColor: colors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
          letterSpacing: 0.15,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: colors.textSecondary,
          letterSpacing: 0.25,
          height: 1.5,
        ),
      ),
      
      // Dividerテーマ
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 16,
      ),
      
      // IconTheme
      iconTheme: IconThemeData(
        color: colors.textSecondary,
        size: 24,
      ),
      
      // Sliderテーマ
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.accent,
        inactiveTrackColor: colors.primary.withOpacity(0.3),
        thumbColor: colors.accent,
        overlayColor: colors.accent.withOpacity(0.2),
        valueIndicatorColor: colors.accent,
        valueIndicatorTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Switchテーマ
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colors.accent;
          }
          return colors.textTertiary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colors.accent.withOpacity(0.5);
          }
          return colors.primary.withOpacity(0.3);
        }),
      ),
    );
  }

  // ========================================
  // ダークブルーテーマ (旧: 夜の海)
  // ========================================

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

  // ========================================
  // ライトブルーテーマ (旧: 深淵の青) - 水色ベース
  // ========================================

  static const AppThemeColors _deepBlueColors = AppThemeColors(
    background: Color(0xFFE0F2FE), // 薄い水色背景
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF0EA5E9), // Sky Blue 500
    accent: Color(0xFF0284C7), // Sky Blue 600
    darkAccent: Color(0xFF0369A1), // Sky Blue 700
    textPrimary: Color(0xFF0C4A6E), // Sky Blue 900
    textSecondary: Color(0xFF0369A1), // Sky Blue 700
    textTertiary: Color(0xFF38BDF8), // Sky Blue 400
    textDisabled: Color(0xFF94A3B8),
    divider: Color(0xFFBAE6FD), // Sky Blue 200
    error: Color(0xFFEF4444),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
  );

  static const AppThemeGradients _deepBlueGradients = AppThemeGradients(
    background: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFE0F2FE),
        Color(0xFFBAE6FD),
        Color(0xFF7DD3FC),
      ],
    ),
    button: LinearGradient(
      colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    card: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFF0F9FF),
      ],
    ),
  );

  // ========================================
  // ホワイトテーマ (旧: ミニマル白)
  // ========================================

  static const AppThemeColors _minimalWhiteColors = AppThemeColors(
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF475569),
    accent: Color(0xFF0F172A),
    darkAccent: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textTertiary: Color(0xFF94A3B8),
    textDisabled: Color(0xFFCBD5E1),
    divider: Color(0xFFE2E8F0),
    error: Color(0xFFEF4444),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
  );

  static const AppThemeGradients _minimalWhiteGradients = AppThemeGradients(
    background: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFF1F5F9),
        Color(0xFFF8FAFC),
        Color(0xFFFFFFFF),
      ],
    ),
    button: LinearGradient(
      colors: [Color(0xFF334155), Color(0xFF475569)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    card: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFF8FAFC),
      ],
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

/// テーマのカラーセット (ThemeExtension)
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
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

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? primary,
    Color? accent,
    Color? darkAccent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? divider,
    Color? error,
    Color? success,
    Color? warning,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      darkAccent: darkAccent ?? this.darkAccent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      divider: divider ?? this.divider,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      darkAccent: Color.lerp(darkAccent, other.darkAccent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

/// テーマのグラデーションセット (ThemeExtension)
@immutable
class AppThemeGradients extends ThemeExtension<AppThemeGradients> {
  final LinearGradient background;
  final LinearGradient button;
  final LinearGradient card;

  const AppThemeGradients({
    required this.background,
    required this.button,
    required this.card,
  });

  @override
  AppThemeGradients copyWith({
    LinearGradient? background,
    LinearGradient? button,
    LinearGradient? card,
  }) {
    return AppThemeGradients(
      background: background ?? this.background,
      button: button ?? this.button,
      card: card ?? this.card,
    );
  }

  @override
  AppThemeGradients lerp(ThemeExtension<AppThemeGradients>? other, double t) {
    if (other is! AppThemeGradients) {
      return this;
    }
    return AppThemeGradients(
      background: LinearGradient.lerp(background, other.background, t)!,
      button: LinearGradient.lerp(button, other.button, t)!,
      card: LinearGradient.lerp(card, other.card, t)!,
    );
  }
}

/// BuildContextからテーマカラーを取得する拡張
extension ThemeExtensionContext on BuildContext {
  /// 現在のテーマのカラーを取得
  AppThemeColors get colors {
    return Theme.of(this).extension<AppThemeColors>()!;
  }
  
  /// 現在のテーマのグラデーションを取得
  AppThemeGradients get gradients {
    return Theme.of(this).extension<AppThemeGradients>()!;
  }
}
