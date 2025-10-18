import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/focus_session.dart';

/// SQLiteデータベースヘルパー
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// データベースインスタンスを取得
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('focus_sessions.db');
    return _database!;
  }

  /// データベースを初期化
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// テーブル作成
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE focus_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        work_minutes INTEGER NOT NULL,
        break_minutes INTEGER NOT NULL,
        completed_sets INTEGER NOT NULL,
        total_sets INTEGER NOT NULL,
        total_focus_minutes INTEGER NOT NULL,
        was_interrupted INTEGER NOT NULL
      )
    ''');

    // 日付でインデックスを作成（検索高速化）
    await db.execute('''
      CREATE INDEX idx_date ON focus_sessions(date)
    ''');
  }

  /// セッションを保存
  Future<int> insertSession(FocusSession session) async {
    final db = await database;
    return await db.insert('focus_sessions', session.toMap());
  }

  /// 特定の日のセッション一覧を取得
  Future<List<FocusSession>> getSessionsByDate(DateTime date) async {
    final db = await database;
    final dateStr = _formatDate(date);
    
    final maps = await db.query(
      'focus_sessions',
      where: 'date LIKE ?',
      whereArgs: ['$dateStr%'],
      orderBy: 'id DESC',
    );

    return maps.map((map) => FocusSession.fromMap(map)).toList();
  }

  /// 期間内のセッション一覧を取得
  Future<List<FocusSession>> getSessionsBetween(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startStr = _formatDate(startDate);
    final endStr = _formatDate(endDate.add(const Duration(days: 1)));

    final maps = await db.query(
      'focus_sessions',
      where: 'date >= ? AND date < ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date DESC',
    );

    return maps.map((map) => FocusSession.fromMap(map)).toList();
  }

  /// 全セッションを取得
  Future<List<FocusSession>> getAllSessions() async {
    final db = await database;
    final maps = await db.query('focus_sessions', orderBy: 'date DESC');
    return maps.map((map) => FocusSession.fromMap(map)).toList();
  }

  /// 特定の日の集中時間合計を取得
  Future<int> getTotalFocusMinutesByDate(DateTime date) async {
    final db = await database;
    final dateStr = _formatDate(date);

    final result = await db.rawQuery('''
      SELECT SUM(total_focus_minutes) as total
      FROM focus_sessions
      WHERE date LIKE ?
    ''', ['$dateStr%']);

    return result.first['total'] as int? ?? 0;
  }

  /// 1年以内のデータを取得（古いデータは削除対象）
  Future<List<FocusSession>> getRecentSessions() async {
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
    final oneYearAgoStr = _formatDate(oneYearAgo);

    final db = await database;
    final maps = await db.query(
      'focus_sessions',
      where: 'date >= ?',
      whereArgs: [oneYearAgoStr],
      orderBy: 'date DESC',
    );

    return maps.map((map) => FocusSession.fromMap(map)).toList();
  }

  /// 1年より古いデータを削除
  Future<int> deleteOldSessions() async {
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
    final oneYearAgoStr = _formatDate(oneYearAgo);

    final db = await database;
    return await db.delete(
      'focus_sessions',
      where: 'date < ?',
      whereArgs: [oneYearAgoStr],
    );
  }

  /// 全データを削除（リセット用）
  Future<void> deleteAllSessions() async {
    final db = await database;
    await db.delete('focus_sessions');
  }

  /// データベースをクローズ
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// 日付をYYYY-MM-DD形式に変換
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
