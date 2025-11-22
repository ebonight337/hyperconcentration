import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'widgets/notification_settings_card.dart';
import 'widgets/theme_selection_card.dart';
import 'widgets/my_set_list_card.dart';
import 'widgets/data_management_card.dart';
import 'widgets/app_info_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // マイセット適用時にタイマー画面を更新するためのコールバック
  void _onSetApplied() {
    // タイマー画面が自動的に設定を読み込むので、特に何もしなくてOK
    // 必要に応じてここで追加の処理を実行できる
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          // タイトル
          Text(
            '設定',
            style: AppConstants.titleStyle,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // テーマ設定
          const ThemeSelectionCard(),
          
          const SizedBox(height: 20),
          
          // 通知設定
          const NotificationSettingsCard(),
          
          const SizedBox(height: 20),
          
          // マイセット管理
          MySetListCard(
            onSetApplied: _onSetApplied,
          ),
          
          const SizedBox(height: 20),
          
          // データ管理
          const DataManagementCard(),
          
          const SizedBox(height: 20),
          
          // アプリ情報
          const AppInfoCard(),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
