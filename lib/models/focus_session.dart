/// 集中セッションの記録
class FocusSession {
  final int? id;
  final DateTime date;
  final int workMinutes;
  final int breakMinutes;
  final int completedSets;
  final int totalSets;
  final int totalFocusMinutes; // 実際に集中した時間（分）
  final bool wasInterrupted; // 途中停止したかどうか

  FocusSession({
    this.id,
    required this.date,
    required this.workMinutes,
    required this.breakMinutes,
    required this.completedSets,
    required this.totalSets,
    required this.totalFocusMinutes,
    this.wasInterrupted = false,
  });

  /// データベースから取得
  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      workMinutes: map['work_minutes'] as int,
      breakMinutes: map['break_minutes'] as int,
      completedSets: map['completed_sets'] as int,
      totalSets: map['total_sets'] as int,
      totalFocusMinutes: map['total_focus_minutes'] as int,
      wasInterrupted: (map['was_interrupted'] as int) == 1,
    );
  }

  /// データベースに保存
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'work_minutes': workMinutes,
      'break_minutes': breakMinutes,
      'completed_sets': completedSets,
      'total_sets': totalSets,
      'total_focus_minutes': totalFocusMinutes,
      'was_interrupted': wasInterrupted ? 1 : 0,
    };
  }

  /// デバッグ用
  @override
  String toString() {
    return 'FocusSession(id: $id, date: $date, focus: ${totalFocusMinutes}min, sets: $completedSets/$totalSets)';
  }
}
