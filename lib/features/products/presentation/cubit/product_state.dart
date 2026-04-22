part of 'product_cubit.dart';

@immutable
sealed class ProductState {}

final class ProductInitial extends ProductState {}

final class ProductLoading extends ProductState {}

final class AddProductSuccess extends ProductState {}

final class UpdateProductSuccess extends ProductState {}

final class DeleteProductSuccess extends ProductState {}

final class GetProductsSuccess extends ProductState {
  final List<ProductEntity> products;
  GetProductsSuccess(this.products);
}

final class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
