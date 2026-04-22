import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:xspire_dashboard/features/products/domain/entities/product_entity.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/add_product_usecase.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/get_products_usecase.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/update_product_usecase.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final AddProductUseCase addProductUseCase;
  final GetProductsUseCase getProductsUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  ProductCubit({
    required this.addProductUseCase,
    required this.getProductsUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  }) : super(ProductInitial());

  Future<void> getProducts(String userId) async {
    emit(ProductLoading());
    final result = await getProductsUseCase(userId);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(GetProductsSuccess(products)),
    );
  }

  Future<void> addProduct(ProductEntity product) async {
    emit(ProductLoading());
    final result = await addProductUseCase(product);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(AddProductSuccess()),
    );
  }

  Future<void> updateProduct(String id, ProductEntity product) async {
    emit(ProductLoading());
    final result = await updateProductUseCase(id, product);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(UpdateProductSuccess()),
    );
  }

  Future<void> deleteProduct(String id) async {
    emit(ProductLoading());
    final result = await deleteProductUseCase(id);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(DeleteProductSuccess()),
    );
  }
}
