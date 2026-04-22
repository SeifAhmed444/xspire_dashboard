// lib/features/add_product/presentation/manager/cubit/add_product_cubit.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xspire_dashboard/core/domain/usecases/business_hours_use_case.dart';
import 'package:xspire_dashboard/core/repos/image_repo/image_repo.dart';
import 'package:xspire_dashboard/core/repos/product_repo/products_repo.dart';
import 'package:xspire_dashboard/core/services/user_session.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';

part 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  AddProductCubit(this.imageRepo, this.productsRepo)
      : super(AddProductInitial());

  final ImageRepo imageRepo;
  final ProductsRepo productsRepo;
  final _businessHours = const BusinessHoursUseCase();

  // ─────────────────────────────────────────────
  // Add
  // ─────────────────────────────────────────────
  Future<void> addProduct(AddProductInputEntity entity) async {
    emit(AddProductLoading());
    try {
      if (entity.image == null) {
        emit(AddProductFailure("Please select an image"));
        return;
      }

      // ✅ ربط البيانات بالمستخدم + حالة الفتح التلقائية
      entity.userEmail = UserSession.instance.currentEmail;
      entity.isOpend   = _businessHours.isCurrentlyOpen();

      final imageResult = await imageRepo.uploadImage(entity.image!);

      await imageResult.fold(
        (failure) async => emit(AddProductFailure(failure.message)),
        (url) async {
          entity.imageUrl = url;

          final result = await productsRepo.addProduct(entity);
          result.fold(
            (failure) => emit(AddProductFailure(failure.message)),
            (_) async {
              await _cacheLocally(entity);
              emit(AddProductSuccess());
            },
          );
        },
      );
    } catch (e) {
      emit(AddProductFailure("Unexpected error while uploading image"));
    }
  }

  
  Future<void> updateProduct(
      String docId, AddProductInputEntity entity) async {
    emit(AddProductLoading());
    try {
      if (entity.image != null) {
        final imageResult = await imageRepo.uploadImage(entity.image!);

        // لو رفع الصورة فشل نوقف هنا
        bool imageFailed = false;
        imageResult.fold(
          (failure) {
            emit(AddProductFailure(failure.message));
            imageFailed = true;
          },
          (url) => entity.imageUrl = url,
        );
        if (imageFailed) return;
      }

      final result = await productsRepo.updateProduct(docId, entity);
      result.fold(
        (failure) => emit(AddProductFailure(failure.message)),
        (_)       => emit(UpdateProductSuccess()),
      );
    } catch (e) {
      emit(AddProductFailure("Unexpected error while updating product"));
    }
  }


  Future<void> getProducts() async {
    emit(AddProductLoading());

    final email = UserSession.instance.isLoggedIn
        ? UserSession.instance.currentEmail
        : null;

    final result = await productsRepo.getProducts(userEmail: email);
    result.fold(
      (failure) => emit(AddProductFailure(failure.message)),
      (products) => emit(GetProductsSuccess(products)),
    );
  }

  Future<void> deleteProduct(String docId) async {
    emit(AddProductLoading());

    final result = await productsRepo.deleteProduct(docId);
    result.fold(
      (failure) => emit(AddProductFailure(failure.message)),
      (_)       => emit(DeleteProductSuccess()),
    );
  }

  Future<void> _cacheLocally(AddProductInputEntity entity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw   = prefs.getString('cached_restaurants') ?? '[]';
      final list  = jsonDecode(raw) as List;

      list.add({
        'id'         : DateTime.now().millisecondsSinceEpoch.toString(),
        'name'       : entity.name,
        'branches'   : entity.branches,
        'distance'   : entity.distance,
        'isOpend'    : entity.isOpend,
        'isAvailable': entity.isAvailable,
        'imageUrl'   : entity.imageUrl,
        'userEmail'  : entity.userEmail,
      });

      await prefs.setString('cached_restaurants', jsonEncode(list));
    } catch (_) {
      // الكاش اختياري — لو فشل منوقفش الـ flow
    }
  }
}