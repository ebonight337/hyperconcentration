/// 実績の種類
enum AchievementType {
  cumulative, // 累計型（永続）
  streak,     // 継続型（1ヶ月でリセット）
  daily,      // チャレンジ型（1日でリセット）
}

/// 実績データ
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon; // 絵文字
  final AchievementType type;
  final int requiredValue; // 達成に必要な値
  final String unit; // 単位（分、日、セットなど）

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.requiredValue,
    required this.unit,
  });

  /// 進捗率を計算（0.0 〜 1.0）
  double getProgress(int currentValue) {
    if (currentValue >= requiredValue) return 1.0;
    return currentValue / requiredValue;
  }

  /// 進捗テキスト
  String getProgressText(int currentValue) {
    if (currentValue >= requiredValue) {
      return '達成済み';
    }
    return '$currentValue / $requiredValue $unit';
  }

  /// 解除済みかどうか
  bool isUnlocked(int currentValue) {
    return currentValue >= requiredValue;
  }
}

/// 全実績リスト
class Achievements {
  // =================================================================
  // 🏆 達成型（累計時間ベース） - 分単位
  // =================================================================
  static const cumulative = [
    Achievement(
      id: 'first_step',
      title: '初めての一歩',
      description: '初回セット完了',
      icon: '🌊',
      type: AchievementType.cumulative,
      requiredValue: 1,
      unit: 'セット',
    ),
    Achievement(
      id: 'shallow_water',
      title: '浅瀬',
      description: '累計1時間達成',
      icon: '🏖️',
      type: AchievementType.cumulative,
      requiredValue: 60,
      unit: '分',
    ),
    Achievement(
      id: 'focus_master',
      title: '集中マスター',
      description: '累計10時間達成',
      icon: '🎯',
      type: AchievementType.cumulative,
      requiredValue: 600,
      unit: '分',
    ),
    Achievement(
      id: 'mid_layer',
      title: '中層',
      description: '累計50時間達成',
      icon: '🐠',
      type: AchievementType.cumulative,
      requiredValue: 3000,
      unit: '分',
    ),
    Achievement(
      id: 'deep_diver',
      title: '深海ダイバー',
      description: '累計100時間達成',
      icon: '🤿',
      type: AchievementType.cumulative,
      requiredValue: 6000,
      unit: '分',
    ),
    Achievement(
      id: 'japan_sea_depth',
      title: '日本海深部',
      description: '累計200時間達成',
      icon: '🗾',
      type: AchievementType.cumulative,
      requiredValue: 12000,
      unit: '分',
    ),
    Achievement(
      id: 'mariana_trench',
      title: 'マリアナ海溝',
      description: '累計500時間達成',
      icon: '🌀',
      type: AchievementType.cumulative,
      requiredValue: 30000,
      unit: '分',
    ),
    Achievement(
      id: 'deep_sea_ruler',
      title: '深海の覇者',
      description: '累計1000時間達成',
      icon: '👑',
      type: AchievementType.cumulative,
      requiredValue: 60000,
      unit: '分',
    ),
    Achievement(
      id: 'abyss_sage',
      title: '深淵なる賢者',
      description: '累計5000時間達成',
      icon: '🧙',
      type: AchievementType.cumulative,
      requiredValue: 300000,
      unit: '分',
    ),
    Achievement(
      id: 'knowledge_master',
      title: '知識を極めた者',
      description: '累計10000時間達成',
      icon: '📚',
      type: AchievementType.cumulative,
      requiredValue: 600000,
      unit: '分',
    ),
  ];

  // =================================================================
  // 📅 継続型（1ヶ月でリセット） - 日数
  // =================================================================
  static const streak = [
    Achievement(
      id: 'streak_2',
      title: '2日連続',
      description: '2日連続で1セット以上完了',
      icon: '🔥',
      type: AchievementType.streak,
      requiredValue: 2,
      unit: '日',
    ),
    Achievement(
      id: 'streak_5',
      title: '5日連続',
      description: '5日連続で1セット以上完了',
      icon: '⚡',
      type: AchievementType.streak,
      requiredValue: 5,
      unit: '日',
    ),
    Achievement(
      id: 'perfect_week',
      title: 'パーフェクトウィーク',
      description: '7日連続で毎日1セット以上完了',
      icon: '✨',
      type: AchievementType.streak,
      requiredValue: 7,
      unit: '日',
    ),
    Achievement(
      id: 'streak_30',
      title: '30日連続',
      description: '30日連続で1セット以上完了',
      icon: '🌟',
      type: AchievementType.streak,
      requiredValue: 30,
      unit: '日',
    ),
  ];

  // =================================================================
  // ⚡ チャレンジ型（1日でリセット） - 分単位またはセット数
  // =================================================================
  static const daily = [
    Achievement(
      id: 'sprinter',
      title: 'スプリンター',
      description: '1日で3時間集中',
      icon: '🏃',
      type: AchievementType.daily,
      requiredValue: 180,
      unit: '分',
    ),
    Achievement(
      id: 'marathon_runner',
      title: 'マラソンランナー',
      description: '1日で5時間集中',
      icon: '🏃‍♂️',
      type: AchievementType.daily,
      requiredValue: 300,
      unit: '分',
    ),
    Achievement(
      id: 'early_bird',
      title: '早起き習慣',
      description: '午前6時〜9時に10セット完了',
      icon: '🌅',
      type: AchievementType.daily,
      requiredValue: 10,
      unit: 'セット',
    ),
  ];

  /// 全実績リスト
  static List<Achievement> get all {
    return [...cumulative, ...streak, ...daily];
  }

  /// IDから実績を取得
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// タイプ別に実績を取得
  static List<Achievement> getByType(AchievementType type) {
    return all.where((a) => a.type == type).toList();
  }
}
