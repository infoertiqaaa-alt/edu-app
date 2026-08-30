import 'package:dartz/dartz.dart';
import 'package:teacher/core/network/network_exceptions.dart';
import '../../data/models/scanned_student_model.dart';

abstract class ScanQrRepository {
  Future<Either<Failure, ScannedStudentModel>> scanStudent(String qrCodeString);
  Future<Either<Failure, void>> registerAttendance(int studentId);
}
