
import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/core/repos/product_repo/products_repo.dart';
import 'package:xspire_dashboard/core/services/database_services.dart';
import 'package:xspire_dashboard/core/utils/backend_endpoints.dart';
import 'package:xspire_dashboard/features/add_product/data/models/add_product_input_model.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';

class ProductsRepoImpl implements ProductsRepo {
  final DatabaseServies databaseServies;

  ProductsRepoImpl(this.databaseServies);

  @override
  Future<Either<Failure, void>> addProduct(
    AddProductInputEntity entity,
  ) async {
    try {
      await databaseServies.addData(
        path: BackendEndpoints.productCollection,
        data: AddProductInputModel.fromEntity(entity).toJson(),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to add product'));
    }
  }

  @override
  Future<Either<Failure, List<AddProductInputEntity>>> getProducts({
    String? userEmail,
  }) async {
    try {
      final Map<String, dynamic>? query = userEmail != null
          ? {'where': 'userEmail', 'isEqualTo': userEmail}
          : null;

      final data = await databaseServies.getData(
        path: BackendEndpoints.productCollection,
        query: query,
      );

      final List<AddProductInputEntity> products = (data as List)
          .map((item) => AddProductInputModel.fromJson(
                item as Map<String, dynamic>,
              ).toEntity())
          .toList();

      return Right(products);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch products'));
    }
  }

  @override
  Future<Either<Failure, List<AddProductInputEntity>>> getProductsByRestaurant({
    required String restaurantId,
  }) async {
    try {
      final data = await databaseServies.getData(
        path: BackendEndpoints.productCollection,
        query: {'where': 'restaurantId', 'isEqualTo': restaurantId},
      );

      final List<AddProductInputEntity> products = (data as List)
          .map((item) => AddProductInputModel.fromJson(
                item as Map<String, dynamic>,
              ).toEntity())
          .toList();

      return Right(products);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch products for restaurant'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(
    String docId,
    AddProductInputEntity entity,
  ) async {
    try {
      await databaseServies.updateData(
        path: BackendEndpoints.productCollection,
        documentId: docId,
        data: AddProductInputModel.fromEntity(entity).toJson(),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update product'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String docId) async {
    try {
      await databaseServies.deleteData(
        path: BackendEndpoints.productCollection,
        documentId: docId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete product'));
    }
  }
}