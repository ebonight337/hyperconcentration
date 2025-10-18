/// マイセット設定
class MySet {
  final String id;
  final String name;
  final int workMinutes;
  final int breakMinutes;
  final int sets;

  MySet({
    required this.id,
    required this.name,
    required this.workMinutes,
    required this.breakMinutes,
    required this.sets,
  });

  /// SharedPreferencesから取得
  factory MySet.fromJson(Map<String, dynamic> json) {
    return MySet(
      id: json['id'] as String,
      name: json['name'] as String,
      workMinutes: json['work_minutes'] as int,
      breakMinutes: json['break_minutes'] as int,
      sets: json['sets'] as int,
    );
  }

  /// SharedPreferencesに保存
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'work_minutes': workMinutes,
      'break_minutes': breakMinutes,
      'sets': sets,
    };
  }

  /// デフォルトのマイセット
  static MySet get defaultSet {
    return MySet(
      id: 'default',
      name: 'デフォルト',
      workMinutes: 30,
      breakMinutes: 5,
      sets: 3,
    );
  }

  /// デバッグ用
  @override
  String toString() {
    return 'MySet($name: ${workMinutes}分作業 + ${breakMinutes}分休憩 × ${sets}セット)';
  }
}
