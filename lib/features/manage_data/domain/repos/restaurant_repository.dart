import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/restaurant_entity.dart';

/// Abstract contract — implemented in the data layer.
abstract class RestaurantRepository {
  /// Fetch all restaurants for the current user from Firestore.
  Future<Either<Failure, List<RestaurantEntity>>> fetchRestaurants(
      String userEmail);

  /// Add a new restaurant to Firestore (image already uploaded → imageUrl set).
  Future<Either<Failure, RestaurantEntity>> addRestaurant(
      RestaurantEntity entity);

  /// Update an existing restaurant document in Firestore.
  Future<Either<Failure, RestaurantEntity>> updateRestaurant(
      RestaurantEntity entity);

  /// Delete a restaurant document from Firestore.
  Future<Either<Failure, void>> deleteRestaurant(String docId);

  /// Upload an image file to Supabase and return the public URL.
  Future<Either<Failure, String>> uploadImage(
      String filePath, String fileName);
}