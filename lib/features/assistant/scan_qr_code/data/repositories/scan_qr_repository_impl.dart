import 'package:dartz/dartz.dart';
import 'package:teacher/core/network/network_exceptions.dart';
import '../../domain/repositories/scan_qr_repository.dart';
import '../datasources/scan_qr_remote_data_source.dart';
import '../models/scanned_student_model.dart';

class ScanQrRepositoryImpl implements ScanQrRepository {
  final ScanQrRemoteDataSource remoteDataSource;

  ScanQrRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ScannedStudentModel>> scanStudent(
      String qrCodeString) async {
    try {
      final student = await remoteDataSource.scanStudent(qrCodeString);
      return Right(student);
    } catch (e) {
      return Left(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> registerAttendance(int studentId) async {
    try {
      await remoteDataSource.registerAttendance(studentId);
      return const Right(null);
    } catch (e) {
      return Left(NetworkExceptions.handle(e));
    }
  }
}
