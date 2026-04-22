import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/features/products/domain/repos/product_repo.dart';

class DeleteProductUseCase {
  final ProductRepo repo;
  DeleteProductUseCase(this.repo);

  Future<Either<Failure, void>> call(String id) => repo.deleteProduct(id);
}
