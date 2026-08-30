import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher/core/network/network_exceptions.dart';
import '../../domain/repositories/scan_qr_repository.dart';
import 'scan_qr_state.dart';

/// نفس الـ instance بتتشارك بين الشاشات التلاتة (زرار المسح -> الكاميرا -> النتيجة)
/// عن طريق BlocProvider.value لما ننتقل بين الشاشات، عشان النتيجة تفضل
/// موجودة لحد ما نوصل لشاشة عرض بيانات الطالب.
class ScanQrCubit extends Cubit<ScanQrState> {
  final ScanQrRepository _repository;

  ScanQrCubit(this._repository) : super(ScanQrInitial());

  Future<void> scanAndFetch(String qrCodeString) async {
    emit(ScanQrLoading());
    final result = await _repository.scanStudent(qrCodeString);
    result.fold(
      (failure) => emit(ScanQrError(failure.message)),
      (student) => emit(ScanQrSuccess(student)),
    );
  }

  Future<Failure?> registerAttendance(int studentId) async {
    final result = await _repository.registerAttendance(studentId);
    return result.fold((failure) => failure, (_) => null);
  }

  void reset() => emit(ScanQrInitial());
}
