import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/services/get_it_services.dart';
import 'package:xspire_dashboard/core/services/user_session.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/add_product_usecase.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/get_products_usecase.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/update_product_usecase.dart';
import 'package:xspire_dashboard/features/products/presentation/cubit/product_cubit.dart';
import 'package:xspire_dashboard/features/products/presentation/views/add_item_view.dart';
import 'package:xspire_dashboard/features/products/presentation/widgets/products_list_body.dart';

class ProductsListView extends StatelessWidget {
  const ProductsListView({super.key});
  static const routeName = 'products_list';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductCubit(
        addProductUseCase: getIt<AddProductUseCase>(),
        getProductsUseCase: getIt<GetProductsUseCase>(),
        updateProductUseCase: getIt<UpdateProductUseCase>(),
        deleteProductUseCase: getIt<DeleteProductUseCase>(),
      )..getProducts(UserSession.instance.currentUserId),
      child: const _ProductsListScaffold(),
    );
  }
}

class _ProductsListScaffold extends StatelessWidget {
  const _ProductsListScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('My Products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context
                .read<ProductCubit>()
                .getProducts(UserSession.instance.currentUserId),
          ),
        ],
      ),
      body: const ProductsListBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.pushNamed(
              context, AddItemView.routeName);
          if (added == true && context.mounted) {
            context
                .read<ProductCubit>()
                .getProducts(UserSession.instance.currentUserId);
          }
        },
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Product',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}