// lib/features/products/presentation/widgets/product_card_actions.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';
import 'package:xspire_dashboard/features/add_product/presentation/manager/cubit/add_product_cubit.dart';
import 'package:xspire_dashboard/features/products/presentation/views/edit_product_view.dart';

class ProductCardActions extends StatelessWidget {
  const ProductCardActions({super.key, required this.product});
  final AddProductInputEntity product;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Edit ──
        _EditButton(product: product),
        const SizedBox(height: 8),
        // ── Delete ──
        if (product.docId != null) _DeleteButton(product: product),
      ],
    );
  }
}

// ── Edit Button ───────────────────────────────────────────────────────────────
class _EditButton extends StatelessWidget {
  const _EditButton({required this.product});
  final AddProductInputEntity product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => EditProductView(product: product),
          ),
        );
        if (updated == true && context.mounted) {
          context.read<AddProductCubit>().getProducts();
        }
      },
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Edit Restaurant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Delete Button ─────────────────────────────────────────────────────────────
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.product});
  final AddProductInputEntity product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDeleteDialog(context),
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.errorColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.errorColor.withOpacity(0.25)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded,
                color: AppColors.errorColor, size: 16),
            SizedBox(width: 8),
            Text(
              'Delete Restaurant',
              style: TextStyle(
                color: AppColors.errorColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Restaurant'),
        content: Text(
          'Are you sure you want to delete "${product.name}"?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // ✅ الـ success + reload بيتعملوا في الـ listener في products_list_body
              context
                  .read<AddProductCubit>()
                  .deleteProduct(product.docId!);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}