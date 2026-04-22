import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/features/products/domain/entities/product_entity.dart';
import 'package:xspire_dashboard/features/products/presentation/cubit/product_cubit.dart';
import 'package:xspire_dashboard/features/products/presentation/views/edit_product_view.dart';

class ProductCardActions extends StatelessWidget {
  const ProductCardActions({super.key, required this.product});
  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Edit button
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => EditProductView(product: product)),
              );
              if (updated == true && context.mounted) {
                // Refresh is handled in products_list_view via Navigator.pop(true)
                // The parent BlocConsumer listening to UpdateProductSuccess will handle it
              }
            },
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryColor.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3)),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('Edit', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Delete button
        if (product.id != null)
          Expanded(
            child: GestureDetector(
              onTap: () => _showDeleteDialog(context),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline_rounded, color: AppColors.errorColor, size: 16),
                    SizedBox(width: 6),
                    Text('Delete', style: TextStyle(color: AppColors.errorColor, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.errorColor, size: 24),
          SizedBox(width: 10),
          Text('Delete Product'),
        ]),
        content: Text(
          'Are you sure you want to delete "${product.name}"?\nThis action cannot be undone.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.primaryColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<ProductCubit>().deleteProduct(product.id!);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}