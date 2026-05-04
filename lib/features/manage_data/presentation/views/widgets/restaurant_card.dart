import 'package:flutter/material.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/restaurant_entity.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
  });

  final RestaurantEntity restaurant;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isBusy ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
            // ── Image ──────────────────────────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: _RestaurantImage(imageUrl: restaurant.imageUrl),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Name + status badges ──────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.displayName,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(
                        label: restaurant.isOpend ? 'Open' : 'Closed',
                        color: restaurant.isOpend
                            ? AppColors.successColor
                            : AppColors.errorColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ── Meta info ─────────────────────────────────────────
                  _InfoRow(
                    icon: Icons.store_mall_directory_outlined,
                    label: restaurant.branchesDisplay,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 3),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: restaurant.branchLocation,
                    color: AppColors.secoundryColor,
                  ),
                  const SizedBox(height: 3),
                  _InfoRow(
                    icon: Icons.check_circle_outline_rounded,
                    label: restaurant.isAvailable ? 'Available' : 'Not Available',
                    color: restaurant.isAvailable
                        ? AppColors.primaryColor
                        : AppColors.grey,
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 10),

                  // ── Actions ───────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Edit',
                          icon: Icons.edit_rounded,
                          gradient: AppColors.primaryGradient,
                          onTap: isBusy ? null : onEdit,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          label: 'Delete',
                          icon: Icons.delete_outline_rounded,
                          color: AppColors.errorColor,
                          onTap: isBusy ? null : onDelete,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Image ─────────────────────────────────────────────────────────────────────
class _RestaurantImage extends StatelessWidget {
  const _RestaurantImage({required this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _placeholder(loading: true),
      );
    }
    return _placeholder();
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      height: 160,
      width: double.infinity,
      color: const Color(0xFFF0F4F3),
      child: loading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            )
          : Icon(Icons.restaurant_rounded,
              size: 48, color: AppColors.primaryColor.withOpacity(0.2)),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    this.gradient,
    this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final LinearGradient? gradient;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isGradient = gradient != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: isGradient ? gradient : null,
          color: isGradient ? null : color?.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: isGradient
              ? null
              : Border.all(color: color?.withOpacity(0.3) ?? Colors.grey),
          boxShadow: isGradient
              ? [
                  BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isGradient ? Colors.white : color, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                  color: isGradient ? Colors.white : color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}