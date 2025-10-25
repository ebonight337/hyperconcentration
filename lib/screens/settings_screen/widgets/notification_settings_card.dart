import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../services/storage_service.dart';
import '../../../services/notification_service.dart';

class NotificationSettingsCard extends StatefulWidget {
  const NotificationSettingsCard({super.key});

  @override
  State<NotificationSettingsCard> createState() => _NotificationSettingsCardState();
}

class _NotificationSettingsCardState extends State<NotificationSettingsCard> {
  final StorageService _storage = StorageService.instance;
  final NotificationService _notificationService = NotificationService.instance;
  
  String _selectedSoundId = AppConstants.defaultNotificationSoundId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final soundId = await _storage.getNotificationSoundId();
    setState(() {
      _selectedSoundId = soundId;
      _isLoading = false;
    });
  }

  Future<void> _updateSound(String soundId) async {
    await _storage.setNotificationSoundId(soundId);
    setState(() {
      _selectedSoundId = soundId;
    });
    
    // 変更を保存した通知を表示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '通知音を変更しました',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: AppConstants.surfaceColor,
        ),
      );
    }
  }

  Future<void> _testNotification() async {
    // 選択中の効果音でテスト通知を送信
    await _notificationService.showTestNotification(_selectedSoundId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'テスト通知を送信しました',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: AppConstants.surfaceColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: AppConstants.cardDecoration,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppConstants.accentColor,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppConstants.accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '通知設定',
                style: AppConstants.sectionTitleStyle,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 動的に効果音リストを生成（拡張性を考慮）
          ...AppConstants.notificationSounds.map((soundOption) {
            return _buildSoundOption(
              soundId: soundOption.id,
              title: soundOption.displayName,
              subtitle: soundOption.description,
            );
          }),
          
          const SizedBox(height: 16),
          
          // テスト通知ボタン
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _testNotification,
              icon: const Icon(Icons.volume_up),
              label: const Text('テスト通知を送信'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.accentColor,
                side: const BorderSide(
                  color: AppConstants.accentColor,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundOption({
    required String soundId,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedSoundId == soundId;
    
    return InkWell(
      onTap: () => _updateSound(soundId),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Radio<String>(
              value: soundId,
              groupValue: _selectedSoundId,
              onChanged: (val) => _updateSound(val!),
              activeColor: AppConstants.accentColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
