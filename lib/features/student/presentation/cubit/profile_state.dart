import 'package:equatable/equatable.dart';
import '../../data/models/student_profile_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final StudentProfileModel profile;

  /// True when the displayed profile comes from cache because a refresh failed.
  final bool isStale;

  const ProfileLoaded(this.profile, {this.isStale = false});

  @override
  List<Object?> get props => [profile, isStale];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
