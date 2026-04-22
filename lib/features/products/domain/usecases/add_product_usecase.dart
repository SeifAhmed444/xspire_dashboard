import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/features/products/domain/entities/product_entity.dart';
import 'package:xspire_dashboard/features/products/domain/repos/product_repo.dart';

class AddProductUseCase {
  final ProductRepo repo;
  AddProductUseCase(this.repo);

  Future<Either<Failure, void>> call(ProductEntity product) =>
      repo.addProduct(product);
}
