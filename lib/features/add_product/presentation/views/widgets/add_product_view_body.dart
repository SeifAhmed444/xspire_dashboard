import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  String title = '';
  double price = 0.0, oldPrice = 0.0, rating = 0.0;
  int bagsLeft = 0;
  String? detectedFood;
  List<DetectedItem> detectedItems = [];
  File? image;
  bool isAvailable = true;

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

              // ── AI Scanner (Segmentation) ──────────────────────────────
              AiScannerWidget(
                mode: AiScannerMode.segmentation,
                onScanComplete: (scannedImage, result) {
                  setState(() {
                    image = scannedImage;
                    final Map<String, int> itemsMap = result as Map<String, int>;
                    detectedItems = itemsMap.entries
                        .map((e) => DetectedItem(e.key, e.value))
                        .toList();
                  });
                },
              ),
              const SizedBox(height: 16),

              // ── AI Detected Variables ──────────────────────────────────
              if (detectedItems.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Verify Detected Items',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...detectedItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (item.count > 0) item.count--;
                                      });
                                    },
                                    icon: const Icon(Icons.remove_circle_outline),
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
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Colors.green,
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
                const SizedBox(height: 16),
              ],

              // ── Bag Info ──────────────────────────────────────────────
              CustomTextFormField(
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
                      onSaved: (v) => price = double.tryParse(v!) ?? 0.0,
                      hintText: 'Price',
                      textInputType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextFormField(
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
              
              // ── AI Scanner (Classification - Optional) ────────────────
              AiScannerWidget(
                mode: AiScannerMode.classification,
                onScanComplete: (scannedImage, result) {
                  setState(() {
                    image = scannedImage;
                    detectedFood = result as String;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              if (detectedFood != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Food Category: $detectedFood',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              IsFeaturedCheckBox(
                onChanged: (v) => isAvailable = v,
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
                    
                    // Combine detected items into a string list for the entity
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
