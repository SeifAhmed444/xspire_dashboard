import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/widgets/custom_button.dart';
import 'package:xspire_dashboard/core/widgets/custom_text_field.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';
import 'package:xspire_dashboard/features/add_product/presentation/manager/cubit/add_product_cubit.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/widgets/custom_check_box.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/widgets/image_field.dart';
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

  late String name, branches, distance;
  String? detectedFood;
  String? price;
  File? image;
  bool isOpend = false;
  bool isAvailable= false;

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
              CustomTextFormField(
                onSaved: (value) {
                  name = value!;
                },
                hintText: 'Resturant Name',
                textInputType: TextInputType.text,
              ),

              SizedBox(height: 16),
              CustomTextFormField(
                onSaved: (value) {
                  branches = value!;
                },
                hintText: 'Restaurant Branch',
                textInputType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                onSaved: (value) {
                  distance = value!;
                },
                hintText: 'Branch Distance',
                textInputType: TextInputType.text,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              CheckBox.IsCheckBox(
                onChanged: (value) {
                isAvailable = value;
                },
              ),
              const SizedBox(height: 16),
              CheckBox.IsCheckBox(
                onChanged: (value) {
                  isOpend = value;
                },
              ),
              const SizedBox(height: 16),
              AiScannerWidget(
                onScanComplete: (scannedImage, detectedFoodStr) {
                  setState(() {
                    this.image = scannedImage;
                    this.detectedFood = detectedFoodStr;
                  });
                },
              ),
              const SizedBox(height: 16),
              
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
                CustomTextFormField(
                  onSaved: (value) {
                    price = value!;
                  },
                  hintText: 'Product Price',
                  textInputType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              CustomButton(
                onPressed: () {
                  if (image != null && detectedFood != null) {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      AddProductInputEntity input = AddProductInputEntity(
                        name: '$name - $detectedFood', // Combining restaurant with food or just passing name
                        distance: distance,
                        branches: branches,
                        isAvailable: isAvailable,
                        isOpend: isOpend,
                        image: image!, 
                        price: price,
                      );
                      context.read<AddProductCubit>().addProduct(input);

                    } else {
                      autovalidateMode = AutovalidateMode.always;
                      setState(() {});
                    }
                  } else {
                    showError(context);
                  }
                },
                text: 'Add Product',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  void showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select and scan an image first'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
