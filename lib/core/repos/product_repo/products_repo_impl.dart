import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/core/repos/product_repo/products_repo.dart';
import 'package:xspire_dashboard/core/services/database_services.dart';
import 'package:xspire_dashboard/core/utils/backend_endpoints.dart';
import 'package:xspire_dashboard/features/add_product/data/models/add_product_input_model.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';

class ProductsRepoImpl implements ProductsRepo {
  @override
  final DatabaseServies databaseServies;

  ProductsRepoImpl(this.databaseServies);
  Future<Either<Failure, void>> addProduct(
    AddProductInputEntity addProductInputEntity,
  ) async {
    try {
      await databaseServies.addData(
        path: BackendEndpoints.productCollection,
        data: AddProductInputModel.fromEntity(AddProductInputEntity).toJson(),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to add product'));
    }
  }
}
