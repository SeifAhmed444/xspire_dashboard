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
    if (isClosed) return;
    emit(RestaurantLoading());
    final result = await fetchRestaurantsUseCase(userEmail);
    if (isClosed) return;
    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (list) {
        _localList = list;
        _emitListState();
      },
    );
  }

  // ── Add multiple restaurants (one per branch) ─────────────────────────────
  Future<void> addRestaurantsWithBranches({
    required String name,
    required List<String> branchLocations,
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

      final totalBranches = branchLocations.length;
      final savedRestaurants = <RestaurantEntity>[];

      // 2. Create a restaurant for each branch
      for (int i = 0; i < branchLocations.length; i++) {
        final entity = RestaurantEntity(
          name: name,
          branchLocation: branchLocations[i],
          totalBranches: totalBranches,
          branchIndex: i + 1,
          isOpend: isOpend,
          isAvailable: isAvailable,
          imageUrl: imageUrl,
          userEmail: userEmail,
        );

        final result = await addRestaurantUseCase(entity);
        final success = result.fold(
          (failure) {
            emit(RestaurantError(failure.message, restaurants: _localList));
            return null;
          },
          (saved) => saved,
        );
        
        if (success != null) {
          savedRestaurants.add(success);
        }
      }

      // 3. Optimistic local update with all saved restaurants
      if (savedRestaurants.isNotEmpty) {
        _localList = [...savedRestaurants, ..._localList];
        final msg = savedRestaurants.length == 1
            ? 'Restaurant added successfully'
            : '${savedRestaurants.length} branches added successfully';
        emit(RestaurantOperationSuccess(_localList, msg));
      }
    } catch (e) {
      emit(RestaurantError('Unexpected error: $e', restaurants: _localList));
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────
  Future<void> updateRestaurant({
    required RestaurantEntity existing,
    required String name,
    required String branchLocation,
    required int totalBranches,
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
        branchLocation: branchLocation,
        totalBranches: totalBranches,
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
      (_) {
        if (!isClosed) {
          emit(RestaurantOperationSuccess(_localList, 'Restaurant deleted'));
        }
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _emitListState({RestaurantState? override}) {
    if (isClosed) return;
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