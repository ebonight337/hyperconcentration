import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'screens/timer_screen.dart';
import 'screens/stats_screen/stats_screen.dart';
import 'screens/settings_screen/settings_screen.dart';
import 'utils/constants.dart';
import 'utils/app_theme.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/foreground_timer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Foreground Task通信ポートを初期化（必須！）
  FlutterForegroundTask.initCommunicationPort();
  
  // データ保存サービスを初期化
  await StorageService.instance.init();
  
  // 通知サービスを初期化
  await NotificationService.instance.init();
  
  // ✅ Foreground Timerサービスを初期化（追加！）
  await ForegroundTimerService.instance.init();
  
  runApp(const HyperConcentrationApp());
}

class HyperConcentrationApp extends StatelessWidget {
  const HyperConcentrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 将来的にはStorageServiceから保存されたテーマIDを取得
    const currentThemeId = 'ocean_night';
    
    return MaterialApp(
      title: '過集中サポート',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(currentThemeId),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    
    return Scaffold(
      body: Column(
        children: [
          // タブバー
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: TabBar(
                controller: _tabController,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'タイマー'),
                  Tab(text: '統計'),
                  Tab(text: '設定'),
                ],
              ),
            ),
          ),
          // タブビュー
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                TimerScreen(),
                StatsScreen(),
                SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
