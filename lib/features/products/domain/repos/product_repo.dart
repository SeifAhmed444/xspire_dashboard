import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/features/products/domain/entities/product_entity.dart';

abstract class ProductRepo {
  Future<Either<Failure, void>> addProduct(ProductEntity product);
  Future<Either<Failure, List<ProductEntity>>> getProducts(String userId);
  Future<Either<Failure, void>> updateProduct(String id, ProductEntity product);
  Future<Either<Failure, void>> deleteProduct(String id);
}
