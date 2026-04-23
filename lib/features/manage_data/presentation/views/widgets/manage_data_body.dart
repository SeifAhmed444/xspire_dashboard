import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/services/user_session.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/restaurant_entity.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/cubit/restaurant_cubit.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/views/widgets/restaurant_card.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/views/widgets/restaurant_form_sheet.dart';

class ManageDataBody extends StatelessWidget {
  const ManageDataBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RestaurantCubit, RestaurantState>(
      listener: (context, state) {
        if (state is RestaurantOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(state.message),
            ]),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        }
        if (state is RestaurantError && state.message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      builder: (context, state) {
        // ── Full-screen loading (initial fetch) ──────────────────────────
        if (state is RestaurantLoading) {
          return const Center(
            child:
                CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        // ── Empty ────────────────────────────────────────────────────────
        if (state is RestaurantEmpty) {
          return _EmptyState(
            onAdd: () => _showAddSheet(context),
          );
        }

        // ── Error with no data yet ────────────────────────────────────────
        if (state is RestaurantError && state.restaurants.isEmpty) {
          return _ErrorState(
            message: state.message,
            onRetry: () => context
                .read<RestaurantCubit>()
                .fetchRestaurants(UserSession.instance.currentEmail),
          );
        }

        // ── Extract list from any state that carries one ──────────────────
        final List<RestaurantEntity> list = switch (state) {
          RestaurantLoaded s => s.restaurants,
          RestaurantOperationLoading s => s.restaurants,
          RestaurantOperationSuccess s => s.restaurants,
          RestaurantError s => s.restaurants,
          _ => [],
        };

        // ── Overlay spinner for item-level operations ─────────────────────
        final String? busyId = state is RestaurantOperationLoading
            ? state.operationId
            : null;

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () => context
              .read<RestaurantCubit>()
              .fetchRestaurants(UserSession.instance.currentEmail),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: list.length,
            itemBuilder: (_, index) => RestaurantCard(
              restaurant: list[index],
              isBusy: busyId == list[index].docId,
              onEdit: () => _showEditSheet(context, list[index]),
              onDelete: () => _confirmDelete(context, list[index]),
            ),
          ),
        );
      },
    );
  }

  void _showAddSheet(BuildContext context) {
    final cubit = context.read<RestaurantCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const RestaurantFormSheet(),
      ),
    );
  }

  void _showEditSheet(BuildContext context, RestaurantEntity entity) {
    final cubit = context.read<RestaurantCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: RestaurantFormSheet(existing: entity),
      ),
    );
  }

  void _confirmDelete(BuildContext context, RestaurantEntity entity) {
    final cubit = context.read<RestaurantCubit>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.errorColor, size: 24),
          SizedBox(width: 10),
          Text('Delete Restaurant'),
        ]),
        content: Text(
          'Delete "${entity.name}"? This cannot be undone.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.primaryColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              if (entity.docId != null) {
                cubit.deleteRestaurant(entity.docId!);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
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
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.store_outlined,
                size: 50,
                color: AppColors.primaryColor.withOpacity(0.35)),
          ),
          const SizedBox(height: 20),
          const Text('No Restaurants Yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 8),
          Text('Tap the button below to add your first restaurant.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Restaurant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
            ),
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
          Icon(Icons.error_outline_rounded,
              size: 60, color: AppColors.errorColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }
}