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

  double price = 0.0, oldPrice = 0.0, rating = 0.0;
  int bagsLeft = 0;
  List<DetectedFoodItem>? detectedItems;
  File? image;
  bool isAvailable = false;

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

              // ── AI Scanner ──────────────────────────────────────────────
              AiScannerWidget(
                onScanComplete: (scannedImage, items) {
                  setState(() {
                    image = scannedImage;
                    detectedItems = items;
                  });
                },
              ),
              const SizedBox(height: 16),

              // ── AI Detected Variables ──────────────────────────────────
              if (detectedItems != null && detectedItems!.isNotEmpty) ...[
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
                      ...detectedItems!.map((item) {
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

              // ── Bag Item Info ────────────────────────────────────────
              CustomTextFormField(
                onSaved: (v) => price = double.tryParse(v!) ?? 0.0,
                hintText: 'Price',
                textInputType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                onSaved: (v) => oldPrice = double.tryParse(v!) ?? 0.0,
                hintText: 'Old Price',
                textInputType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                onSaved: (v) => bagsLeft = int.tryParse(v!) ?? 0,
                hintText: 'Bags Left',
                textInputType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                onSaved: (v) => rating = double.tryParse(v!) ?? 0.0,
                hintText: 'Rating (0-5)',
                textInputType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // ── Toggles ──────────────────────────────────────────────
              CheckBox.IsCheckBox(
                label: 'Is Available',
                onChanged: (v) => isAvailable = v,
              ),
              const SizedBox(height: 16),

              // ── Submit ───────────────────────────────────────────────
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
                  
                  // Filter out items with 0 count
                  final finalItems = detectedItems
                          ?.where((element) => element.count > 0)
                          .toList() ?? [];

                  if (finalItems.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please ensure there is at least one item detected'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    
                    final itemNames = finalItems.map((e) => e.name).toSet().toList();
                    final generatedTitle = 'Bag with ${itemNames.join(', ')}';
                    
                    final detectedItemsStrings = finalItems
                        .map((e) => '${e.count}x ${e.name}')
                        .toList();

                    final input = AddProductInputEntity(
                      isAvailable: isAvailable,
                      title: generatedTitle,
                      price: price,
                      oldPrice: oldPrice,
                      bagsLeft: bagsLeft,
                      rating: rating,
                      image: image!,
                      detectedItems: detectedItemsStrings,
                    );
                    context.read<AddProductCubit>().addProduct(input);
                  } else {
                    setState(
                        () => autovalidateMode = AutovalidateMode.always);
                  }
                },
                text: 'Add Bag Item',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}