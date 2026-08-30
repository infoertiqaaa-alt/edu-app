import 'package:equatable/equatable.dart';
import '../../data/models/lesson_detail_model.dart';

abstract class LessonDetailState extends Equatable {
  const LessonDetailState();
  @override
  List<Object?> get props => [];
}

class LessonDetailInitial extends LessonDetailState {}

class LessonDetailLoading extends LessonDetailState {}

class LessonDetailLoaded extends LessonDetailState {
  final LessonDetailModel lesson;
  const LessonDetailLoaded(this.lesson);

  @override
  List<Object?> get props => [lesson];
}

class LessonDetailError extends LessonDetailState {
  final String message;
  const LessonDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
