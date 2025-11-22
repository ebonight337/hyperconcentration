import 'package:flutter/material.dart';
import 'package:hyperconcentration/services/ad_service.dart';

class AdTestScreen extends StatelessWidget {
  const AdTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('広告テスト'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '広告テスト画面',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print('\n=== テストボタン: 広告ロード ===');
                await AdService().loadAppOpenAd();
              },
              child: const Text('広告をロード'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print('\n=== テストボタン: 広告表示 ===');
                await AdService().showAppOpenAd();
              },
              child: const Text('広告を表示'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('\n=== 広告ステータス確認 ===');
                print('広告利用可能: ${AdService().isAdAvailable}');
              },
              child: const Text('ステータス確認'),
            ),
          ],
        ),
      ),
    );
  }
}
