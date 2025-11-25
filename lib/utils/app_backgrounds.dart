import 'package:flutter/material.dart';

/// アプリの背景定義クラス
class AppBackground {
  final String id;
  final String path;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const AppBackground({
    required this.id,
    required this.path,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  /// デフォルトの背景（海）
  static const AppBackground defaultBackground = AppBackground(
    id: 'ocean_background',
    path: 'assets/images/backgrounds/ocean_background.png',
    name: 'Ocean',
    description: 'Standard background',
    icon: Icons.water,
    color: Colors.blue,
  );

  static List<AppBackground>? _cache;

  /// 全ての背景画像を取得
  static Future<List<AppBackground>> getAll() async {
    if (_cache != null) return _cache!;

    // 静的に定義された背景リスト
    _cache = [
      const AppBackground(
        id: '暗い海',
        path: 'assets/images/backgrounds/暗い海.png',
        name: '暗い海',
        description: '深く静かな海',
        icon: Icons.water,
        color: Colors.indigo,
      ),
      const AppBackground(
        id: '本の虫',
        path: 'assets/images/backgrounds/本の虫.png',
        name: '本の虫',
        description: '読書の時間',
        icon: Icons.local_library,
        color: Colors.brown,
      ),
      const AppBackground(
        id: '海の見える部屋',
        path: 'assets/images/backgrounds/海の見える部屋.png',
        name: '海の見える部屋',
        description: '海辺の静けさ',
        icon: Icons.window,
        color: Colors.blue,
      ),
      const AppBackground(
        id: '田舎の風景',
        path: 'assets/images/backgrounds/田舎の風景.png',
        name: '田舎の風景',
        description: '自然の中で',
        icon: Icons.landscape,
        color: Colors.green,
      ),
      const AppBackground(
        id: '雨の町',
        path: 'assets/images/backgrounds/雨の町.png',
        name: '雨の町',
        description: '雨の日の静けさ',
        icon: Icons.umbrella,
        color: Colors.blueGrey,
      ),
    ];

    return _cache!;
  }

  /// IDから背景を取得（非同期）
  /// 見つからない場合はデフォルトを返す
  static Future<AppBackground> fromId(String id) async {
    final all = await getAll();
    return all.firstWhere((bg) => bg.id == id, orElse: () => defaultBackground);
  }
}
