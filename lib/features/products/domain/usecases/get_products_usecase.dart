import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/features/products/domain/entities/product_entity.dart';
import 'package:xspire_dashboard/features/products/domain/repos/product_repo.dart';

class GetProductsUseCase {
  final ProductRepo repo;
  GetProductsUseCase(this.repo);

  Future<Either<Failure, List<ProductEntity>>> call(String userId) =>
      repo.getProducts(userId);
}
