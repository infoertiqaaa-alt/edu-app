import 'package:equatable/equatable.dart';
import '../../data/models/scanned_student_model.dart';

abstract class ScanQrState extends Equatable {
  const ScanQrState();
  @override
  List<Object?> get props => [];
}

class ScanQrInitial extends ScanQrState {}

class ScanQrLoading extends ScanQrState {}

class ScanQrSuccess extends ScanQrState {
  final ScannedStudentModel student;
  const ScanQrSuccess(this.student);

  @override
  List<Object?> get props => [student];
}

class ScanQrError extends ScanQrState {
  final String message;
  const ScanQrError(this.message);

  @override
  List<Object?> get props => [message];
}
