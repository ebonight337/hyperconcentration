import 'package:flutter/material.dart';
import 'screens/timer_screen.dart';
import 'screens/placeholder_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const HyperConcentrationApp());
}

class HyperConcentrationApp extends StatelessWidget {
  const HyperConcentrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '過集中サポート',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        primaryColor: AppConstants.primaryColor,
        colorScheme: ColorScheme.dark(
          primary: AppConstants.primaryColor,
          secondary: AppConstants.accentColor,
          surface: AppConstants.surfaceColor,
          background: AppConstants.backgroundColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.backgroundColor,
          elevation: 0,
        ),
        tabBarTheme: const TabBarThemeData(
          indicatorColor: AppConstants.accentColor,
          labelColor: AppConstants.accentColor,
          unselectedLabelColor: Color(0xFF4A5568),
        ),
      ),
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
    return Scaffold(
      body: Column(
        children: [
          // タブバー
          Container(
            decoration: BoxDecoration(
              color: AppConstants.surfaceColor,
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
                PlaceholderScreen(title: '統計'),
                PlaceholderScreen(title: '設定'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
