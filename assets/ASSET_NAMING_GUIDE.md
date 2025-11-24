# 📁 アセット管理ガイド

## フォルダ構造

```
assets/
├── images/
│   ├── backgrounds/     # 背景画像
│   ├── icons/          # アイコン画像
│   └── badges/         # 実績バッジ画像
└── audio/
    ├── notifications/  # 通知音（効果音）
    └── bgm/           # BGM（背景音楽）
```

---

## 📝 命名ルール

### 基本ルール
- **小文字のみ使用**
- **単語の区切りはアンダースコア `_`**
- **日本語は使わない**（英語のみ）
- **拡張子を必ず含める**

### 悪い例 ❌
- `BackgroundImage.png` (大文字を含む)
- `background-image.png` (ハイフンを使用)
- `背景画像.png` (日本語を使用)
- `bg1.png` (意味が不明瞭)

### 良い例 ✅
- `ocean_background.png`
- `timer_icon.png`
- `notification_complete.mp3`

---

## 🖼️ 画像ファイル命名規則

### backgrounds/ （背景画像）
**パターン**: `{用途}_{場所/状態}_background.{拡張子}`

**例**:
- `ocean_main_background.png` - メイン画面の海背景
- `deep_ocean_focus_background.png` - 集中モード画面の深海背景
- `gradient_timer_background.png` - タイマー画面用グラデーション

### icons/ （アイコン）
**パターン**: `icon_{用途}.{拡張子}`

**例**:
- `icon_timer.png` - タイマーアイコン
- `icon_stats.png` - 統計アイコン
- `icon_settings.png` - 設定アイコン
- `icon_play.png` - 再生ボタン
- `icon_stop.png` - 停止ボタン

### badges/ （実績バッジ）
**パターン**: `badge_{実績名}.{拡張子}`

**例**:
- `badge_first_step.png` - 初めての一歩
- `badge_shallow_water.png` - 浅瀬
- `badge_concentration_master.png` - 集中マスター
- `badge_middle_layer.png` - 中層
- `badge_deep_diver.png` - 深海ダイバー
- `badge_mariana_trench.png` - マリアナ海溝
- `badge_perfect_week.png` - パーフェクトウィーク

---

## 🔊 オーディオファイル命名規則

### notifications/ （通知音・効果音）
**パターン**: `notification_{種類}_{男性/女性}.{拡張子}`

**例**:
- `notification_work_complete_male.mp3` - 作業完了通知（男性）
- `notification_work_complete_female.mp3` - 作業完了通知（女性）
- `notification_break_complete_male.mp3` - 休憩完了通知（男性）
- `notification_break_complete_female.mp3` - 休憩完了通知（女性）
- `notification_all_complete_male.mp3` - 全セット完了（男性）
- `notification_all_complete_female.mp3` - 全セット完了（女性）
- `notification_system_alert.mp3` - システムアラート音

### bgm/ （BGM）
**パターン**: `bgm_{雰囲気/シーン}.{拡張子}`

**例**:
- `bgm_ocean_ambient.mp3` - 海の環境音
- `bgm_deep_calm.mp3` - 深い静けさBGM
- `bgm_focus_mode.mp3` - 集中モードBGM
- `bgm_achievement.mp3` - 実績解除BGM

---

## 📐 推奨ファイル形式

### 画像
- **PNG** - 透明度が必要な画像（アイコン、バッジ）
- **JPG** - 写真や背景画像（透明度不要）
- **WebP** - 軽量化が必要な場合

### オーディオ
- **MP3** - 汎用性が高い（iOS/Android両対応）
- **WAV** - 高品質が必要な場合（ファイルサイズ大）

---

## 🎨 画像サイズ推奨値

### 背景画像
- **1080x1920px** - スマートフォン標準
- **1242x2688px** - 高解像度（iPhone向け）

### アイコン
- **48x48px** - 小サイズ
- **96x96px** - 中サイズ
- **144x144px** - 大サイズ

### バッジ
- **256x256px** - 実績バッジ標準サイズ

---

## 📦 pubspec.yaml への登録

ファイルを追加したら、必ず `pubspec.yaml` に登録してください：

```yaml
flutter:
  uses-material-design: true
  
  assets:
    - assets/images/backgrounds/
    - assets/images/icons/
    - assets/images/badges/
    - assets/audio/notifications/
    - assets/audio/bgm/
```

**注意**: フォルダ単位で指定する場合は末尾に `/` を付ける

---

## 💡 使用例（Dart コード内）

### 画像の読み込み
```dart
// 背景画像
Image.asset('assets/images/backgrounds/ocean_main_background.png')

// アイコン
Image.asset('assets/images/icons/icon_timer.png')

// バッジ
Image.asset('assets/images/badges/badge_first_step.png')
```

### オーディオの再生（後で実装）
```dart
// 通知音
audioPlayer.play('assets/audio/notifications/notification_work_complete_male.mp3');

// BGM
audioPlayer.play('assets/audio/bgm/bgm_ocean_ambient.mp3');
```

---

## ✅ チェックリスト

新しいアセットを追加する際は、以下を確認：

- [ ] ファイル名は小文字とアンダースコアのみ
- [ ] 意味が明確で分かりやすい名前
- [ ] 適切なフォルダに配置
- [ ] pubspec.yaml に登録済み
- [ ] ファイル形式は推奨形式
- [ ] 画像サイズは適切か（大きすぎないか）

---

## 🚨 注意事項

1. **著作権に注意**
   - フリー素材を使う場合も、ライセンスを確認
   - 商用利用可能なものを選ぶ

2. **ファイルサイズに注意**
   - アプリサイズが大きくなりすぎないよう、適度に圧縮
   - 不要な高解像度は避ける

3. **バージョン管理**
   - 同じファイル名で更新する場合は注意
   - 必要に応じてバージョン番号を付ける（例: `ocean_background_v2.png`）
