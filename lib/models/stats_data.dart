/// 統計データ
class StatsData {
  final int totalFocusMinutes; // 累計集中時間（分）
  final int currentStreak; // 現在の連続達成日数
  final int maxStreak; // 最大連続達成日数
  final int totalInterruptions; // 累計途中停止回数
  final DateTime? lastSessionDate; // 最後のセッション日
  final List<String> unlockedAchievements; // 解除済み実績ID

  StatsData({
    this.totalFocusMinutes = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.totalInterruptions = 0,
    this.lastSessionDate,
    this.unlockedAchievements = const [],
  });

  /// SharedPreferencesから取得
  factory StatsData.fromJson(Map<String, dynamic> json) {
    return StatsData(
      totalFocusMinutes: json['total_focus_minutes'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      maxStreak: json['max_streak'] as int? ?? 0,
      totalInterruptions: json['total_interruptions'] as int? ?? 0,
      lastSessionDate: json['last_session_date'] != null
          ? DateTime.parse(json['last_session_date'] as String)
          : null,
      unlockedAchievements: (json['unlocked_achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// SharedPreferencesに保存
  Map<String, dynamic> toJson() {
    return {
      'total_focus_minutes': totalFocusMinutes,
      'current_streak': currentStreak,
      'max_streak': maxStreak,
      'total_interruptions': totalInterruptions,
      'last_session_date': lastSessionDate?.toIso8601String(),
      'unlocked_achievements': unlockedAchievements,
    };
  }

  /// コピーを作成（値の更新用）
  StatsData copyWith({
    int? totalFocusMinutes,
    int? currentStreak,
    int? maxStreak,
    int? totalInterruptions,
    DateTime? lastSessionDate,
    List<String>? unlockedAchievements,
  }) {
    return StatsData(
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      totalInterruptions: totalInterruptions ?? this.totalInterruptions,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  /// デバッグ用
  @override
  String toString() {
    return 'StatsData(total: ${totalFocusMinutes}min, streak: $currentStreak/$maxStreak days)';
  }
}
