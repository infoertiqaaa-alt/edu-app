import 'package:dartz/dartz.dart';
import '../../../../core/network/network_exceptions.dart';
import '../repositories/update_repository.dart';
import '../../data/models/release_model.dart';

class GetLatestRelease {
  final UpdateRepository _repository;

  GetLatestRelease(this._repository);

  Future<Either<Failure, ReleaseModel>> call() =>
      _repository.getLatestRelease();
}
