import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../services/achievement_service.dart';
import '../../models/stats_data.dart';
import '../../models/focus_session.dart';
import '../../models/achievement.dart';
import '../../utils/constants.dart';
import 'widgets/today_stats_card.dart';
import 'widgets/streak_stats_card.dart';
import 'widgets/period_stats_card.dart';
import 'widgets/weekly_chart.dart';
import 'widgets/monthly_chart.dart';
import 'widgets/achievement_badge.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final StorageService _storage = StorageService.instance;
  final AchievementService _achievementService = AchievementService();
  
  // 統計データ
  StatsData? _statsData;
  int _todayMinutes = 0;
  int _weekMinutes = 0;
  int _monthMinutes = 0;
  List<FocusSession> _recentSessions = [];
  
  // 実績データ
  List<Achievement> _unlockedAchievements = [];
  List<Achievement> _lockedAchievements = [];
  Map<String, int> _achievementProgress = {};
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  /// 統計データを読み込む
  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _storage.getStats();
      final today = DateTime.now();
      
      // 今日・今週・今月の集中時間を取得
      final todayMinutes = await _storage.getTotalFocusMinutesByDate(today);
      final weekStart = _getWeekStart(today);
      final weekMinutes = await _calculatePeriodMinutes(weekStart, today);
      final monthStart = DateTime(today.year, today.month, 1);
      final monthMinutes = await _calculatePeriodMinutes(monthStart, today);
      
      // グラフ用の最近のセッションを取得
      final thirtyDaysAgo = today.subtract(const Duration(days: 30));
      final recentSessions = await _storage.getSessionsBetween(thirtyDaysAgo, today);
      
      // 実績データを取得
      final unlockedAchievements = await _achievementService.getUnlockedAchievements();
      final lockedAchievements = await _achievementService.getLockedAchievements();
      final achievementProgress = await _achievementService.getAchievementProgress();

      setState(() {
        _statsData = stats;
        _todayMinutes = todayMinutes;
        _weekMinutes = weekMinutes;
        _monthMinutes = monthMinutes;
        _recentSessions = recentSessions;
        _unlockedAchievements = unlockedAchievements;
        _lockedAchievements = lockedAchievements;
        _achievementProgress = achievementProgress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'データの読み込みに失敗しました: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 期間内の集中時間を計算
  Future<int> _calculatePeriodMinutes(DateTime start, DateTime end) async {
    final sessions = await _storage.getSessionsBetween(start, end);
    return sessions.fold<int>(
      0,
      (sum, session) => sum + session.totalFocusMinutes,
    );
  }

  /// 週の開始日（月曜日）を取得
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  /// 時間を「○時間○分」形式に変換
  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes}分';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '${hours}時間';
    }
    return '${hours}時間${mins}分';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppConstants.accentColor,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      color: AppConstants.accentColor,
      backgroundColor: AppConstants.surfaceColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // タイトル
            Text(
              '統計',
              style: AppConstants.titleStyle,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 30),
            
            // 今日の集中時間
            TodayStatsCard(
              minutes: _todayMinutes,
              formatMinutes: _formatMinutes,
            ),
            
            const SizedBox(height: 20),
            
            // 連続達成日数
            StreakStatsCard(
              currentStreak: _statsData?.currentStreak ?? 0,
              maxStreak: _statsData?.maxStreak ?? 0,
            ),
            
            const SizedBox(height: 20),
            
            // 週・月・累計の統計
            PeriodStatsCard(
              weekMinutes: _weekMinutes,
              monthMinutes: _monthMinutes,
              totalMinutes: _statsData?.totalFocusMinutes ?? 0,
              formatMinutes: _formatMinutes,
            ),
            
            const SizedBox(height: 20),
            
            // 過去7日間のグラフ
            WeeklyChart(sessions: _recentSessions),
            
            const SizedBox(height: 20),
            
            // 過去30日間のグラフ
            MonthlyChart(sessions: _recentSessions),
            
            const SizedBox(height: 20),
            
            // 実績バッジエリア
            _buildAchievementSection(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 実績バッジセクション
  Widget _buildAchievementSection() {
    final unlockRate = _unlockedAchievements.length / Achievements.all.length;
    final unlockPercentage = (unlockRate * 100).toInt();
    
    // 解除済みと未解除を結合（解除済みを先に）
    final allAchievements = [..._unlockedAchievements, ..._lockedAchievements];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: AppConstants.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '実績バッジ',
                    style: AppConstants.sectionTitleStyle,
                  ),
                ],
              ),
              // 達成率
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppConstants.accentColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '$unlockPercentage%',
                  style: const TextStyle(
                    color: AppConstants.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // 達成数
          Text(
            '${_unlockedAchievements.length} / ${Achievements.all.length} 解除',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // バッジグリッド
          if (allAchievements.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'セッションを完了して実績を解除しよう！',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.62,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: allAchievements.length,
              itemBuilder: (context, index) {
                final achievement = allAchievements[index];
                final isUnlocked = _unlockedAchievements.contains(achievement);
                final currentProgress = _getProgressForAchievement(achievement);
                
                return AchievementBadge(
                  achievement: achievement,
                  isUnlocked: isUnlocked,
                  currentProgress: currentProgress,
                );
              },
            ),
        ],
      ),
    );
  }
  
  /// 実績の進捗値を取得
  int _getProgressForAchievement(Achievement achievement) {
    switch (achievement.type) {
      case AchievementType.cumulative:
        return _achievementProgress['totalMinutes'] ?? 0;
      case AchievementType.streak:
        return _achievementProgress['currentStreak'] ?? 0;
      case AchievementType.daily:
        if (achievement.id == 'early_bird') {
          return _achievementProgress['earlyBirdCount'] ?? 0;
        }
        return _achievementProgress['todayMinutes'] ?? 0;
    }
  }
}
