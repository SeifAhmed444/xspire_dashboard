import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/widgets/custom_button.dart';
import 'package:xspire_dashboard/core/widgets/custom_text_field.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';
import 'package:xspire_dashboard/features/add_product/presentation/manager/cubit/add_product_cubit.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/widgets/image_field.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/widgets/is_featured_check_box.dart';

class AddProductViewBody extends StatefulWidget {
  const AddProductViewBody({super.key});

  @override
  State<AddProductViewBody> createState() => _AddProductViewBodyState();
}

class _AddProductViewBodyState extends State<AddProductViewBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  late String name, branches, distance;
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
              CustomTextFormField(
                onSaved: (value) => name = value!,
                hintText: 'Restaurant Name',
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                onSaved: (value) => branches = value!,
                hintText: 'Restaurant Branch',
                textInputType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                onSaved: (value) => distance = value!,
                hintText: 'Branch Distance',
                textInputType: TextInputType.text,
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              // Fix: pass correct labels and capture correct values
              CheckBox.IsCheckBox(
                label: 'Is Available',
                onChanged: (value) => isAvailable = value,
              ),
              const SizedBox(height: 16),
              CheckBox.IsCheckBox(
                label: 'Is Open',
                onChanged: (value) => isOpend = value,
              ),
              const SizedBox(height: 16),
              ImageField(
                onFileChange: (file) => image = file,
              ),
              const SizedBox(height: 16),
              CustomButton(
                onPressed: () {
                  if (image != null) {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Fix: pass the actual checkbox values instead of
                      // hardcoded false
                      final input = AddProductInputEntity(
                        name: name,
                        distance: distance,
                        branches: branches,
                        isAvailable: isAvailable,
                        isOpend: isOpend,
                        image: image!,
                      );
                      context.read<AddProductCubit>().addProduct(input);
                    } else {
                      setState(
                          () => autovalidateMode = AutovalidateMode.always);
                    }
                  } else {
                    _showImageError(context);
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

  void _showImageError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select an image'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
