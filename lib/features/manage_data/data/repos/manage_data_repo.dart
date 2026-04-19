// lib/features/manage_data/domain/repos/manage_data_repo.dart

import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/local_data_entity.dart';

abstract class ManageDataRepo {
  Future<Either<Failure, List<LocalDataEntity>>> getLocalData();
  Future<Either<Failure, void>> deleteLocalData(String id);
}
