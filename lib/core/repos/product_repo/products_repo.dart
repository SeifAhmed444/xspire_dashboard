import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';

abstract class ProductsRepo {
  Future<Either<Failure, void>> addProduct(
    AddProductInputEntity addProductInputEntity,
  );

  Future<Either<Failure, List<AddProductInputEntity>>> getProducts();

  Future<Either<Failure, void>> updateProduct(
    String docId,
    AddProductInputEntity addProductInputEntity,
  );
}
