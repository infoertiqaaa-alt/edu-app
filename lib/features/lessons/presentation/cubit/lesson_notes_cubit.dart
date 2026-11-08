import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mr/core/network/network_exceptions.dart';
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
    } catch (error) {
      emit(LessonNotesError(_messageFor(error, 'تحميل')));
    }
  }

  Future<void> addNote(int lessonId, String content) async {
    try {
      await _repository.addNote(lessonId, content);
      await loadNotes(lessonId);
    } catch (error) {
      emit(LessonNotesError(_messageFor(error, 'إضافة')));
    }
  }

  Future<void> updateNote(LessonNote note, String content) async {
    try {
      await _repository.updateNote(note, content);
      await loadNotes(note.lessonId);
    } catch (error) {
      emit(LessonNotesError(_messageFor(error, 'تعديل')));
    }
  }

  Future<void> deleteNote(LessonNote note) async {
    try {
      await _repository.deleteNote(note.id);
      await loadNotes(note.lessonId);
    } catch (error) {
      emit(LessonNotesError(_messageFor(error, 'حذف')));
    }
  }

  String _messageFor(Object error, String action) {
    if (error is SessionException) return error.message;
    return 'حدث خطأ أثناء $action الملاحظة';
  }
}
