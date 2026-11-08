import 'package:mr/core/network/network_exceptions.dart';
import 'package:mr/core/storage/token_storage.dart';

import '../../data/datasources/notes_database.dart';
import '../../data/models/lesson_note_model.dart';
import '../../domain/repositories/lesson_notes_repository.dart';

class LessonNotesRepositoryImpl implements LessonNotesRepository {
  final NotesDatabase _database;
  final TokenStorage _tokenStorage;

  LessonNotesRepositoryImpl(this._database, this._tokenStorage);

  Future<String> _requireUserId() async {
    final userId = (await _tokenStorage.getUserId())?.trim();
    if (userId == null || userId.isEmpty) {
      throw const SessionException('يجب تسجيل الدخول لعرض ملاحظاتك المحفوظة.');
    }
    return userId;
  }

  @override
  Future<List<LessonNote>> getNotes(int lessonId) async {
    final userId = await _requireUserId();
    await _database.claimLegacyNotes(userId);

    final db = await _database.database;
    final rows = await db.query(
      NotesDatabase.tableName,
      where: 'lesson_id = ? AND user_id = ?',
      whereArgs: [lessonId, userId],
      orderBy: 'updated_at DESC',
    );
    return rows.map(LessonNote.fromMap).toList();
  }

  @override
  Future<void> addNote(int lessonId, String content) async {
    final userId = await _requireUserId();
    await _database.claimLegacyNotes(userId);

    final db = await _database.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(NotesDatabase.tableName, {
      'lesson_id': lessonId,
      'user_id': userId,
      'content': content,
      'created_at': now,
      'updated_at': now,
    });
  }

  @override
  Future<void> updateNote(LessonNote note, String content) async {
    final userId = await _requireUserId();
    final db = await _database.database;
    await db.update(
      NotesDatabase.tableName,
      {'content': content, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ? AND user_id = ?',
      whereArgs: [note.id, userId],
    );
  }

  @override
  Future<void> deleteNote(int noteId) async {
    final userId = await _requireUserId();
    final db = await _database.database;
    await db.delete(
      NotesDatabase.tableName,
      where: 'id = ? AND user_id = ?',
      whereArgs: [noteId, userId],
    );
  }
}
