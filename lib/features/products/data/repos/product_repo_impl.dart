import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/features/products/data/models/product_model.dart';
import 'package:xspire_dashboard/features/products/domain/entities/product_entity.dart';
import 'package:xspire_dashboard/features/products/domain/repos/product_repo.dart';

class ProductRepoImpl implements ProductRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'products';

  @override
  Future<Either<Failure, void>> addProduct(ProductEntity product) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final model = ProductModel.fromEntity(product);
      await docRef.set({...model.toJson(), 'id': docRef.id});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to add product: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return Right(products);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch products: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(
      String id, ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(product);
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(model.toUpdateJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update product: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete product: $e'));
    }
  }
}
