import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/exceptions.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/features/manage_data/data/datasources/restaurant_remote_datasource.dart';
import 'package:xspire_dashboard/features/manage_data/data/models/restaurant_model.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/restaurant_entity.dart';
import 'package:xspire_dashboard/features/manage_data/domain/repos/restaurant_repository.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDatasource remoteDatasource;

  const RestaurantRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<RestaurantEntity>>> fetchRestaurants(
      String userEmail) async {
    try {
      final models = await remoteDatasource.fetchRestaurants(userEmail);
      return Right(models.map((m) => m.toEntity()).toList());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, RestaurantEntity>> addRestaurant(
      RestaurantEntity entity) async {
    try {
      final model = await remoteDatasource
          .addRestaurant(RestaurantModel.fromEntity(entity));
      return Right(model.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, RestaurantEntity>> updateRestaurant(
      RestaurantEntity entity) async {
    try {
      final model = await remoteDatasource
          .updateRestaurant(RestaurantModel.fromEntity(entity));
      return Right(model.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRestaurant(String docId) async {
    try {
      await remoteDatasource.deleteRestaurant(docId);
      return const Right(null);
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(
      String filePath, String fileName) async {
    try {
      final url = await remoteDatasource.uploadImage(filePath, fileName);
      return Right(url);
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}