import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
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
    // ✅ check if image is null before uploading
    if (addProductInputEntity.image == null) {
      emit(AddProductFailure("Please select an image"));
      return;
    }

    var result = await imageRepo.uploadImage(addProductInputEntity.image!); // ← add !

    result.fold(
      (f) {
        emit(AddProductFailure(f.message));
      },
      (url) async {
        addProductInputEntity.imageUrl = url;

        var result = await productsRepo.addProduct(addProductInputEntity);

        result.fold(
          (f) => emit(AddProductFailure(f.message)),
          (r) => emit(AddProductSuccess()),
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
    // if admin picked a new image → upload it first
    if (addProductInputEntity.image != null) {
      var imageResult = await imageRepo.uploadImage(
        addProductInputEntity.image!,
      );

      imageResult.fold(
        (f) {
          emit(AddProductFailure(f.message));
          return;
        },
        (url) {
          addProductInputEntity.imageUrl = url;
        },
      );

      // stop here if image upload failed
      if (state is AddProductFailure) return;
    }
    // if no new image → keep the existing imageUrl as is

    var result = await productsRepo.updateProduct(docId, addProductInputEntity);

    result.fold(
      (f) => emit(AddProductFailure(f.message)),
      (r) => emit(UpdateProductSuccess()),
    );
  } catch (e) {
    emit(AddProductFailure("Unexpected error while updating product"));
  }
}

  getProducts() {}
}
