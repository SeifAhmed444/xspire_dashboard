import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xspire_dashboard/core/services/get_it_services.dart';
import 'package:xspire_dashboard/core/services/user_session.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/core/widgets/custom_button.dart';
import 'package:xspire_dashboard/core/widgets/custom_text_field.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/cubit/restaurant_cubit.dart';

class AddRestaurantSimple extends StatefulWidget {
  static const routeName = 'add_restaurant_simple';
  
  const AddRestaurantSimple({super.key});

  @override
  State<AddRestaurantSimple> createState() => _AddRestaurantSimpleState();
}

// Wrapper to provide the cubit
class AddRestaurantSimplePage extends StatelessWidget {
  const AddRestaurantSimplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RestaurantCubit(
        fetchRestaurantsUseCase: getIt(),
        addRestaurantUseCase: getIt(),
        updateRestaurantUseCase: getIt(),
        deleteRestaurantUseCase: getIt(),
        uploadImageUseCase: getIt(),
      ),
      child: const AddRestaurantSimple(),
    );
  }
}

class _AddRestaurantSimpleState extends State<AddRestaurantSimple> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _branchesCountController = TextEditingController(text: '1');
  final _branchLocationController = TextEditingController();
  
  File? _logoImage;
  bool _isAvailable = true;
  bool _isOpenNow = true;

  @override
  void dispose() {
    _nameController.dispose();
    _branchesCountController.dispose();
    _branchLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RestaurantCubit, RestaurantState>(
      listener: (context, state) {
        if (state is RestaurantOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(state.message),
              ]),
              backgroundColor: AppColors.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          // Pop after success
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) Navigator.pop(context, true);
          });
        }
        if (state is RestaurantError && state.message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F5),
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Add Restaurant',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<RestaurantCubit, RestaurantState>(
          builder: (context, state) {
            final isLoading = state is RestaurantOperationLoading;
            
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo Upload
                          Center(
                            child: GestureDetector(
                              onTap: _pickLogo,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey.shade300),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _logoImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.file(_logoImage!, fit: BoxFit.cover),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate_outlined,
                                              size: 40, color: Colors.grey.shade400),
                                          const SizedBox(height: 8),
                                          Text('Add Logo',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade500)),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Restaurant Name
                          CustomTextFormField(
                            controller: _nameController,
                            hintText: 'Restaurant Name (e.g. Madbina)',
                            textInputType: TextInputType.text,
                            prefixIcon: Icon(Icons.restaurant, color: Colors.grey.shade500),
                            validator: (v) => v?.isEmpty == true ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),

                          // Number of Branches
                          CustomTextFormField(
                            controller: _branchesCountController,
                            hintText: 'Number of Branches',
                            textInputType: TextInputType.number,
                            prefixIcon: Icon(Icons.store_mall_directory_outlined, color: Colors.grey.shade500),
                            validator: (v) => v?.isEmpty == true ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),

                          // Branch Location
                          CustomTextFormField(
                            controller: _branchLocationController,
                            hintText: 'Branch Location (e.g. Zamalek, 2 Taha Hussein)',
                            textInputType: TextInputType.text,
                            prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey.shade500),
                            validator: (v) => v?.isEmpty == true ? 'Required' : null,
                          ),
                          const SizedBox(height: 24),

                          // Toggles
                          Row(
                            children: [
                              Expanded(
                                child: _buildToggle(
                                  'Available',
                                  _isAvailable,
                                  Icons.check_circle,
                                  (v) => setState(() => _isAvailable = v),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildToggle(
                                  'Open Now',
                                  _isOpenNow,
                                  Icons.access_time,
                                  (v) => setState(() => _isOpenNow = v),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Save Button
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: CustomButton(
                      onPressed: isLoading ? () {} : _saveRestaurant,
                      text: isLoading ? 'Saving...' : 'Save Restaurant',
                      useGradient: true,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, IconData icon, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: value ? AppColors.primaryColor.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value ? AppColors.primaryColor : Colors.grey.shade300,
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: value ? AppColors.primaryColor : Colors.grey.shade500),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: value ? AppColors.primaryColor : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickLogo() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _logoImage = File(pickedFile.path);
      });
    }
  }

  void _saveRestaurant() {
    if (_formKey.currentState!.validate()) {
      final branchCount = int.tryParse(_branchesCountController.text) ?? 1;
      final branchLocations = List.generate(
        branchCount,
        (_) => _branchLocationController.text.trim(),
      );
      
      context.read<RestaurantCubit>().addRestaurantsWithBranches(
        name: _nameController.text.trim(),
        branchLocations: branchLocations,
        isOpend: _isOpenNow,
        isAvailable: _isAvailable,
        userEmail: UserSession.instance.currentEmail,
        imageFile: _logoImage,
      );
    }
  }
}
