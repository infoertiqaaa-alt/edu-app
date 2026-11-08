import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mr/core/network/network_exceptions.dart';
import 'package:mr/features/lessons/data/datasources/notes_database.dart';
import 'package:mr/features/lessons/data/repositories/lesson_notes_repository_impl.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/in_memory_token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mr_notes_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  String dbPath() => p.join(tempDir.path, 'app.db');

  LessonNotesRepositoryImpl repoFor(NotesDatabase database, String? userId) {
    final storage = InMemoryTokenStorage()
      ..token = 'token'
      ..role = 'student'
      ..userId = userId;
    return LessonNotesRepositoryImpl(database, storage);
  }

  group('NotesDatabase migration', () {
    test(
      'v1 rows are preserved and claiming assigns them to the first user',
      () async {
        final path = dbPath();
        final legacyDb = await databaseFactoryFfi.openDatabase(
          path,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              await db.execute('''
              CREATE TABLE ${NotesDatabase.tableName} (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                lesson_id INTEGER NOT NULL,
                content TEXT NOT NULL,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
              )
            ''');
              await db.insert(NotesDatabase.tableName, {
                'lesson_id': 5,
                'content': 'legacy note',
                'created_at': 1,
                'updated_at': 1,
              });
            },
          ),
        );
        await legacyDb.close();

        final database = NotesDatabase.forTesting(
          factory: databaseFactoryFfi,
          databasePath: path,
        );
        final db = await database.database;

        final before = await db.query(NotesDatabase.tableName);
        expect(before, hasLength(1));
        expect(before.single['content'], 'legacy note');
        expect(before.single['user_id'], NotesDatabase.legacyUserId);

        final claimed = await database.claimLegacyNotes('user-1');
        expect(claimed, 1);

        final after = await db.query(
          NotesDatabase.tableName,
          where: 'lesson_id = ?',
          whereArgs: [5],
        );
        expect(after.single['user_id'], 'user-1');

        // Claiming twice is a no-op.
        expect(await database.claimLegacyNotes('user-1'), 0);

        await database.close();
      },
    );
  });

  group('per-user note isolation', () {
    test('each user only sees and mutates their own notes', () async {
      final database = NotesDatabase.forTesting(
        factory: databaseFactoryFfi,
        databasePath: dbPath(),
      );
      final userOne = repoFor(database, 'user-1');
      final userTwo = repoFor(database, 'user-2');

      await userOne.addNote(5, 'user one note');
      await userTwo.addNote(5, 'user two note');

      final oneNotes = await userOne.getNotes(5);
      final twoNotes = await userTwo.getNotes(5);

      expect(oneNotes.map((note) => note.content), ['user one note']);
      expect(twoNotes.map((note) => note.content), ['user two note']);

      // User one cannot delete user two's note.
      await userOne.deleteNote(twoNotes.single.id);
      expect(await userTwo.getNotes(5), hasLength(1));

      // User one cannot update user two's note.
      await userOne.updateNote(twoNotes.single, 'hijacked');
      expect((await userTwo.getNotes(5)).single.content, 'user two note');

      await database.close();
    });

    test('legacy notes become visible only to the claiming user', () async {
      final path = dbPath();
      final legacyDb = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE ${NotesDatabase.tableName} (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                lesson_id INTEGER NOT NULL,
                content TEXT NOT NULL,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
              )
            ''');
            await db.insert(NotesDatabase.tableName, {
              'lesson_id': 5,
              'content': 'old note',
              'created_at': 1,
              'updated_at': 1,
            });
          },
        ),
      );
      await legacyDb.close();

      final database = NotesDatabase.forTesting(
        factory: databaseFactoryFfi,
        databasePath: path,
      );

      final first = await repoFor(database, 'user-1').getNotes(5);
      final second = await repoFor(database, 'user-2').getNotes(5);

      expect(first.map((note) => note.content), ['old note']);
      expect(second, isEmpty);

      await database.close();
    });

    test('requires an authenticated user id', () async {
      final database = NotesDatabase.forTesting(
        factory: databaseFactoryFfi,
        databasePath: dbPath(),
      );
      final repository = repoFor(database, null);

      await expectLater(
        repository.getNotes(1),
        throwsA(isA<SessionException>()),
      );

      await database.close();
    });
  });
}
