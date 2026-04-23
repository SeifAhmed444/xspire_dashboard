import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:xspire_dashboard/core/errors/failures.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/restaurant_entity.dart';
import 'package:xspire_dashboard/features/manage_data/domain/repos/restaurant_repository.dart';

// ── Fetch ─────────────────────────────────────────────────────────────────────
class FetchRestaurantsUseCase {
  final RestaurantRepository repo;
  const FetchRestaurantsUseCase(this.repo);

  Future<Either<Failure, List<RestaurantEntity>>> call(String userEmail) =>
      repo.fetchRestaurants(userEmail);
}

// ── Add ───────────────────────────────────────────────────────────────────────
class AddRestaurantUseCase {
  final RestaurantRepository repo;
  const AddRestaurantUseCase(this.repo);

  Future<Either<Failure, RestaurantEntity>> call(RestaurantEntity entity) =>
      repo.addRestaurant(entity);
}

// ── Update ────────────────────────────────────────────────────────────────────
class UpdateRestaurantUseCase {
  final RestaurantRepository repo;
  const UpdateRestaurantUseCase(this.repo);

  Future<Either<Failure, RestaurantEntity>> call(RestaurantEntity entity) =>
      repo.updateRestaurant(entity);
}

// ── Delete ────────────────────────────────────────────────────────────────────
class DeleteRestaurantUseCase {
  final RestaurantRepository repo;
  const DeleteRestaurantUseCase(this.repo);

  Future<Either<Failure, void>> call(String docId) =>
      repo.deleteRestaurant(docId);
}

// ── Upload Image ──────────────────────────────────────────────────────────────
class UploadRestaurantImageUseCase {
  final RestaurantRepository repo;
  const UploadRestaurantImageUseCase(this.repo);

  Future<Either<Failure, String>> call(File file) =>
      repo.uploadImage(file.path, file.path.split('/').last);
}