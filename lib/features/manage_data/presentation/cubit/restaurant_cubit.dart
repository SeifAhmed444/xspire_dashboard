import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/restaurant_entity.dart';
import 'package:xspire_dashboard/features/manage_data/domain/usecases/restaurant_usecases.dart';

part 'restaurant_state.dart';

class RestaurantCubit extends Cubit<RestaurantState> {
  RestaurantCubit({
    required this.fetchRestaurantsUseCase,
    required this.addRestaurantUseCase,
    required this.updateRestaurantUseCase,
    required this.deleteRestaurantUseCase,
    required this.uploadImageUseCase,
  }) : super(RestaurantInitial());

  final FetchRestaurantsUseCase fetchRestaurantsUseCase;
  final AddRestaurantUseCase addRestaurantUseCase;
  final UpdateRestaurantUseCase updateRestaurantUseCase;
  final DeleteRestaurantUseCase deleteRestaurantUseCase;
  final UploadRestaurantImageUseCase uploadImageUseCase;

  // In-memory local list — single source of truth for the UI
  List<RestaurantEntity> _localList = [];

  List<RestaurantEntity> get currentList => List.unmodifiable(_localList);

  // ── Fetch (on screen load) ────────────────────────────────────────────────
  Future<void> fetchRestaurants(String userEmail) async {
    emit(RestaurantLoading());
    final result = await fetchRestaurantsUseCase(userEmail);
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (list) {
        _localList = list;
        _emitListState();
      },
    );
  }

  // ── Add ───────────────────────────────────────────────────────────────────
  Future<void> addRestaurant({
    required String name,
    required String branches,
    required String distance,
    required bool isOpend,
    required bool isAvailable,
    required String userEmail,
    File? imageFile,
    String? existingImageUrl,
  }) async {
    emit(RestaurantOperationLoading(_localList));
    try {
      // 1. Upload image if a new file was chosen
      String? imageUrl = existingImageUrl;
      if (imageFile != null) {
        final uploadResult = await uploadImageUseCase(imageFile);
        bool uploadFailed = false;
        uploadResult.fold(
          (failure) {
            emit(RestaurantError(failure.message, restaurants: _localList));
            uploadFailed = true;
          },
          (url) => imageUrl = url,
        );
        if (uploadFailed) return;
      }

      // 2. Build entity and persist
      final entity = RestaurantEntity(
        name: name,
        branches: branches,
        distance: distance,
        isOpend: isOpend,
        isAvailable: isAvailable,
        imageUrl: imageUrl,
        userEmail: userEmail,
      );

      final result = await addRestaurantUseCase(entity);
      result.fold(
        (failure) =>
            emit(RestaurantError(failure.message, restaurants: _localList)),
        (saved) {
          // 3. Optimistic local update
          _localList = [saved, ..._localList];
          emit(RestaurantOperationSuccess(_localList, 'Restaurant added successfully'));
        },
      );
    } catch (e) {
      emit(RestaurantError('Unexpected error: $e', restaurants: _localList));
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────
  Future<void> updateRestaurant({
    required RestaurantEntity existing,
    required String name,
    required String branches,
    required String distance,
    required bool isOpend,
    required bool isAvailable,
    File? newImageFile,
  }) async {
    emit(RestaurantOperationLoading(_localList,
        operationId: existing.docId));
    try {
      // 1. Upload new image if provided
      String? imageUrl = existing.imageUrl;
      if (newImageFile != null) {
        final uploadResult = await uploadImageUseCase(newImageFile);
        bool uploadFailed = false;
        uploadResult.fold(
          (failure) {
            emit(RestaurantError(failure.message, restaurants: _localList));
            uploadFailed = true;
          },
          (url) => imageUrl = url,
        );
        if (uploadFailed) return;
      }

      final updated = existing.copyWith(
        name: name,
        branches: branches,
        distance: distance,
        isOpend: isOpend,
        isAvailable: isAvailable,
        imageUrl: imageUrl,
      );

      final result = await updateRestaurantUseCase(updated);
      result.fold(
        (failure) =>
            emit(RestaurantError(failure.message, restaurants: _localList)),
        (saved) {
          // 2. Replace in local list
          _localList = _localList
              .map((r) => r.docId == saved.docId ? saved : r)
              .toList();
          emit(RestaurantOperationSuccess(
              _localList, 'Restaurant updated successfully'));
        },
      );
    } catch (e) {
      emit(RestaurantError('Unexpected error: $e', restaurants: _localList));
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<void> deleteRestaurant(String docId) async {
    // Optimistic removal first
    final backup = List<RestaurantEntity>.from(_localList);
    _localList = _localList.where((r) => r.docId != docId).toList();
    _emitListState(
        override: RestaurantOperationLoading(_localList, operationId: docId));

    final result = await deleteRestaurantUseCase(docId);
    result.fold(
      (failure) {
        // Roll back
        _localList = backup;
        emit(RestaurantError(failure.message, restaurants: _localList));
      },
      (_) => emit(
          RestaurantOperationSuccess(_localList, 'Restaurant deleted')),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _emitListState({RestaurantState? override}) {
    if (override != null) {
      emit(override);
      return;
    }
    if (_localList.isEmpty) {
      emit(RestaurantEmpty());
    } else {
      emit(RestaurantLoaded(_localList));
    }
  }
}