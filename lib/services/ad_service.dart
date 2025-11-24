import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // シングルトンインスタンス
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // 初期化フラグ
  bool _isInitialized = false;

  // アプリ起動広告
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  // 開発中はテスト広告IDを使用
  // リリース時にはコメントアウトして本番IDを使用
  static const bool _isTestMode = false; // 本番リリース時はfalseに変更

  // 広告ID（テスト用と本番用）
  static String get _appOpenAdUnitId {
    if (_isTestMode) {
      // テスト用広告ID
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9257395921' // Android test ID
          : 'ca-app-pub-3940256099942544/5575463023'; // iOS test ID
    } else {
      // 本番用広告ID
      return Platform.isAndroid
          ? 'ca-app-pub-4491043698969716/1214126893' // あなたの本番ID
          : 'YOUR_IOS_APP_OPEN_AD_ID'; // iOS用の本番IDを後で追加
    }
  }

  // 初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    print('\n=== AdService 初期化開始 ===');
    await MobileAds.instance.initialize();
    _isInitialized = true;
    print('MobileAds SDK 初期化完了');

    // アプリ起動時に広告をロード
    await loadAppOpenAd();
    print('=== AdService 初期化完了 ===\n');
  }

  // アプリ起動広告のロード
  Future<void> loadAppOpenAd() async {
    if (!_isInitialized) {
      print('エラー: AdServiceが初期化されていません');
      return;
    }

    print('\n広告ロード開始... ID: $_appOpenAdUnitId');

    await AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('アプリ起動広告がロードされました');
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('アプリ起動広告のロードに失敗: ${error.message}');
          _appOpenAd = null;
        },
      ),
    );
  }

  // アプリ起動広告の表示
  Future<void> showAppOpenAd() async {
    print('==== showAppOpenAd() 呼び出し ====');
    print('_appOpenAd: ${_appOpenAd != null ? "あり" : "なし"}');
    print('_isShowingAd: $_isShowingAd');

    if (_appOpenAd == null) {
      print('表示する広告がありません');
      await loadAppOpenAd(); // 次回のために再ロード
      return;
    }

    if (_isShowingAd) {
      print('広告は既に表示中です');
      return;
    }

    print('広告を表示します...');

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('アプリ起動広告が表示されました');
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        print('アプリ起動広告が閉じられました');
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd(); // 次回のために再ロード
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        print('アプリ起動広告の表示に失敗: ${error.message}');
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd(); // 次回のために再ロード
      },
    );

    await _appOpenAd!.show();
  }

  // 広告が表示可能かチェック
  bool get isAdAvailable => _appOpenAd != null && !_isShowingAd;

  // リソースの解放
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}
