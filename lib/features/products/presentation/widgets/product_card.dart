// lib/features/products/presentation/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';
import 'package:xspire_dashboard/features/products/presentation/widgets/product_card_actions.dart';
import 'package:xspire_dashboard/features/products/presentation/widgets/product_card_image.dart';
import 'package:xspire_dashboard/features/products/presentation/widgets/product_meta_chip.dart';
import 'package:xspire_dashboard/features/products/presentation/widgets/product_state_badge.dart';
import 'package:xspire_dashboard/core/domain/usecases/business_hours_use_case.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final AddProductInputEntity product;

  @override
  Widget build(BuildContext context) {
    // ✅ حالة الفتح من الـ UseCase مش من الـ model
    final bool isOpen = const BusinessHoursUseCase().isCurrentlyOpen();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── الصورة ──
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: ProductCardImage(imageUrl: product.imageUrl),
          ),

          // ── المعلومات ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الاسم + الـ badges
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // ✅ من الـ UseCase
                        ProductStatusBadge(
                          label: isOpen ? 'Open' : 'Closed',
                          color: isOpen
                              ? AppColors.successColor
                              : AppColors.errorColor,
                        ),
                        const SizedBox(height: 4),
                        ProductStatusBadge(
                          label: product.isAvailable ? 'Available' : 'N/A',
                          color: product.isAvailable
                              ? AppColors.primaryColor
                              : AppColors.grey,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // الـ meta chips
                Row(
                  children: [
                    ProductMetaChip(
                      icon: Icons.location_on_outlined,
                      label: product.distance,
                      color: AppColors.secoundryColor,
                    ),
                    const SizedBox(width: 10),
                    ProductMetaChip(
                      icon: Icons.store_mall_directory_outlined,
                      label: '${product.branches} branches',
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 12),

                // ✅ أزرار Edit + Delete
                ProductCardActions(product: product),
              ],
            ),
          ),
        ],
      ),
    );
  }
}