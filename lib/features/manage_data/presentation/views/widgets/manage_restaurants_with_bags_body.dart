import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/repos/product_repo/products_repo.dart';
import 'package:xspire_dashboard/core/services/get_it_services.dart';
import 'package:xspire_dashboard/core/services/user_session.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/restaurant_entity.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/cubit/restaurant_cubit.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/views/widgets/restaurant_form_sheet.dart';

class ManageRestaurantsWithBagsBody extends StatefulWidget {
  const ManageRestaurantsWithBagsBody({super.key});

  @override
  State<ManageRestaurantsWithBagsBody> createState() => _ManageRestaurantsWithBagsBodyState();
}

class _ManageRestaurantsWithBagsBodyState extends State<ManageRestaurantsWithBagsBody> {
  final ProductsRepo _productsRepo = getIt<ProductsRepo>();
  Map<String, List<AddProductInputEntity>> _restaurantBags = {};
  bool _isLoadingBags = false;

  bool _bagsLoaded = false;

  @override
  void initState() {
    super.initState();
    // Don't load bags here - wait for restaurants to load in build
  }

  Future<void> _loadBagsForRestaurants(List<RestaurantEntity> restaurants) async {
    if (_bagsLoaded) return; // Already loaded
    
    setState(() => _isLoadingBags = true);
    
    final bagsMap = <String, List<AddProductInputEntity>>{};
    
    for (final restaurant in restaurants) {
      if (restaurant.docId != null) {
        final result = await _productsRepo.getProductsByRestaurant(
          restaurantId: restaurant.docId!,
        );
        result.fold(
          (failure) => bagsMap[restaurant.docId!] = [],
          (bags) => bagsMap[restaurant.docId!] = bags,
        );
      }
    }
    
    if (mounted) {
      setState(() {
        _restaurantBags = bagsMap;
        _isLoadingBags = false;
        _bagsLoaded = true;
      });
    }
  }

  Future<void> _refresh(List<RestaurantEntity> restaurants) async {
    setState(() => _bagsLoaded = false); // Reset to reload bags
    context.read<RestaurantCubit>().fetchRestaurants(UserSession.instance.currentEmail);
    await _loadBagsForRestaurants(restaurants);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RestaurantCubit, RestaurantState>(
      listener: (context, state) {
        if (state is RestaurantOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(state.message),
            ]),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
          // Reload bags after successful operation
          setState(() => _bagsLoaded = false);
        }
        if (state is RestaurantError && state.message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      builder: (context, state) {
        if (state is RestaurantLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }

        if (state is RestaurantEmpty) {
          return _EmptyState(onAdd: () => _showAddSheet(context));
        }

        final restaurants = switch (state) {
          RestaurantLoaded s => s.restaurants,
          RestaurantOperationLoading s => s.restaurants,
          RestaurantOperationSuccess s => s.restaurants,
          RestaurantError s => s.restaurants,
          _ => <RestaurantEntity>[],
        };

        if (state is RestaurantError && restaurants.isEmpty) {
          return _ErrorState(
            message: state.message,
            onRetry: () => _refresh(restaurants),
          );
        }

        final busyId = state is RestaurantOperationLoading ? state.operationId : null;

        // Load bags when restaurants are first loaded
        if (restaurants.isNotEmpty && !_bagsLoaded && !_isLoadingBags) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadBagsForRestaurants(restaurants);
          });
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () => _refresh(restaurants),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: restaurants.length,
            itemBuilder: (_, index) {
              final restaurant = restaurants[index];
              final bags = _restaurantBags[restaurant.docId] ?? [];
              
              return _RestaurantWithBagsCard(
                restaurant: restaurant,
                bags: bags,
                isBusy: busyId == restaurant.docId,
                isLoadingBags: _isLoadingBags,
                onEdit: () => _showEditSheet(context, restaurant),
                onDelete: () => _confirmDelete(context, restaurant),
              );
            },
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.errorColor, size: 24),
          SizedBox(width: 10),
          Text('Delete Restaurant'),
        ]),
        content: Text('Delete "${entity.name}"? This cannot be undone.', style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.primaryColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              if (entity.docId != null) cubit.deleteRestaurant(entity.docId!);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _RestaurantWithBagsCard extends StatelessWidget {
  final RestaurantEntity restaurant;
  final List<AddProductInputEntity> bags;
  final bool isBusy;
  final bool isLoadingBags;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RestaurantWithBagsCard({
    required this.restaurant,
    required this.bags,
    required this.isBusy,
    this.isLoadingBags = false,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Restaurant Header ─────────────────────────────────────
          _RestaurantHeader(
            restaurant: restaurant,
            isBusy: isBusy,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
          
          // ── Available Bags Section ─────────────────────────────────
          if (isLoadingBags) ...[
            // Loading indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Loading bags...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (bags.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Available bags',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${bags.length} bag${bags.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // ── Vertical List of Bag Cards ───────────────────────────
            ...bags.map((bag) => _BagCard(bag: bag)),
            
            const SizedBox(height: 12),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: Colors.grey.shade400),
                    const SizedBox(width: 12),
                    Text(
                      'No bags available yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RestaurantHeader extends StatelessWidget {
  final RestaurantEntity restaurant;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RestaurantHeader({
    required this.restaurant,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        image: restaurant.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(restaurant.imageUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.3),
                  BlendMode.darken,
                ),
              )
            : null,
        gradient: restaurant.imageUrl == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Badges Row ────────────────────────────────────────────
            Row(
              children: [
                // Available Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: restaurant.isAvailable ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.isAvailable ? 'Available' : 'Unavailable',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Now Badge (Open/Closed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: restaurant.isOpend ? Colors.orange : Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        restaurant.isOpend ? Icons.access_time_filled : Icons.access_time,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.isOpend ? 'Now' : 'Closed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // ── Logo + Name Row ───────────────────────────────────────
            Row(
              children: [
                // Logo placeholder or actual logo
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: restaurant.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            restaurant.imageUrl!,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          ),
                        )
                      : const Icon(Icons.restaurant, color: Color(0xFF2C3E50)),
                ),
                const SizedBox(width: 12),
                // Name and Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.store, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.branchesDisplay,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.location_on, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.branchLocation,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: isBusy ? null : onEdit,
                      icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                    ),
                    IconButton(
                      onPressed: isBusy ? null : onDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BagCard extends StatelessWidget {
  final AddProductInputEntity bag;

  const _BagCard({required this.bag});

  @override
  Widget build(BuildContext context) {
    final oldPrice = bag.oldPrice ?? bag.price;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Bag Image ─────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: bag.imageUrl != null
                ? Image.network(
                    bag.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
          
          // ── Bag Info ──────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  bag.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Pickup Time
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        bag.pickupTime ?? 'Pickup 9:00 AM - 11:59 PM',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // ── Price & Bags Left Row ────────────────────────────
                Row(
                  children: [
                    // Bags Left Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 12, color: Colors.orange.shade600),
                          const SizedBox(width: 2),
                          Text(
                            '${bag.bagsLeft} left',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Old Price
                    if (oldPrice > bag.price)
                      Text(
                        '${oldPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    
                    // New Price
                    Text(
                      '${bag.price.toStringAsFixed(0)} EGP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // ── Reserve Button ────────────────────────────────────────
          ElevatedButton(
            onPressed: () {
              // Reserve action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Reserve',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

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
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.store_outlined, size: 50, color: AppColors.primaryColor.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          const Text('No Restaurants Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Add your first restaurant to start selling bags.', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Restaurant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: AppColors.errorColor.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
