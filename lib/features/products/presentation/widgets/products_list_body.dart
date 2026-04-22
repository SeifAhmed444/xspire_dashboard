import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/services/user_session.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/features/products/presentation/cubit/product_cubit.dart';
import 'package:xspire_dashboard/features/products/presentation/widgets/product_card.dart';

class ProductsListBody extends StatelessWidget {
  const ProductsListBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {
        if (state is ProductError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
        if (state is DeleteProductSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Product deleted successfully'),
            ]),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
          context.read<ProductCubit>().getProducts(UserSession.instance.currentUserId);
        }
      },
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (state is GetProductsSuccess) {
          if (state.products.isEmpty) {
            return _EmptyState(
              onAdd: () async {
                final added = await Navigator.pushNamed(context, 'add_item');
                if (added == true && context.mounted) {
                  context.read<ProductCubit>().getProducts(UserSession.instance.currentUserId);
                }
              },
            );
          }
          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () async => context
                .read<ProductCubit>()
                .getProducts(UserSession.instance.currentUserId),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: state.products.length,
              itemBuilder: (_, index) => ProductCard(product: state.products[index]),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined, size: 54,
                color: AppColors.primaryColor.withOpacity(0.35)),
          ),
          const SizedBox(height: 24),
          const Text('No Products Yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 8),
          Text('Tap the button below to add your first product.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}