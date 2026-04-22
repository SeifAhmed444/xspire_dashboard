// lib/features/products/presentation/widgets/products_list_body.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/features/add_product/presentation/manager/cubit/add_product_cubit.dart';
import 'package:xspire_dashboard/features/products/presentation/widgets/product_card.dart';
import 'package:xspire_dashboard/features/products/presentation/widgets/product_empty_state.dart';


class ProductsListBody extends StatelessWidget {
  const ProductsListBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddProductCubit, AddProductState>(
      listener: (context, state) {
        if (state is AddProductFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errMessage),
              backgroundColor: AppColors.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }

        // ✅ بعد الحذف نجلب الـ list تاني
        if (state is DeleteProductSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Restaurant deleted successfully'),
                ],
              ),
              backgroundColor: AppColors.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.read<AddProductCubit>().getProducts();
        }
      },
      builder: (context, state) {
        if (state is AddProductLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (state is GetProductsSuccess) {
          if (state.products.isEmpty) return const ProductsEmptyState();

          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () async =>
                context.read<AddProductCubit>().getProducts(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              itemCount: state.products.length,
              itemBuilder: (_, index) => ProductCard(
                product: state.products[index],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}