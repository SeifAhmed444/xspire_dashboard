// lib/features/manage_data/domain/usecases/get_local_data_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/local_data_entity.dart';
import 'package:xspire_dashboard/features/manage_data/domain/repos/manage_data_repo.dart';

class GetLocalDataUseCase {
  final ManageDataRepo repo;

  GetLocalDataUseCase(this.repo);

  Future<Either<Failure, List<LocalDataEntity>>> call() {
    return repo.getLocalData();
  }
}
