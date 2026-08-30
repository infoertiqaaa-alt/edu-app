import 'package:equatable/equatable.dart';

abstract class AutoAuthState extends Equatable {
  const AutoAuthState();

  @override
  List<Object?> get props => [];
}

class AutoAuthInitial extends AutoAuthState {}

class AutoAuthLoading extends AutoAuthState {}

class AutoAuthAuthenticated extends AutoAuthState {
  final String role;

  const AutoAuthAuthenticated(this.role);

  @override
  List<Object?> get props => [role];
}

class AutoAuthUnauthenticated extends AutoAuthState {}
