# 🎨 アセットフォルダ

このフォルダには、アプリで使用する画像・音声ファイルを格納します。

## 📂 フォルダ構造

```
assets/
├── images/
│   ├── backgrounds/     # 背景画像（海のグラデーション、集中画面の背景など）
│   ├── icons/          # アイコン画像（タイマー、統計、設定アイコンなど）
│   └── badges/         # 実績バッジ画像（達成時に表示されるバッジ）
└── audio/
    ├── notifications/  # 通知音・効果音（作業完了、休憩完了などの通知音）
    └── bgm/           # BGM（集中モード時の環境音など）
```

## 📝 ファイルを追加する前に

1. **命名ルールを確認**
   - `ASSET_NAMING_GUIDE.md` を必ず読んでください
   - 小文字とアンダースコアのみ使用
   - 意味が明確な名前を付ける

2. **ファイル形式を確認**
   - 画像: PNG, JPG, WebP
   - オーディオ: MP3推奨

3. **ファイルサイズに注意**
   - 大きすぎる画像は圧縮する
   - アプリサイズが肥大化しないよう注意

## 🎯 ファイルを追加したら

ファイルを追加した後は：

1. `flutter pub get` を実行
2. アプリを再起動

これで新しいアセットが使えるようになります！

## 💡 使い方の例

```dart
// 背景画像を表示
Image.asset('assets/images/backgrounds/ocean_main_background.png')

// アイコンを表示
Image.asset('assets/images/icons/icon_timer.png')

// バッジを表示
Image.asset('assets/images/badges/badge_first_step.png')
```

---

詳しくは `ASSET_NAMING_GUIDE.md` を参照してください。
