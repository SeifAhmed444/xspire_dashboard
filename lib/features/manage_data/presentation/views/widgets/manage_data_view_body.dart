// lib/features/manage_data/presentation/views/widgets/manage_data_view_body.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/local_data_entity.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/manager/manage_data_cubit.dart';

class ManageDataViewBody extends StatelessWidget {
  const ManageDataViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManageDataCubit, ManageDataState>(
      listener: (context, state) {
        if (state is ManageDataError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        // ── Loading ──────────────────────────────────────────────────────
        if (state is ManageDataLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        // ── Empty ────────────────────────────────────────────────────────
        if (state is ManageDataEmpty) {
          return _EmptyState();
        }

        // ── Loaded ───────────────────────────────────────────────────────
        if (state is ManageDataLoaded) {
          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () =>
                context.read<ManageDataCubit>().loadLocalData(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              itemCount: state.items.length,
              itemBuilder: (context, index) => _LocalDataCard(
                item: state.items[index],
              ),
            ),
          );
        }

        // ── Error ────────────────────────────────────────────────────────
        if (state is ManageDataError) {
          return _ErrorState(
            message: state.message,
            onRetry: () => context.read<ManageDataCubit>().loadLocalData(),
          );
        }

        return const SizedBox();
      },
    );
  }
}

// ── Local Data Card ───────────────────────────────────────────────────────────
class _LocalDataCard extends StatelessWidget {
  const _LocalDataCard({required this.item});
  final LocalDataEntity item;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image / Icon ──
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _ItemThumbnail(imageUrl: item.imageUrl),
            ),
            const SizedBox(width: 14),

            // ── Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.store_mall_directory_outlined,
                    label: '${item.branches} branches',
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: item.distance,
                    color: AppColors.secoundryColor,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatusBadge(
                        label: item.isOpend ? 'Open' : 'Closed',
                        color: item.isOpend
                            ? AppColors.successColor
                            : AppColors.errorColor,
                      ),
                      const SizedBox(width: 6),
                      _StatusBadge(
                        label: item.isAvailable ? 'Available' : 'N/A',
                        color: item.isAvailable
                            ? AppColors.primaryColor
                            : AppColors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Delete Button ──
            _DeleteButton(itemId: item.id, itemName: item.name),
          ],
        ),
      ),
    );
  }
}

// ── Delete Button with Confirmation ──────────────────────────────────────────
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.itemId, required this.itemName});
  final String itemId;
  final String itemName;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _confirmDelete(context),
      icon: const Icon(Icons.delete_outline_rounded),
      color: AppColors.errorColor,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.errorColor.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ManageDataCubit>().deleteItem(itemId);
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

// ── Thumbnail ─────────────────────────────────────────────────────────────────
class _ItemThumbnail extends StatelessWidget {
  const _ItemThumbnail({required this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 70,
      height: 70,
      color: const Color(0xFFF0F4F3),
      child: Icon(
        Icons.restaurant_rounded,
        color: AppColors.primaryColor.withOpacity(0.3),
        size: 30,
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.color,
  });
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
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
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
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 50,
              color: AppColors.primaryColor.withOpacity(0.35),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Local Data Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data will appear here after adding restaurants',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 60,
            color: AppColors.errorColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
