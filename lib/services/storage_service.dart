import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/focus_session.dart';
import '../models/stats_data.dart';
import '../models/my_set.dart';
import 'database_helper.dart';

/// データ保存を統合管理するサービス
class StorageService {
  static final StorageService instance = StorageService._init();
  
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  SharedPreferences? _prefs;

  StorageService._init();

  /// 初期化
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // データベースも初期化
    await _dbHelper.database;
  }

  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ==================== セッション記録 ====================

  /// セッションを保存
  Future<void> saveSession(FocusSession session) async {
    await _dbHelper.insertSession(session);
    
    // 統計データを更新
    await _updateStatsAfterSession(session);
  }

  /// 特定の日のセッション一覧を取得
  Future<List<FocusSession>> getSessionsByDate(DateTime date) async {
    return await _dbHelper.getSessionsByDate(date);
  }

  /// 期間内のセッション一覧を取得
  Future<List<FocusSession>> getSessionsBetween(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _dbHelper.getSessionsBetween(startDate, endDate);
  }

  /// 特定の日の集中時間合計を取得
  Future<int> getTotalFocusMinutesByDate(DateTime date) async {
    return await _dbHelper.getTotalFocusMinutesByDate(date);
  }

  // ==================== 統計データ ====================

  /// 統計データを取得
  Future<StatsData> getStats() async {
    final jsonString = _preferences.getString('stats_data');
    if (jsonString == null) {
      return StatsData();
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return StatsData.fromJson(json);
    } catch (e) {
      return StatsData();
    }
  }

  /// 統計データを保存
  Future<void> saveStats(StatsData stats) async {
    final jsonString = jsonEncode(stats.toJson());
    await _preferences.setString('stats_data', jsonString);
  }

  /// セッション後に統計を更新
  Future<void> _updateStatsAfterSession(FocusSession session) async {
    final stats = await getStats();
    
    // 累計時間を更新（途中停止でも集中した時間は記録）
    final newTotalMinutes = stats.totalFocusMinutes + session.totalFocusMinutes;
    
    // 連続達成日数を更新
    int newCurrentStreak = stats.currentStreak;
    int newMaxStreak = stats.maxStreak;
    int newInterruptions = stats.totalInterruptions;
    DateTime? newLastSessionDate = stats.lastSessionDate;

    if (session.wasInterrupted) {
      // 途中停止の場合
      // - 途中停止回数だけ増やす
      // - 連続達成日数は変更しない（リセットしない）
      // - lastSessionDateは更新しない（その日に後で達成すれば連続になる）
      newInterruptions++;
    } else {
      // 正常完了の場合のみ、連続達成日数を更新
      final today = _normalizeDate(session.date);
      final lastDate = stats.lastSessionDate != null
          ? _normalizeDate(stats.lastSessionDate!)
          : null;

      if (lastDate == null) {
        // 初回セッション
        newCurrentStreak = 1;
      } else {
        final daysDiff = today.difference(lastDate).inDays;
        
        if (daysDiff == 0) {
          // 同じ日の追加セッション（連続日数は変わらない）
          // 途中停止があった後でも、同じ日に達成すれば連続継続
          newCurrentStreak = stats.currentStreak;
        } else if (daysDiff == 1) {
          // 連続している
          newCurrentStreak = stats.currentStreak + 1;
        } else {
          // 連続が途切れた（1日以上空いた）
          newCurrentStreak = 1;
        }
      }

      // 最大連続日数を更新
      if (newCurrentStreak > stats.maxStreak) {
        newMaxStreak = newCurrentStreak;
      }
      
      // 正常完了の場合のみlastSessionDateを更新
      newLastSessionDate = session.date;
    }

    // 更新された統計を保存
    final updatedStats = stats.copyWith(
      totalFocusMinutes: newTotalMinutes,
      currentStreak: newCurrentStreak,
      maxStreak: newMaxStreak,
      totalInterruptions: newInterruptions,
      lastSessionDate: newLastSessionDate,
    );

    await saveStats(updatedStats);
  }

  /// 実績を解除
  Future<void> unlockAchievement(String achievementId) async {
    final stats = await getStats();
    
    if (!stats.unlockedAchievements.contains(achievementId)) {
      final updated = stats.copyWith(
        unlockedAchievements: [...stats.unlockedAchievements, achievementId],
      );
      await saveStats(updated);
    }
  }

  // ==================== マイセット ====================

  /// マイセット一覧を取得
  Future<List<MySet>> getMySets() async {
    final jsonString = _preferences.getString('my_sets');
    if (jsonString == null) {
      // デフォルトセットを返す
      return [MySet.defaultSet];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => MySet.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [MySet.defaultSet];
    }
  }

  /// マイセットを保存
  Future<void> saveMySets(List<MySet> sets) async {
    final jsonList = sets.map((set) => set.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _preferences.setString('my_sets', jsonString);
  }

  /// マイセットを追加
  Future<void> addMySet(MySet set) async {
    final sets = await getMySets();
    
    // 最大5つまで
    if (sets.length >= 5) {
      throw Exception('マイセットは最大5つまでです');
    }
    
    sets.add(set);
    await saveMySets(sets);
  }

  /// マイセットを削除
  Future<void> deleteMySet(String id) async {
    final sets = await getMySets();
    sets.removeWhere((set) => set.id == id);
    await saveMySets(sets);
  }

  // ==================== 設定 ====================

  /// 通知音設定を取得（ID形式）【拡張性を考慮】
  Future<String> getNotificationSoundId() async {
    // 新形式：String ID
    final soundId = _preferences.getString('notification_sound_id');
    if (soundId != null) {
      return soundId;
    }
    
    // 旧形式からのマイグレーション（互換性のため）
    final oldValue = _preferences.getInt('notification_sound');
    if (oldValue != null) {
      // 旧形式のintをIDに変換
      String migratedId;
      switch (oldValue) {
        case 0: // 男性音声（準備中だった）
        case 1: // 女性音声（準備中だった）
        case 2: // システム音 → 柱時計にマッピング
          migratedId = 'clock';
          break;
        case 3: // バイブのみ
          migratedId = 'vibration_only';
          break;
        default:
          migratedId = 'clock';
      }
      // 新形式で保存
      await setNotificationSoundId(migratedId);
      return migratedId;
    }
    
    // デフォルト
    return 'clock';
  }

  /// 通知音設定を保存（ID形式）
  Future<void> setNotificationSoundId(String soundId) async {
    await _preferences.setString('notification_sound_id', soundId);
  }

  /// 最後に設定したタイマー設定を取得
  Future<Map<String, int>> getLastTimerSettings() async {
    return {
      'workMinutes': _preferences.getInt('last_work_minutes') ?? 25,
      'breakMinutes': _preferences.getInt('last_break_minutes') ?? 5,
      'sets': _preferences.getInt('last_sets') ?? 3,
    };
  }

  /// 最後に設定したタイマー設定を保存
  Future<void> saveLastTimerSettings({
    required int workMinutes,
    required int breakMinutes,
    required int sets,
  }) async {
    await _preferences.setInt('last_work_minutes', workMinutes);
    await _preferences.setInt('last_break_minutes', breakMinutes);
    await _preferences.setInt('last_sets', sets);
  }

  // ==================== データリセット ====================

  /// 全データを削除
  Future<void> resetAllData() async {
    // SQLiteデータを削除
    await _dbHelper.deleteAllSessions();
    
    // SharedPreferencesデータを削除
    await _preferences.clear();
  }

  /// 古いデータを削除（1年以上前）
  Future<void> cleanOldData() async {
    await _dbHelper.deleteOldSessions();
  }

  // ==================== ユーティリティ ====================

  /// 日付を正規化（時刻を00:00:00にする）
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
