import 'package:flutter/material.dart';
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
  Map<int, int> ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  List<ReviewEntity> latestReviews = [];
  List<MapEntry<RestaurantEntity, List<AddProductInputEntity>>>
  restaurantProductStats = [];
  List<MapEntry<RestaurantEntity, double>> restaurantAverageRatings = [];
  // Keyword analytics
  Map<String, int> keywordCounts = {};
  Map<String, int> keywordRatingSum = {};
  List<MapEntry<String, int>> topKeywords = [];

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
    ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    latestReviews = [];
    restaurantProductStats = [];
    restaurantAverageRatings = [];

    for (final r in _restaurants) {
      final products = _productsByRestaurant[r.docId] ?? const [];
      totalProducts += products.length;
      restaurantProductStats.add(MapEntry(r, products));

      double restaurantRatingSum = 0;
      int restaurantReviewCount = 0;

      for (final rev in r.reviews) {
        totalReviews++;
        final rating = rev.rating ?? 0;
        sum += (rating);
        restaurantRatingSum += rating;
        restaurantReviewCount++;
        if (rating >= 1 && rating <= 5)
          ratingCounts[rating] = ratingCounts[rating]! + 1;
        latestReviews.add(rev);
      }

      final restaurantAvg = restaurantReviewCount == 0
          ? 0.0
          : restaurantRatingSum / restaurantReviewCount;
      restaurantAverageRatings.add(MapEntry(r, restaurantAvg));
    }

    if (totalReviews > 0) averageRating = (sum / totalReviews);
    latestReviews.sort(
      (a, b) =>
          (b.date?.millisecondsSinceEpoch ?? 0) -
          (a.date?.millisecondsSinceEpoch ?? 0),
    );
    if (latestReviews.length > 20) latestReviews = latestReviews.sublist(0, 20);

    // Build keyword counts (simple tokenizer + stopwords)
    keywordCounts.clear();
    keywordRatingSum.clear();
    final stopwords = <String>{
      'the',
      'and',
      'for',
      'with',
      'this',
      'that',
      'have',
      'from',
      'your',
      'was',
      'were',
      'but',
      'not',
      'are',
      'our',
      'you',
      'its',
      'a',
      'an',
      'in',
      'on',
      'of',
      'to',
      'is',
      'it',
      'at',
      'be',
    };

    for (final rev in latestReviews) {
      final text = (rev.review ?? '').toLowerCase();
      if (text.isEmpty) continue;
      final tokens = text.split(RegExp(r"[^a-zA-Z\u0600-\u06FF0-9]+"));
      final used = <String>{};
      for (final t in tokens) {
        final tok = t.trim();
        if (tok.length < 3) continue;
        if (stopwords.contains(tok)) continue;
        // avoid double-counting same word in single review
        if (used.contains(tok)) continue;
        used.add(tok);
        keywordCounts[tok] = (keywordCounts[tok] ?? 0) + 1;
        keywordRatingSum[tok] =
            (keywordRatingSum[tok] ?? 0) + (rev.rating ?? 0);
      }
    }

    topKeywords = keywordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (topKeywords.length > 20) topKeywords = topKeywords.sublist(0, 20);
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
                  _buildDistributionCard(),
                  const SizedBox(height: 12),
                  _buildTopKeywordsCard(),
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
              final avgRating = restaurantAverageRatings
                  .firstWhere(
                    (e) => e.key.docId == restaurant.docId,
                    orElse: () => MapEntry(restaurant, 0.0),
                  )
                  .value;

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
                          '${restaurant.reviews.length} reviews',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: TextStyle(
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.w700,
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

  Widget _buildDistributionCard() {
    final maxCount = ratingCounts.values.fold<int>(0, (p, n) => n > p ? n : p);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ratings Distribution',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...[5, 4, 3, 2, 1].map((star) {
              final count = ratingCounts[star] ?? 0;
              final pct = maxCount == 0 ? 0.0 : (count / maxCount);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    SizedBox(width: 28, child: Text('$star★')),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: pct,
                            child: Container(
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(width: 40, child: Text('$count')),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopKeywordsCard() {
    if (topKeywords.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'No keyword insights yet',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Mentioned Keywords',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topKeywords.map((e) {
                final kw = e.key;
                final count = e.value;
                final avg =
                    (keywordRatingSum[kw] ?? 0) / (count == 0 ? 1 : count);
                return Chip(
                  label: Text('$kw · $count · ${avg.toStringAsFixed(1)}★'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showRawData() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Debug: Fetched Data'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Restaurants fetched: ${_restaurants.length}'),
                Text('Total reviews counted: $totalReviews'),
                const SizedBox(height: 8),
                ..._restaurants.map((r) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '- ${r.name} (${r.docId ?? 'no-id'}) — ${r.reviews.length} reviews',
                        ),
                        if (r.reviews.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 4),
                            child: Text(
                              '  sample: ${r.reviews.first.review} | rating: ${r.reviews.first.rating} | user: ${r.reviews.first.userId}',
                            ),
                          ),
                      ],
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

  Widget _buildLatestReviews() {
    if (latestReviews.isEmpty) {
      return const Center(child: Text('No reviews yet'));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: latestReviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = latestReviews[index];
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
