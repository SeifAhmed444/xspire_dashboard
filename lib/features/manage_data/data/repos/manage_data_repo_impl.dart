import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/exceptions.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/features/manage_data/data/datasources/manage_data_local_datasource.dart';
import 'package:xspire_dashboard/features/manage_data/domain/repos/manage_data_repo.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/local_data_entity.dart';

class ManageDataRepoImpl implements ManageDataRepo {
  final ManageDataLocalDatasource localDatasource;

  ManageDataRepoImpl(this.localDatasource);

  @override
  Future<Either<Failure, List<LocalDataEntity>>> getLocalData() async {
    try {
      final data = await localDatasource.getLocalData();
      return Right(data);
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLocalData(String id) async {
    try {
      await localDatasource.deleteLocalData(id);
      return const Right(null);
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}