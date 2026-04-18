part of 'add_product_cubit.dart';

@immutable
sealed class AddProductState {}

final class AddProductInitial extends AddProductState {}

final class AddProductLoading extends AddProductState {}

final class AddProductFailure extends AddProductState {
  final String errMessage;
  AddProductFailure(this.errMessage);
}

final class AddProductSuccess extends AddProductState {}

final class GetProductsSuccess extends AddProductState {
  final List<AddProductInputEntity> products;
  GetProductsSuccess(this.products);
}

final class UpdateProductSuccess extends AddProductState {}
