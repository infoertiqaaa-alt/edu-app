import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/student_profile_model.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  StudentProfileModel? _lastLoaded;
  bool _isLoading = false;

  ProfileCubit(this._profileRepository) : super(ProfileInitial());

  Future<void> getProfile({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      // Keep showing the current profile while an explicit refresh is running.
      if (_lastLoaded == null) emit(ProfileLoading());

      final result = await _profileRepository.getProfile(
        forceRefresh: forceRefresh,
      );

      result.fold(
        (failure) {
          if (_lastLoaded != null) {
            emit(ProfileLoaded(_lastLoaded!, isStale: true));
          } else {
            emit(ProfileError(failure.message));
          }
        },
        (profile) {
          _lastLoaded = profile;
          emit(ProfileLoaded(profile));
        },
      );
    } finally {
      _isLoading = false;
    }
  }
}
