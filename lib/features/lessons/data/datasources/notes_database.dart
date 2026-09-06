import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotesDatabase {
  NotesDatabase._();

  static final NotesDatabase instance = NotesDatabase._();

  static const _dbName = 'app.db';
  static const _dbVersion = 1;
  static const tableName = 'lesson_notes';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lesson_id INTEGER NOT NULL,
            content TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_lesson_notes_lesson_id ON $tableName (lesson_id)',
        );
      },
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}