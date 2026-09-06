import '../../data/datasources/notes_database.dart';
import '../../data/models/lesson_note_model.dart';
import '../../domain/repositories/lesson_notes_repository.dart';

class LessonNotesRepositoryImpl implements LessonNotesRepository {
  final NotesDatabase _database;

  LessonNotesRepositoryImpl(this._database);

  @override
  Future<List<LessonNote>> getNotes(int lessonId) async {
    final db = await _database.database;
    final rows = await db.query(
      NotesDatabase.tableName,
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
      orderBy: 'updated_at DESC',
    );
    return rows.map(LessonNote.fromMap).toList();
  }

  @override
  Future<void> addNote(int lessonId, String content) async {
    final db = await _database.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(NotesDatabase.tableName, {
      'lesson_id': lessonId,
      'content': content,
      'created_at': now,
      'updated_at': now,
    });
  }

  @override
  Future<void> updateNote(LessonNote note, String content) async {
    final db = await _database.database;
    await db.update(
      NotesDatabase.tableName,
      {
        'content': content,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> deleteNote(int noteId) async {
    final db = await _database.database;
    await db.delete(
      NotesDatabase.tableName,
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }
}