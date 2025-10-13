import 'package:flutter/material.dart';

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
        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: const Color(0xFF0A2540),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF1E4D7B),
          secondary: const Color(0xFF2C7DA0),
          surface: const Color(0xFF0A1929),
          background: const Color(0xFF000000),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000000),
          elevation: 0,
        ),
        tabBarTheme: const TabBarThemeData(
          indicatorColor: Color(0xFF2C7DA0),
          labelColor: Color(0xFF2C7DA0),
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
              color: const Color(0xFF0A1929),
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

// タイマー画面
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // デフォルト値
  double _workMinutes = 25;
  double _breakMinutes = 5;
  int _sets = 3;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // タイトル
            Text(
              '集中モードを開始',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // 作業時間設定
            _buildTimeSection(
              title: '作業時間',
              value: _workMinutes,
              min: 5,
              max: 120,
              onChanged: (value) {
                setState(() {
                  _workMinutes = value;
                });
              },
            ),
            
            const SizedBox(height: 30),
            
            // 休憩時間設定
            _buildTimeSection(
              title: '休憩時間',
              value: _breakMinutes,
              min: 5,
              max: 60,
              onChanged: (value) {
                setState(() {
                  _breakMinutes = value;
                });
              },
            ),
            
            const SizedBox(height: 30),
            
            // セット数設定
            _buildSetSection(),
            
            const SizedBox(height: 50),
            
            // 開始ボタン
            _buildStartButton(),
            
            const SizedBox(height: 30),
            
            // ステータス表示
            _buildStatusDisplay(),
          ],
        ),
      ),
    );
  }

  // 時間設定セクション
  Widget _buildTimeSection({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1929),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E4D7B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C7DA0).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${value.toInt()}分',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C7DA0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF2C7DA0),
              inactiveTrackColor: const Color(0xFF1E4D7B).withOpacity(0.3),
              thumbColor: const Color(0xFF2C7DA0),
              overlayColor: const Color(0xFF2C7DA0).withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) / 5).toInt(),
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${min.toInt()}分',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              Text(
                '${max.toInt()}分',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // セット数設定セクション
  Widget _buildSetSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1929),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E4D7B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'セット数',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // マイナスボタン
              IconButton(
                onPressed: _sets > 1
                    ? () {
                        setState(() {
                          _sets--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: const Color(0xFF2C7DA0),
                iconSize: 36,
              ),
              
              const SizedBox(width: 20),
              
              // セット数表示
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C7DA0).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2C7DA0),
                    width: 2,
                  ),
                ),
                child: Text(
                  '$_sets',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C7DA0),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // プラスボタン
              IconButton(
                onPressed: _sets < 100
                    ? () {
                        setState(() {
                          _sets++;
                        });
                      }
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF2C7DA0),
                iconSize: 36,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'セット',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 開始ボタン
  Widget _buildStartButton() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E4D7B), Color(0xFF2C7DA0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C7DA0).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(35),
          onTap: () {
            // TODO: タイマー開始処理
          },
          child: const Center(
            child: Text(
              '開始する',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ステータス表示
  Widget _buildStatusDisplay() {
    final totalMinutes = (_workMinutes + _breakMinutes) * _sets;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1929).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E4D7B).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '合計時間',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hours > 0 ? '${hours}時間 ${minutes.toInt()}分' : '${minutes.toInt()}分',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusItem('作業', '${_workMinutes.toInt()}分'),
              Container(
                height: 30,
                width: 1,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildStatusItem('休憩', '${_breakMinutes.toInt()}分'),
              Container(
                height: 30,
                width: 1,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildStatusItem('セット', '$_setsセット'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

// プレースホルダー画面（統計・設定用）
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '$title画面',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '準備中...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
