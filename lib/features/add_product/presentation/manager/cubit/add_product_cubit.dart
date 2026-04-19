import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xspire_dashboard/core/repos/image_repo/image_repo.dart';
import 'package:xspire_dashboard/core/repos/product_repo/products_repo.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';

part 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  AddProductCubit(this.imageRepo, this.productsRepo)
      : super(AddProductInitial());

  final ImageRepo imageRepo;
  final ProductsRepo productsRepo;

  Future<void> addProduct(AddProductInputEntity addProductInputEntity) async {
    emit(AddProductLoading());
    try {
      if (addProductInputEntity.image == null) {
        emit(AddProductFailure("Please select an image"));
        return;
      }

      var result = await imageRepo.uploadImage(addProductInputEntity.image!);

      result.fold(
        (f) => emit(AddProductFailure(f.message)),
        (url) async {
          addProductInputEntity.imageUrl = url;

          var result = await productsRepo.addProduct(addProductInputEntity);

          result.fold(
            (f) => emit(AddProductFailure(f.message)),
            (r) async {
              // ✅ حفظ محلي في SharedPreferences بعد نجاح الرفع
              final prefs = await SharedPreferences.getInstance();
              final raw = prefs.getString('cached_restaurants') ?? '[]';
              final List list = jsonDecode(raw);
              list.add({
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'name': addProductInputEntity.name,
                'branches': addProductInputEntity.branches,
                'distance': addProductInputEntity.distance,
                'isOpend': addProductInputEntity.isOpend,
                'isAvailable': addProductInputEntity.isAvailable,
                'imageUrl': addProductInputEntity.imageUrl,
              });
              await prefs.setString('cached_restaurants', jsonEncode(list));
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
    String docId,
    AddProductInputEntity addProductInputEntity,
  ) async {
    emit(AddProductLoading());
    try {
      if (addProductInputEntity.image != null) {
        var imageResult =
            await imageRepo.uploadImage(addProductInputEntity.image!);

        imageResult.fold(
          (f) => emit(AddProductFailure(f.message)),
          (url) => addProductInputEntity.imageUrl = url,
        );

        if (state is AddProductFailure) return;
      }

      var result =
          await productsRepo.updateProduct(docId, addProductInputEntity);

      result.fold(
        (f) => emit(AddProductFailure(f.message)),
        (r) => emit(UpdateProductSuccess()),
      );
    } catch (e) {
      emit(AddProductFailure("Unexpected error while updating product"));
    }
  }

  Future<void> getProducts() async {
    emit(AddProductLoading());
    var result = await productsRepo.getProducts();
    result.fold(
      (f) => emit(AddProductFailure(f.message)),
      (products) => emit(GetProductsSuccess(products)),
    );
  }
}