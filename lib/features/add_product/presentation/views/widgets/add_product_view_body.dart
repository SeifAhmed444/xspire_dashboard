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

  late String name, branches, distance, title;
  double price = 0.0, oldPrice = 0.0, rating = 0.0;
  int bagsLeft = 0;
  String? detectedFood;
  File? image;
  bool isOpend = false;
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

              // ── AI Scanner أول حاجة ──────────────────────────────────
              AiScannerWidget(
                onScanComplete: (scannedImage, detectedFoodStr) {
                  setState(() {
                    image = scannedImage;
                    detectedFood = detectedFoodStr;
                  });
                },
              ),
              const SizedBox(height: 16),

              // ── نتيجة الـ AI ─────────────────────────────────────────
              if (detectedFood != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI Detected: $detectedFood',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Restaurant Info ──────────────────────────────────────
              CustomTextFormField(
                onSaved: (v) => name = v!,
                hintText: 'Restaurant Name',
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                onSaved: (v) => branches = v!,
                hintText: 'Number of Branches',
                textInputType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                onSaved: (v) => distance = v!,
                hintText: 'Distance',
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 16),

              // ── Bag Item Info ────────────────────────────────────────
              CustomTextFormField(
                onSaved: (v) => title = v!,
                hintText: 'Bag Title',
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 16),
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
              CheckBox.IsCheckBox(
                label: 'Is Open Now',
                onChanged: (v) => isOpend = v,
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
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final input = AddProductInputEntity(
                      name: name,
                      logoImage: '',
                      branches: branches,
                      distance: distance,
                      isAvailable: isAvailable,
                      isOpenNow: isOpend,
                      title: title,
                      price: price,
                      oldPrice: oldPrice,
                      bagsLeft: bagsLeft,
                      rating: rating,
                      image: image!,
                      detectedItems: (detectedFood ?? '')
                          .split(', ')
                          .where((s) => s.isNotEmpty)
                          .toList(),
                      isOpend: isOpend,
                    );
                    context.read<AddProductCubit>().addProduct(input);
                  } else {
                    setState(
                        () => autovalidateMode = AutovalidateMode.always);
                  }
                },
                text: 'Add Restaurant',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}