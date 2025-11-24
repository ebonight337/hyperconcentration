import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

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

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final imagePaths = manifestMap.keys
          .where((String key) => key.startsWith('assets/images/backgrounds/'))
          .where(
            (String key) =>
                key.endsWith('.png') ||
                key.endsWith('.jpg') ||
                key.endsWith('.jpeg') ||
                key.endsWith('.webp'),
          )
          .toList();

      if (imagePaths.isEmpty) {
        return [defaultBackground];
      }

      _cache = imagePaths.map((path) {
        final filename = path.split('/').last;
        final id = filename.split('.').first; // 拡張子を除く

        // ファイル名から表示名を生成 (例: ocean_background -> Ocean)
        final name = _formatName(id);

        return AppBackground(
          id: id,
          path: path,
          name: name,
          description: 'Background image', // 動的生成時は固定またはメタデータから取得が必要だが一旦簡易化
          icon: _getIconForName(name),
          color: _getColorForName(name),
        );
      }).toList();

      return _cache!;
    } catch (e) {
      debugPrint('Error loading backgrounds: $e');
      return [defaultBackground];
    }
  }

  /// IDから背景を取得（非同期）
  /// 見つからない場合はデフォルトを返す
  static Future<AppBackground> fromId(String id) async {
    final all = await getAll();
    return all.firstWhere((bg) => bg.id == id, orElse: () => defaultBackground);
  }

  /// 名前をフォーマット (ocean_background -> Ocean Background)
  static String _formatName(String id) {
    return id
        .replaceAll('_', ' ')
        .replaceAll('background', '') // "background" という単語は冗長なので削除
        .trim()
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  /// 名前からアイコンを推測
  static IconData _getIconForName(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('ocean') || lowerName.contains('sea'))
      return Icons.water;
    if (lowerName.contains('forest') || lowerName.contains('tree'))
      return Icons.forest;
    if (lowerName.contains('rain')) return Icons.umbrella;
    if (lowerName.contains('cafe') || lowerName.contains('coffee'))
      return Icons.coffee;
    if (lowerName.contains('library') || lowerName.contains('book'))
      return Icons.local_library;
    if (lowerName.contains('night') || lowerName.contains('star'))
      return Icons.nights_stay;
    if (lowerName.contains('sunset')) return Icons.wb_twilight;
    return Icons.image;
  }

  /// 名前から色を推測
  static Color _getColorForName(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('ocean') || lowerName.contains('sea'))
      return Colors.blue;
    if (lowerName.contains('forest') || lowerName.contains('tree'))
      return Colors.green;
    if (lowerName.contains('rain')) return Colors.blueGrey;
    if (lowerName.contains('cafe') || lowerName.contains('coffee'))
      return Colors.brown;
    if (lowerName.contains('library')) return Colors.indigo;
    if (lowerName.contains('night')) return Colors.deepPurple;
    if (lowerName.contains('sunset')) return Colors.orange;
    return Colors.grey;
  }
}
