import '../../data/models/lesson_note_model.dart';

abstract class LessonNotesRepository {
  Future<List<LessonNote>> getNotes(int lessonId);
  Future<void> addNote(int lessonId, String content);
  Future<void> updateNote(LessonNote note, String content);
  Future<void> deleteNote(int noteId);
}