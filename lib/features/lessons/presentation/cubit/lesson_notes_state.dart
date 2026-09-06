import 'package:equatable/equatable.dart';
import '../../data/models/lesson_note_model.dart';

abstract class LessonNotesState extends Equatable {
  const LessonNotesState();
  @override
  List<Object?> get props => [];
}

class LessonNotesInitial extends LessonNotesState {}

class LessonNotesLoading extends LessonNotesState {}

class LessonNotesLoaded extends LessonNotesState {
  final List<LessonNote> notes;
  const LessonNotesLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

class LessonNotesError extends LessonNotesState {
  final String message;
  const LessonNotesError(this.message);

  @override
  List<Object?> get props => [message];
}