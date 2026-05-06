import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/core/repos/product_repo/products_repo.dart';
import 'package:xspire_dashboard/core/services/database_services.dart';
import 'package:xspire_dashboard/core/utils/backend_endpoints.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xspire_dashboard/features/add_product/data/models/add_product_input_model.dart';
import 'package:uuid/uuid.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';

class ProductsRepoImpl implements ProductsRepo {
  final DatabaseServies databaseServies;

  ProductsRepoImpl(this.databaseServies);

  @override
  Future<Either<Failure, void>> addProduct(AddProductInputEntity entity) async {
    try {
      // Must have restaurantId to nest product under restaurant
      final restaurantId = entity.restaurantId;
      if (restaurantId == null || restaurantId.isEmpty) {
        return Left(ServerFailure('restaurantId is required to add product'));
      }

      final productId = entity.productId ?? const Uuid().v4();
      final dataMap = AddProductInputModel.fromEntity(entity).toJson();
      dataMap['productId'] = productId;
      dataMap['docId'] = productId;

      // Add product into `products` array inside the restaurant document
      await databaseServies.updateData(
        path: BackendEndpoints.resturantCollection,
        documentId: restaurantId,
        data: {
          'products': FieldValue.arrayUnion([dataMap]),
        },
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
      // Fetch restaurant documents (optionally filter by userEmail) and aggregate products
      final Map<String, dynamic>? query = userEmail != null
          ? {'where': 'userEmail', 'isEqualTo': userEmail}
          : null;

      final restaurantsData = await databaseServies.getData(
        path: BackendEndpoints.resturantCollection,
        query: query,
      );

      final List<AddProductInputEntity> products = [];
      for (final r in (restaurantsData as List)) {
        final Map<String, dynamic> rest = r as Map<String, dynamic>;
        final restId = rest['docId'] as String?;
        final items = rest['products'] as List<dynamic>?;
        if (items != null) {
          for (final p in items) {
            final Map<String, dynamic> pm = Map<String, dynamic>.from(p);
            pm['restaurantId'] = pm['restaurantId'] ?? restId;
            products.add(AddProductInputModel.fromJson(pm).toEntity());
          }
        }
      }

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
        path: BackendEndpoints.resturantCollection,
        docuementId: restaurantId,
      );

      if (data is Map<String, dynamic>) {
        final items = data['products'] as List<dynamic>?;
        final List<AddProductInputEntity> products = (items ?? [])
            .map(
              (e) => AddProductInputModel.fromJson(
                Map<String, dynamic>.from(e),
              ).toEntity(),
            )
            .toList();
        return Right(products);
      }

      return const Right([]);
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
      // Find the restaurant that contains this product and replace it
      final restaurants = await databaseServies.getData(
        path: BackendEndpoints.resturantCollection,
      );
      bool updated = false;
      for (final r in (restaurants as List)) {
        final Map<String, dynamic> rest = r as Map<String, dynamic>;
        final restId = rest['docId'] as String?;
        final items = rest['products'] as List<dynamic>?;
        if (items == null) continue;
        final List<Map<String, dynamic>> newItems = items
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        for (int i = 0; i < newItems.length; i++) {
          if (newItems[i]['productId'] == docId) {
            final newMap = AddProductInputModel.fromEntity(entity).toJson();
            newMap['productId'] = docId;
            newMap['docId'] = docId;
            newItems[i] = newMap;
            await databaseServies.updateData(
              path: BackendEndpoints.resturantCollection,
              documentId: restId!,
              data: {'products': newItems},
            );
            updated = true;
            break;
          }
        }
        if (updated) break;
      }

      if (!updated) return Left(ServerFailure('Product not found'));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update product'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String docId) async {
    try {
      // Find the restaurant that contains this product and remove it
      final restaurants = await databaseServies.getData(
        path: BackendEndpoints.resturantCollection,
      );
      bool deleted = false;
      for (final r in (restaurants as List)) {
        final Map<String, dynamic> rest = r as Map<String, dynamic>;
        final restId = rest['docId'] as String?;
        final items = rest['products'] as List<dynamic>?;
        if (items == null) continue;
        final List<Map<String, dynamic>> newItems = items
            .map((e) => Map<String, dynamic>.from(e))
            .where((m) => m['productId'] != docId)
            .toList();
        if (newItems.length != items.length) {
          await databaseServies.updateData(
            path: BackendEndpoints.resturantCollection,
            documentId: restId!,
            data: {'products': newItems},
          );
          deleted = true;
          break;
        }
      }

      if (!deleted) return Left(ServerFailure('Product not found'));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete product'));
    }
  }
}
