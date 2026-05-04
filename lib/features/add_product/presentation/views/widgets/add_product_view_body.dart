import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/localization/app_localizations.dart';
import 'package:xspire_dashboard/core/services/user_session.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/core/widgets/custom_button.dart';
import 'package:xspire_dashboard/core/widgets/custom_text_field.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';
import 'package:xspire_dashboard/features/add_product/presentation/manager/cubit/add_product_cubit.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/widgets/is_featured_check_box.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/widgets/ai_scanner_widget.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/restaurant_entity.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/cubit/restaurant_cubit.dart';

class AddProductViewBody extends StatefulWidget {
  const AddProductViewBody({super.key});

  @override
  State<AddProductViewBody> createState() => _AddProductViewBodyState();
}

class _AddProductViewBodyState extends State<AddProductViewBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  String title = '';
  double price = 0.0;
  int bagsLeft = 0;
  String? detectedFood;
  List<DetectedItem> detectedItems = [];
  File? image;
  bool isAvailable = true;
  
  // Selected restaurant
  RestaurantEntity? selectedRestaurant;
  List<RestaurantEntity> restaurants = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Dispose all item controllers
    for (var item in detectedItems) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: autovalidateMode,
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ── Restaurant Selector ──────────────────────────────────
              BlocBuilder<RestaurantCubit, RestaurantState>(
                builder: (context, state) {
                  if (state is RestaurantLoading) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  if (state is RestaurantLoaded) {
                    restaurants = state.restaurants;
                  } else if (state is RestaurantOperationSuccess) {
                    restaurants = state.restaurants;
                  }
                  
                  return _buildRestaurantDropdown();
                },
              ),
              const SizedBox(height: 16),

              // ── AI Scanner (Primary Entry Point) ──────────────────────
              AiScannerWidget(
                onScanComplete: (scannedImage, detectedFood) {
                  setState(() {
                    // Dispose old item controllers
                    for (var item in detectedItems) {
                      item.dispose();
                    }

                    image = scannedImage;

                    // Parse detected food string (comma-separated)
                    var items = detectedFood.split(', ').where((s) => s.isNotEmpty).toList();
                    if (items.isEmpty) {
                      items = ['Food Item'];
                    }

                    detectedItems = items
                        .map((label) => DetectedItem(label, 1))
                        .toList();

                    // Set title from the first detected item
                    title = items.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // ── AI Detected Variables ──────────────────────────────────
              if (detectedItems.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).verifyDetectedItems,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...detectedItems.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name + Delete button
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: item.nameController,
                                        onChanged: (v) => item.name = v,
                                        decoration: InputDecoration(
                                          labelText: '${AppLocalizations.of(context).bagItem} ${idx + 1}',
                                          labelStyle: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          item.isDeleted = true;
                                        });
                                      },
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      tooltip: AppLocalizations.of(context).deleteItem,
                                    ),
                                  ],
                                ),
                                if (item.isDeleted) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.warning, color: Colors.red, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppLocalizations.of(context).willBeDeleted,
                                          style: TextStyle(color: Colors.red, fontSize: 12),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              item.isDeleted = false;
                                            });
                                          },
                                          child: Text(
                                            AppLocalizations.of(context).undo,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                // Old Price & New Price
                                Row(
                                  children: [
                                    // Old Price
                                    Expanded(
                                      child: TextFormField(
                                        controller: item.oldPriceController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: AppLocalizations.of(context).oldPriceEgp,
                                          labelStyle: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          hintText: 'Enter original price',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Arrow
                                    const Icon(Icons.arrow_forward, color: Colors.grey),
                                    const SizedBox(width: 12),
                                    // New Price (auto-calculated, read-only)
                                    Expanded(
                                      child: TextFormField(
                                        controller: item.priceController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          labelText: AppLocalizations.of(context).newPriceEgp,
                                          labelStyle: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          filled: true,
                                          fillColor: Colors.green.shade50,
                                          suffixText: '(-60%)',
                                          suffixStyle: TextStyle(
                                            color: Colors.green.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Quantity counter
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Quantity: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if (item.count > 0) {
                                                  item.count--;
                                                  }
                                              });
                                            },
                                            icon: const Icon(Icons.remove, size: 18),
                                            color: Colors.redAccent,
                                          ),
                                          Text(
                                            '${item.count}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                item.count++;
                                              });
                                            },
                                            icon: const Icon(Icons.add, size: 18),
                                            color: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Availability Toggle ──────────────────────────────────
              IsFeaturedCheckBox(
                value: isAvailable,
                onChanged: (v) => setState(() => isAvailable = v),
              ),
              const SizedBox(height: 20),

              CustomButton(
                onPressed: () {
                  if (selectedRestaurant == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a restaurant first'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (image == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please scan an image first'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  // Auto-calculate bag data from detected items
                  final activeItems = detectedItems
                      .where((i) => !i.isDeleted && i.count > 0)
                      .toList();
                  
                  if (activeItems.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).noItemsToSave),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  // Auto-generate title from item names
                  final List<String> itemNames = activeItems
                      .map((i) => i.nameController.text.trim())
                      .toList();
                  final autoTitle = itemNames.length == 1 
                      ? itemNames.first 
                      : '${itemNames.first} +${itemNames.length - 1}';
                  
                  // Calculate total price (sum of all new prices)
                  final totalPrice = activeItems.fold<double>(0, (sum, i) {
                    final newPrice = double.tryParse(i.priceController.text) ?? 0.0;
                    return sum + (newPrice * i.count);
                  });
                  
                  // Total quantity
                  final totalQuantity = activeItems.fold<int>(0, (sum, i) => sum + i.count);
                  
                  // Calculate total old price
                  final totalOldPrice = activeItems.fold<double>(0, (sum, i) {
                    final old = double.tryParse(i.oldPriceController.text) ?? 0.0;
                    return sum + (old * i.count);
                  });
                  
                  // Filter out deleted items and format with prices
                  final List<String> finalItems = activeItems.map((i) {
                    final name = i.nameController.text.trim();
                    final oldPrice = double.tryParse(i.oldPriceController.text) ?? 0.0;
                    final newPrice = double.tryParse(i.priceController.text) ?? 0.0;
                    if (oldPrice > 0 && newPrice > 0) {
                      return "${i.count}x $name (EGP ${newPrice.toStringAsFixed(0)}~)";
                    }
                    return "${i.count}x $name";
                  }).toList();

                  final input = AddProductInputEntity(
                    isAvailable: isAvailable,
                    title: autoTitle,
                    price: totalPrice,
                    oldPrice: totalOldPrice > 0 ? totalOldPrice : null,
                    bagsLeft: totalQuantity,
                    image: image!,
                    detectedItems: finalItems,
                    restaurantId: selectedRestaurant!.docId,
                    restaurantName: selectedRestaurant!.name,
                    userEmail: UserSession.instance.currentEmail,
                    pickupTime: 'Pickup 9:00 AM - 11:59 PM',
                  );
                  context.read<AddProductCubit>().addProduct(input);
                },
                text: 'Add Bag Item',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantDropdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).selectRestaurant,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          restaurants.isEmpty
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey.shade500),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).noRestaurantsYet,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : DropdownButtonFormField<RestaurantEntity>(
                value: selectedRestaurant,
                hint: Text(AppLocalizations.of(context).chooseRestaurant, style: TextStyle(color: Colors.grey.shade500)),
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: restaurants.map((restaurant) {
                  return DropdownMenuItem<RestaurantEntity>(
                    value: restaurant,
                    child: Row(
                      children: [
                        Icon(Icons.store, size: 18, color: AppColors.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${restaurant.displayName} • ${restaurant.branchLocation}',
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (restaurant.isAvailable)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '✓',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRestaurant = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context).pleaseSelectRestaurant;
                  }
                  return null;
                },
              ),
        ],
      ),
    );
  }
}

class DetectedItem {
  String name;
  int count;
  double oldPrice;
  double price;
  late TextEditingController nameController;
  late TextEditingController oldPriceController;
  late TextEditingController priceController;
  bool isDeleted;

  DetectedItem(this.name, this.count, {this.oldPrice = 0.0, this.isDeleted = false}) 
      : price = oldPrice * 0.4 {
    nameController = TextEditingController(text: name);
    oldPriceController = TextEditingController(text: oldPrice > 0 ? oldPrice.toStringAsFixed(2) : '');
    priceController = TextEditingController(text: price > 0 ? price.toStringAsFixed(2) : '');
    
    // Auto-calculate new price when old price changes
    oldPriceController.addListener(() {
      final old = double.tryParse(oldPriceController.text) ?? 0.0;
      final newPrice = old * 0.4; // 60% off
      priceController.text = newPrice > 0 ? newPrice.toStringAsFixed(2) : '';
    });
  }

  void dispose() {
    nameController.dispose();
    oldPriceController.dispose();
    priceController.dispose();
  }
}
