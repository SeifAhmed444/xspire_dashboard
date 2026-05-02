import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/services/food_detection_service.dart';
import 'package:xspire_dashboard/core/widgets/custom_button.dart';
import 'package:xspire_dashboard/core/widgets/custom_text_field.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';
import 'package:xspire_dashboard/features/add_product/presentation/manager/cubit/add_product_cubit.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/widgets/is_featured_check_box.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/widgets/ai_scanner_widget.dart';

class AddProductViewBody extends StatefulWidget {
  const AddProductViewBody({super.key});

  @override
  State<AddProductViewBody> createState() => _AddProductViewBodyState();
}

class _AddProductViewBodyState extends State<AddProductViewBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _oldPriceController = TextEditingController();
  final TextEditingController _bagsLeftController = TextEditingController();

  String title = '';
  double price = 0.0, oldPrice = 0.0, rating = 0.0;
  int bagsLeft = 0;
  String? detectedFood;
  List<DetectedItem> detectedItems = [];
  File? image;
  bool isAvailable = true;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _oldPriceController.dispose();
    _bagsLeftController.dispose();
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

              // ── AI Scanner (Primary Entry Point) ──────────────────────
              AiScannerWidget(
                mode: AiScannerMode.segmentation,
                onScanComplete: (scannedImage, result) {
                  setState(() {
                    image = scannedImage;
                    final Map<String, FoodClassificationResult> itemsMap = 
                        result as Map<String, FoodClassificationResult>;
                    
                    detectedItems = itemsMap.entries
                        .map((e) => DetectedItem(e.key, e.value.count))
                        .toList();
                    
                    // Fill fields from the first detected item (the main dish)
                    if (itemsMap.isNotEmpty) {
                      final firstItem = itemsMap.values.first;
                      _titleController.text = firstItem.label;
                      _priceController.text = firstItem.price.toString();
                      _oldPriceController.text = firstItem.oldPrice.toString();
                      _bagsLeftController.text = firstItem.count.toString();
                      isAvailable = firstItem.isAvailable;
                      
                      // Also update local state variables
                      title = firstItem.label;
                      price = firstItem.price;
                      oldPrice = firstItem.oldPrice;
                      bagsLeft = firstItem.count;
                    }
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
                            'Verify Detected Items',
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
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
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
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (item.count > 0) {
                                            item.count--;
                                            // If it's the first item, update the main bagsLeft field
                                            if (idx == 0) {
                                              _bagsLeftController.text = item.count.toString();
                                              bagsLeft = item.count;
                                            }
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
                                          // If it's the first item, update the main bagsLeft field
                                          if (idx == 0) {
                                            _bagsLeftController.text = item.count.toString();
                                            bagsLeft = item.count;
                                          }
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
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Bag Info Form ─────────────────────────────────────────
              CustomTextFormField(
                controller: _titleController,
                onSaved: (v) => title = v ?? '',
                hintText: 'Bag Title (e.g. Mixed Veggies)',
                textInputType: TextInputType.text,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: _priceController,
                      onSaved: (v) => price = double.tryParse(v!) ?? 0.0,
                      hintText: 'Price',
                      textInputType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextFormField(
                      controller: _oldPriceController,
                      onSaved: (v) => oldPrice = double.tryParse(v!) ?? 0.0,
                      hintText: 'Old Price',
                      textInputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: _bagsLeftController,
                      onSaved: (v) => bagsLeft = int.tryParse(v!) ?? 0,
                      hintText: 'Bags Left',
                      textInputType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextFormField(
                      onSaved: (v) => rating = double.tryParse(v!) ?? 0.0,
                      hintText: 'Rating (0-5)',
                      textInputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              IsFeaturedCheckBox(
                value: isAvailable,
                onChanged: (v) => setState(() => isAvailable = v),
              ),
              const SizedBox(height: 20),

              CustomButton(
                onPressed: () {
                  if (image == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please scan an image first'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    
                    final List<String> finalItems = detectedItems
                        .where((i) => i.count > 0)
                        .map((i) => "${i.count}x ${i.name}")
                        .toList();

                    final input = AddProductInputEntity(
                      isAvailable: isAvailable,
                      title: title,
                      price: price,
                      oldPrice: oldPrice,
                      bagsLeft: bagsLeft,
                      rating: rating,
                      image: image!,
                      detectedItems: finalItems,
                    );
                    context.read<AddProductCubit>().addProduct(input);
                  } else {
                    setState(() => autovalidateMode = AutovalidateMode.always);
                  }
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
}

class DetectedItem {
  final String name;
  int count;
  DetectedItem(this.name, this.count);
}
