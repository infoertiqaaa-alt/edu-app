import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/lessons_repository.dart';
import 'lesson_detail_state.dart';

class LessonDetailCubit extends Cubit<LessonDetailState> {
  final LessonsRepository _lessonsRepository;

  LessonDetailCubit(this._lessonsRepository) : super(LessonDetailInitial());

  Future<void> getLessonDetail(int id) async {
    emit(LessonDetailLoading());
    final result = await _lessonsRepository.getLessonDetail(id);
    result.fold(
      (failure) => emit(LessonDetailError(failure.message)),
      (lesson) => emit(LessonDetailLoaded(lesson)),
    );
  }
}
