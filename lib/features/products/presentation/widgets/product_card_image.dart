// lib/features/products/presentation/widgets/product_card_image.dart
import 'package:flutter/material.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';

class ProductCardImage extends StatelessWidget {
  const ProductCardImage({super.key, required this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _placeholder(),
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0xFFF0F4F3),
      child: Icon(
        Icons.restaurant_rounded,
        size: 52,
        color: AppColors.primaryColor.withOpacity(0.25),
      ),
    );
  }
}