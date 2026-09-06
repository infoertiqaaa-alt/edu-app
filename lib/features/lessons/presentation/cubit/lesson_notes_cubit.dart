import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/lesson_note_model.dart';
import '../../domain/repositories/lesson_notes_repository.dart';
import 'lesson_notes_state.dart';

class LessonNotesCubit extends Cubit<LessonNotesState> {
  final LessonNotesRepository _repository;

  LessonNotesCubit(this._repository) : super(LessonNotesInitial());

  Future<void> loadNotes(int lessonId) async {
    emit(LessonNotesLoading());
    try {
      final notes = await _repository.getNotes(lessonId);
      emit(LessonNotesLoaded(notes));
    } catch (e) {
      emit(LessonNotesError('حدث خطأ أثناء تحميل الملاحظات'));
    }
  }

  Future<void> addNote(int lessonId, String content) async {
    try {
      await _repository.addNote(lessonId, content);
      await loadNotes(lessonId);
    } catch (e) {
      emit(LessonNotesError('حدث خطأ أثناء إضافة الملاحظة'));
    }
  }

  Future<void> updateNote(LessonNote note, String content) async {
    try {
      await _repository.updateNote(note, content);
      await loadNotes(note.lessonId);
    } catch (e) {
      emit(LessonNotesError('حدث خطأ أثناء تعديل الملاحظة'));
    }
  }

  Future<void> deleteNote(LessonNote note) async {
    try {
      await _repository.deleteNote(note.id);
      await loadNotes(note.lessonId);
    } catch (e) {
      emit(LessonNotesError('حدث خطأ أثناء حذف الملاحظة'));
    }
  }
}