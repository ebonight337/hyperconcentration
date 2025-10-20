import '../models/achievement.dart';
import '../models/stats_data.dart';
import '../models/focus_session.dart';
import 'storage_service.dart';

/// 実績判定サービス
class AchievementService {
  final StorageService _storage = StorageService.instance;

  /// セッション完了時に実績をチェック
  /// 新しく解除された実績のリストを返す
  Future<List<Achievement>> checkAchievements(FocusSession session) async {
    final stats = await _storage.getStats();
    final unlockedIds = stats.unlockedAchievements;
    final newlyUnlocked = <Achievement>[];

    // 途中停止の場合は実績判定しない
    if (session.wasInterrupted) {
      return newlyUnlocked;
    }

    // 🏆 累計型実績をチェック
    final cumulativeUnlocked = await _checkCumulativeAchievements(
      stats.totalFocusMinutes,
      unlockedIds,
    );
    newlyUnlocked.addAll(cumulativeUnlocked);

    // 📅 継続型実績をチェック
    final streakUnlocked = await _checkStreakAchievements(
      stats.currentStreak,
      unlockedIds,
    );
    newlyUnlocked.addAll(streakUnlocked);

    // ⚡ チャレンジ型実績をチェック
    final dailyUnlocked = await _checkDailyAchievements(
      session,
      unlockedIds,
    );
    newlyUnlocked.addAll(dailyUnlocked);

    // 新しく解除された実績を保存
    for (final achievement in newlyUnlocked) {
      await _storage.unlockAchievement(achievement.id);
    }

    return newlyUnlocked;
  }

  /// 🏆 累計型実績をチェック
  Future<List<Achievement>> _checkCumulativeAchievements(
    int totalMinutes,
    List<String> unlockedIds,
  ) async {
    final newlyUnlocked = <Achievement>[];

    for (final achievement in Achievements.cumulative) {
      // すでに解除済みならスキップ
      if (unlockedIds.contains(achievement.id)) continue;

      // 達成条件をチェック
      if (achievement.isUnlocked(totalMinutes)) {
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  /// 📅 継続型実績をチェック
  Future<List<Achievement>> _checkStreakAchievements(
    int currentStreak,
    List<String> unlockedIds,
  ) async {
    final newlyUnlocked = <Achievement>[];

    for (final achievement in Achievements.streak) {
      // すでに解除済みならスキップ
      if (unlockedIds.contains(achievement.id)) continue;

      // 達成条件をチェック
      if (achievement.isUnlocked(currentStreak)) {
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  /// ⚡ チャレンジ型実績をチェック（1日でリセット）
  Future<List<Achievement>> _checkDailyAchievements(
    FocusSession session,
    List<String> unlockedIds,
  ) async {
    final newlyUnlocked = <Achievement>[];
    final today = _normalizeDate(session.date);

    // 今日の累計時間を取得
    final todayMinutes = await _storage.getTotalFocusMinutesByDate(today);

    // スプリンター: 1日で3時間集中
    if (!unlockedIds.contains('sprinter')) {
      final sprinter = Achievements.getById('sprinter')!;
      if (sprinter.isUnlocked(todayMinutes)) {
        newlyUnlocked.add(sprinter);
      }
    }

    // マラソンランナー: 1日で5時間集中
    if (!unlockedIds.contains('marathon_runner')) {
      final marathon = Achievements.getById('marathon_runner')!;
      if (marathon.isUnlocked(todayMinutes)) {
        newlyUnlocked.add(marathon);
      }
    }

    // 早起き習慣: 午前6時〜9時に10セット完了
    if (!unlockedIds.contains('early_bird')) {
      final earlyBirdCount = await _checkEarlyBirdProgress(today);
      final earlyBird = Achievements.getById('early_bird')!;
      if (earlyBird.isUnlocked(earlyBirdCount)) {
        newlyUnlocked.add(earlyBird);
      }
    }

    return newlyUnlocked;
  }

  /// 早起き習慣の進捗をチェック
  Future<int> _checkEarlyBirdProgress(DateTime date) async {
    final sessions = await _storage.getSessionsByDate(date);
    
    int earlyBirdCount = 0;
    for (final session in sessions) {
      final hour = session.date.hour;
      // 午前6時〜9時の間に完了したセッション
      if (hour >= 6 && hour < 9 && !session.wasInterrupted) {
        earlyBirdCount += session.completedSets;
      }
    }
    
    return earlyBirdCount;
  }

  /// 実績の進捗状況を取得
  Future<Map<String, int>> getAchievementProgress() async {
    final stats = await _storage.getStats();
    final today = _normalizeDate(DateTime.now());
    final todayMinutes = await _storage.getTotalFocusMinutesByDate(today);
    final earlyBirdCount = await _checkEarlyBirdProgress(today);

    return {
      // 累計型の進捗（累計時間）
      'totalMinutes': stats.totalFocusMinutes,
      
      // 継続型の進捗（連続日数）
      'currentStreak': stats.currentStreak,
      
      // チャレンジ型の進捗
      'todayMinutes': todayMinutes,
      'earlyBirdCount': earlyBirdCount,
    };
  }

  /// 特定の実績の進捗値を取得
  Future<int> getProgressValue(Achievement achievement) async {
    final progress = await getAchievementProgress();

    switch (achievement.type) {
      case AchievementType.cumulative:
        return progress['totalMinutes'] ?? 0;
      
      case AchievementType.streak:
        return progress['currentStreak'] ?? 0;
      
      case AchievementType.daily:
        if (achievement.id == 'early_bird') {
          return progress['earlyBirdCount'] ?? 0;
        } else {
          // sprinter, marathon_runner
          return progress['todayMinutes'] ?? 0;
        }
    }
  }

  /// 解除済み実績を取得
  Future<List<Achievement>> getUnlockedAchievements() async {
    final stats = await _storage.getStats();
    final unlockedIds = stats.unlockedAchievements;
    
    return Achievements.all
        .where((a) => unlockedIds.contains(a.id))
        .toList();
  }

  /// 未解除実績を取得
  Future<List<Achievement>> getLockedAchievements() async {
    final stats = await _storage.getStats();
    final unlockedIds = stats.unlockedAchievements;
    
    return Achievements.all
        .where((a) => !unlockedIds.contains(a.id))
        .toList();
  }

  /// 実績の解除率を取得（0.0 〜 1.0）
  Future<double> getUnlockRate() async {
    final stats = await _storage.getStats();
    final totalCount = Achievements.all.length;
    final unlockedCount = stats.unlockedAchievements.length;
    
    if (totalCount == 0) return 0.0;
    return unlockedCount / totalCount;
  }

  /// 日付を正規化（時刻を00:00:00にする）
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
