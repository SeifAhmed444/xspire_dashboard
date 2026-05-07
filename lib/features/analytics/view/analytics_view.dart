// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:math' show min;
import 'package:xspire_dashboard/core/services/get_it_services.dart' show getIt;
import 'package:xspire_dashboard/core/repos/product_repo/products_repo.dart';
import 'package:xspire_dashboard/features/manage_data/domain/usecases/restaurant_usecases.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/restaurant_entity.dart';
import 'package:xspire_dashboard/core/services/user_session.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';

class AnalyticsView extends StatefulWidget {
  static const routeName = '/analytics';
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  final FetchRestaurantsUseCase _fetch = getIt<FetchRestaurantsUseCase>();
  final ProductsRepo _productsRepo = getIt<ProductsRepo>();
  bool _loading = true;
  String? _error;
  List<RestaurantEntity> _restaurants = [];
  Map<String, List<AddProductInputEntity>> _productsByRestaurant = {};

  // Aggregates
  int totalProducts = 0;
  int totalReviews = 0;
  double averageRating = 0.0;
  List<_ReviewWithContext> latestReviews = [];
  List<MapEntry<RestaurantEntity, List<AddProductInputEntity>>>
  restaurantProductStats = [];
  // Product performance
  List<AddProductInputEntity> bestProducts = [];
  List<AddProductInputEntity> worstProducts = [];
  List<AddProductInputEntity> lowStockProducts = [];
  List<AddProductInputEntity> unavailableProducts = [];
  List<AddProductInputEntity> unreviewedProducts = [];
  List<AddProductInputEntity> discountedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final either = await _fetch(UserSession.instance.currentEmail);
      either.fold(
        (failure) {
          setState(() {
            _error = failure.message;
            _loading = false;
          });
        },
        (list) {
          _restaurants = list;
          _loadProductStats(list).then((_) {
            _computeAggregates();
            setState(() {
              _loading = false;
            });
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Unexpected error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _loadProductStats(List<RestaurantEntity> restaurants) async {
    final entries = await Future.wait(
      restaurants.map((restaurant) async {
        if (restaurant.docId == null) {
          return MapEntry<RestaurantEntity, List<AddProductInputEntity>>(
            restaurant,
            const [],
          );
        }
        final result = await _productsRepo.getProductsByRestaurant(
          restaurantId: restaurant.docId!,
        );
        return result.fold(
          (_) => MapEntry<RestaurantEntity, List<AddProductInputEntity>>(
            restaurant,
            const [],
          ),
          (products) => MapEntry<RestaurantEntity, List<AddProductInputEntity>>(
            restaurant,
            products,
          ),
        );
      }),
    );

    _productsByRestaurant = {
      for (final entry in entries)
        if (entry.key.docId != null) entry.key.docId!: entry.value,
    };
  }

  void _computeAggregates() {
    totalProducts = 0;
    totalReviews = 0;
    double sum = 0;
    latestReviews = [];
    restaurantProductStats = [];

    for (final r in _restaurants) {
      final products = _productsByRestaurant[r.docId] ?? const [];
      totalProducts += products.length;
      restaurantProductStats.add(MapEntry(r, products));

      // Aggregate reviews from all products for this restaurant
      for (final product in products) {
        for (final rev in product.reviews) {
          totalReviews++;
          final rating = rev.rating ?? 0;
          sum += rating;
          latestReviews.add(
            _ReviewWithContext(
              review: rev,
              productTitle: product.title,
              restaurantName: r.displayName,
            ),
          );
        }
      }

      // Also include any reviews from the restaurant entity itself (for backward compatibility)
      for (final rev in r.reviews) {
        totalReviews++;
        final rating = rev.rating ?? 0;
        sum += rating;
        latestReviews.add(
          _ReviewWithContext(
            review: rev,
            productTitle: 'Restaurant-level review',
            restaurantName: r.displayName,
          ),
        );
      }
    }

    if (totalReviews > 0) averageRating = (sum / totalReviews);
    latestReviews.sort(
      (a, b) =>
          (b.review.date?.millisecondsSinceEpoch ?? 0) -
          (a.review.date?.millisecondsSinceEpoch ?? 0),
    );
    if (latestReviews.length > 20) latestReviews = latestReviews.sublist(0, 20);

    // Compute product performance using avgRating from products
    final allProducts = <AddProductInputEntity>[];
    for (final restaurant in _restaurants) {
      final products = _productsByRestaurant[restaurant.docId] ?? [];
      allProducts.addAll(products);
    }

    // Sort by average rating (best products)
    bestProducts = allProducts.where((p) => p.avgRating > 0).toList()
      ..sort((a, b) => b.avgRating.compareTo(a.avgRating));
    if (bestProducts.length > 5) bestProducts = bestProducts.sublist(0, 5);

    // Sort by average rating (worst products)
    worstProducts = allProducts.where((p) => p.avgRating > 0).toList()
      ..sort((a, b) => a.avgRating.compareTo(b.avgRating));
    if (worstProducts.length > 5) worstProducts = worstProducts.sublist(0, 5);

    // Sort by review count (most reviewed)

    lowStockProducts = allProducts.where((p) => p.bagsLeft <= 3).toList()
      ..sort((a, b) => a.bagsLeft.compareTo(b.bagsLeft));
    if (lowStockProducts.length > 5) {
      lowStockProducts = lowStockProducts.sublist(0, 5);
    }

    unavailableProducts = allProducts.where((p) => !p.isAvailable).toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    if (unavailableProducts.length > 5) {
      unavailableProducts = unavailableProducts.sublist(0, 5);
    }

    unreviewedProducts = allProducts.where((p) => p.reviews.isEmpty).toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    if (unreviewedProducts.length > 5) {
      unreviewedProducts = unreviewedProducts.sublist(0, 5);
    }

    discountedProducts =
        allProducts
            .where((p) => p.oldPrice != null && p.oldPrice! > p.price)
            .toList()
          ..sort((a, b) {
            final aDiscount = ((a.oldPrice! - a.price) / a.oldPrice!) * 100;
            final bDiscount = ((b.oldPrice! - b.price) / b.oldPrice!) * 100;
            return bDiscount.compareTo(aDiscount);
          });
    if (discountedProducts.length > 5) {
      discountedProducts = discountedProducts.sublist(0, 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Stats'),
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: _showRawData,
            icon: const Icon(Icons.bug_report),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 12),
                  _buildRestaurantStatsCard(),
                  const SizedBox(height: 12),
                  _buildProductPerformanceCard(),
                  const SizedBox(height: 12),
                  _buildWorstProductsCard(),
                  const SizedBox(height: 12),
                  _buildInventoryAlertsCard(),
                  const SizedBox(height: 12),
                  const Text(
                    'Latest Reviews',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  _buildLatestReviews(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Restaurants',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '${_restaurants.length}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Reviews',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '$totalReviews',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Products',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '$totalProducts',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Average Rating',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    averageRating.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantStatsCard() {
    if (_restaurants.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedRestaurants = [...restaurantProductStats]
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Restaurant Breakdown',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...sortedRestaurants.map((entry) {
              final restaurant = entry.key;
              final products = entry.value;
              final availableProducts = products
                  .where((p) => p.isAvailable)
                  .length;
              final unavailableProducts = products.length - availableProducts;
              final lowStockProducts = products
                  .where((p) => p.bagsLeft <= 3)
                  .length;
              final unreviewedProducts = products
                  .where((p) => p.reviews.isEmpty)
                  .length;
              final discountedProducts = products
                  .where((p) => p.oldPrice != null && p.oldPrice! > p.price)
                  .length;
              final restaurantReviewCount = products.fold<int>(
                0,
                (count, product) => count + product.reviews.length,
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            restaurant.branchLocation,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${products.length} products',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '$availableProducts available • $unavailableProducts hidden',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$restaurantReviewCount reviews • $lowStockProducts low stock',
                          style: TextStyle(
                            color: Colors.deepOrange.shade700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$unreviewedProducts no reviews',
                          style: TextStyle(
                            color: Colors.deepOrange.shade700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$discountedProducts discounted',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showRawData() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Debug: Analytics Data'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Restaurants: ${_restaurants.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Total Reviews: $totalReviews'),
                Text('Total Products: $totalProducts'),
                Text('Avg Rating: ${averageRating.toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                const Text(
                  'Product Performance:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  'Best Products: ${bestProducts.length}',
                  style: const TextStyle(color: Colors.green),
                ),
                Text(
                  'Worst Products: ${worstProducts.length}',
                  style: const TextStyle(color: Colors.red),
                ),
                if (bestProducts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Top Product:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                  ),
                  Text(
                    '${bestProducts.first.title} (${bestProducts.first.avgRating.toStringAsFixed(2)}★)',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Restaurant Breakdown:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._restaurants.map((r) {
                  final products = _productsByRestaurant[r.docId] ?? [];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${r.name} (${r.docId?.substring(0, 8) ?? 'no-id'}...)',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '📦 Products: ${products.length}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          ...products.map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                top: 4.0,
                              ),
                              child: Text(
                                '  ↳ ${p.title} (${p.reviews.length} reviews)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '⭐ Reviews: ${r.reviews.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.deepOrange,
                            ),
                          ),
                          if (r.reviews.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                '✓ Sample: "${r.reviews.first.review?.substring(0, min(r.reviews.first.review?.length ?? 0, 40)) ?? 'N/A'}..." (${r.reviews.first.rating}★ by ${r.reviews.first.name ?? 'Anon'})',
                                style: const TextStyle(fontSize: 11),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ] else
                            Text(
                              '✗ No reviews',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPerformanceCard() {
    if (bestProducts.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'No rated products yet',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text(
                  '⭐ Your Best Products',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...bestProducts.map((product) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.restaurantName ?? 'Unknown',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${product.avgRating.toStringAsFixed(1)}★',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${product.reviews.length} reviews',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWorstProductsCard() {
    if (worstProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_down, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text(
                  '⚠️ Products Needing Attention',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...worstProducts.map((product) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.restaurantName ?? 'Unknown',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${product.avgRating.toStringAsFixed(1)}★',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${product.reviews.length} reviews',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryAlertsCard() {
    if (lowStockProducts.isEmpty &&
        unavailableProducts.isEmpty &&
        unreviewedProducts.isEmpty &&
        discountedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune, color: Colors.deepPurple, size: 24),
                SizedBox(width: 8),
                Text(
                  'Manager Alerts',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (lowStockProducts.isNotEmpty) ...[
              const Text(
                'Low stock',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...lowStockProducts.map(
                (product) => _buildAlertRow(
                  color: Colors.orange,
                  title: product.title,
                  subtitle:
                      '${product.restaurantName ?? 'Unknown'} • ${product.bagsLeft} left',
                  trailing: product.bagsLeft <= 0 ? 'Out' : 'Low',
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (unavailableProducts.isNotEmpty) ...[
              const Text(
                'Unavailable products',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...unavailableProducts.map(
                (product) => _buildAlertRow(
                  color: Colors.red,
                  title: product.title,
                  subtitle: product.restaurantName ?? 'Unknown',
                  trailing: 'Hidden',
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (unreviewedProducts.isNotEmpty) ...[
              const Text(
                'No reviews yet',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...unreviewedProducts.map(
                (product) => _buildAlertRow(
                  color: Colors.blueGrey,
                  title: product.title,
                  subtitle: product.restaurantName ?? 'Unknown',
                  trailing: 'New',
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (discountedProducts.isNotEmpty) ...[
              const Text(
                'Discounted products',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...discountedProducts.map((product) {
                final discount =
                    ((product.oldPrice! - product.price) / product.oldPrice!) *
                    100;
                return _buildAlertRow(
                  color: Colors.green,
                  title: product.title,
                  subtitle:
                      '${product.restaurantName ?? 'Unknown'} • ${discount.toStringAsFixed(0)}% off',
                  trailing: product.price.toStringAsFixed(2),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlertRow({
    required Color color,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            trailing,
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestReviews() {
    if (latestReviews.isEmpty) {
      return const Center(child: Text('No reviews yet'));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: latestReviews.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = latestReviews[index];
        final r = item.review;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: r.image != null
                      ? NetworkImage(r.image!)
                      : null,
                  child: r.image == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            r.name ?? 'Anonymous',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            r.rating?.toString() ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.restaurantName} • ${item.productTitle}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.review ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.date != null ? r.date!.toLocal().toString() : '',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReviewWithContext {
  final ReviewEntity review;
  final String restaurantName;
  final String productTitle;

  const _ReviewWithContext({
    required this.review,
    required this.restaurantName,
    required this.productTitle,
  });
}
