import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/lessons_repository.dart';
import 'lessons_state.dart';

class LessonsCubit extends Cubit<LessonsState> {
  final LessonsRepository _lessonsRepository;

  LessonsCubit(this._lessonsRepository) : super(LessonsInitial());

  Future<void> getLessons() async {
    emit(LessonsLoading());
    final result = await _lessonsRepository.getLessons();
    result.fold(
      (failure) => emit(LessonsError(failure.message)),
      (lessons) => emit(LessonsLoaded(lessons)),
    );
  }
}
