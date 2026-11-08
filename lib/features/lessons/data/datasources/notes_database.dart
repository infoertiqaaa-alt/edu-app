import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotesDatabase {
  NotesDatabase._({DatabaseFactory? factory, String? databasePath})
    : _factory = factory,
      _overridePath = databasePath;

  static final NotesDatabase instance = NotesDatabase._();

  /// Test-only constructor that allows injecting an in-memory/temp database.
  factory NotesDatabase.forTesting({
    required DatabaseFactory factory,
    required String databasePath,
  }) => NotesDatabase._(factory: factory, databasePath: databasePath);

  static const _dbName = 'app.db';
  static const _dbVersion = 2;
  static const tableName = 'lesson_notes';

  /// Notes created before per-user scoping existed. They are claimed by the
  /// first authenticated user who opens notes after upgrading.
  static const legacyUserId = '__legacy__';

  static const _userIdColumn = 'user_id';

  final DatabaseFactory? _factory;
  final String? _overridePath;

  Future<Database>? _database;
  final Set<String> _claimedLegacyFor = <String>{};

  /// The open is shared: concurrent first callers (e.g. the notes list and an
  /// add-note action) await the same Future instead of each opening — and
  /// possibly migrating — the database file separately. A failed open is not
  /// cached, so the next call retries.
  Future<Database> get database {
    return _database ??= _initDatabase().catchError((Object error) {
      _database = null;
      throw error;
    });
  }

  Future<Database> _initDatabase() async {
    final factory = _factory ?? databaseFactory;
    final path = _overridePath ?? join(await getDatabasesPath(), _dbName);

    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lesson_id INTEGER NOT NULL,
        $_userIdColumn TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_lesson_notes_lesson_id ON $tableName (lesson_id)',
    );
    await db.execute(
      'CREATE INDEX idx_lesson_notes_user_lesson '
      'ON $tableName ($_userIdColumn, lesson_id)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Preserve every legacy row; it becomes visible to the first user who
      // opens the notes screen after the upgrade (see [claimLegacyNotes]).
      await db.execute(
        'ALTER TABLE $tableName ADD COLUMN $_userIdColumn TEXT '
        "NOT NULL DEFAULT '$legacyUserId'",
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_lesson_notes_user_lesson '
        'ON $tableName ($_userIdColumn, lesson_id)',
      );
    }
  }

  /// Assigns pre-v2 notes to [userId] once. Returns the number of claimed rows.
  Future<int> claimLegacyNotes(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty || normalized == legacyUserId) return 0;
    if (!_claimedLegacyFor.add(normalized)) return 0;

    final db = await database;
    return db.update(
      tableName,
      {_userIdColumn: normalized},
      where: '$_userIdColumn = ?',
      whereArgs: [legacyUserId],
    );
  }

  Future<void> close() async {
    final pending = _database;
    _database = null;
    if (pending != null) {
      try {
        await (await pending).close();
      } catch (_) {
        // The open itself failed; there is nothing to close.
      }
    }
    _claimedLegacyFor.clear();
  }
}
