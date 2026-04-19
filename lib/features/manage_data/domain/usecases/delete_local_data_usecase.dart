// lib/features/manage_data/domain/usecases/delete_local_data_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/features/manage_data/domain/repos/manage_data_repo.dart';

class DeleteLocalDataUseCase {
  final ManageDataRepo repo;

  DeleteLocalDataUseCase(this.repo);

  Future<Either<Failure, void>> call(String id) {
    return repo.deleteLocalData(id);
  }
}
