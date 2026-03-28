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
      var result = await imageRepo.uploadImage(addProductInputEntity.image);

      result.fold(
        (f) {
          print("Image upload failed: ${f.message}");
          emit(AddProductFailure(f.message));
        },
        (url) async {
          print("Image uploaded successfully, URL = $url");
          addProductInputEntity.imageUrl = url;

          try {
            var result = await productsRepo.addProduct(addProductInputEntity);

            result.fold(
              (f) {
                print("Product add failed: ${f.message}");
                emit(AddProductFailure(f.message));
              },
              (r) {
                print("Product added successfully");
                emit(AddProductSuccess());
              },
            );
          } catch (e, st) {
            print("Exception in productsRepo.addProduct: $e");
            print(st);
            emit(AddProductFailure("Unexpected error while adding product"));
          }
        },
      );
    } catch (e, st) {
      print("Exception in imageRepo.uploadImage: $e");
      print(st);
      emit(AddProductFailure("Unexpected error while uploading image"));
    }
  }
}
