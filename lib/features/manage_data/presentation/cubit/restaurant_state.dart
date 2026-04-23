part of 'restaurant_cubit.dart';

sealed class RestaurantState {}

// ── Initial ───────────────────────────────────────────────────────────────────
final class RestaurantInitial extends RestaurantState {}

// ── Loading (full-screen spinner) ─────────────────────────────────────────────
final class RestaurantLoading extends RestaurantState {}

// ── Loaded — holds the local list ────────────────────────────────────────────
final class RestaurantLoaded extends RestaurantState {
  final List<RestaurantEntity> restaurants;
  RestaurantLoaded(this.restaurants);
}

// ── Empty ─────────────────────────────────────────────────────────────────────
final class RestaurantEmpty extends RestaurantState {}

// ── Item-level operation in progress (non-blocking) ──────────────────────────
final class RestaurantOperationLoading extends RestaurantState {
  final List<RestaurantEntity> restaurants; // keep showing current list
  final String? operationId;               // docId being processed
  RestaurantOperationLoading(this.restaurants, {this.operationId});
}

// ── Success toast (after add / update / delete) ───────────────────────────────
final class RestaurantOperationSuccess extends RestaurantState {
  final List<RestaurantEntity> restaurants;
  final String message;
  RestaurantOperationSuccess(this.restaurants, this.message);
}

// ── Error ─────────────────────────────────────────────────────────────────────
final class RestaurantError extends RestaurantState {
  final String message;
  final List<RestaurantEntity> restaurants; // keep showing stale data
  RestaurantError(this.message, {this.restaurants = const []});
}