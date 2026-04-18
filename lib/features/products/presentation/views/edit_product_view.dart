import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/repos/image_repo/image_repo.dart';
import 'package:xspire_dashboard/core/repos/product_repo/products_repo.dart';
import 'package:xspire_dashboard/core/services/get_it_services.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/core/widgets/custom_button.dart';
import 'package:xspire_dashboard/core/widgets/custom_modal_progress_hub.dart';
import 'package:xspire_dashboard/core/widgets/custom_text_field.dart';
import 'package:xspire_dashboard/features/add_product/domain/entities/add_product_input_entity.dart';
import 'package:xspire_dashboard/features/add_product/presentation/manager/cubit/add_product_cubit.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/widgets/image_field.dart';

class EditProductView extends StatelessWidget {
  const EditProductView({super.key, required this.product});
  static const routeName = 'edit_product';

  final AddProductInputEntity product;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddProductCubit(
        getIt.get<ImageRepo>(),
        getIt.get<ProductsRepo>(),
      ),
      child: _EditProductConsumer(product: product),
    );
  }
}

// ── BlocConsumer wrapper ──────────────────────────────────────────────────────
class _EditProductConsumer extends StatelessWidget {
  const _EditProductConsumer({required this.product});
  final AddProductInputEntity product;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddProductCubit, AddProductState>(
      listener: (context, state) {
        if (state is UpdateProductSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text('Restaurant updated successfully!'),
                ],
              ),
              backgroundColor: AppColors.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context, true); // return true → list will refresh
        }

        if (state is AddProductFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errMessage),
              backgroundColor: AppColors.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return CustomModalProgressHUD(
          inAsyncCall: state is AddProductLoading,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F7F5),
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Edit Restaurant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: _EditProductForm(product: product),
          ),
        );
      },
    );
  }
}

// ── Form ──────────────────────────────────────────────────────────────────────
class _EditProductForm extends StatefulWidget {
  const _EditProductForm({required this.product});
  final AddProductInputEntity product;

  @override
  State<_EditProductForm> createState() => _EditProductFormState();
}

class _EditProductFormState extends State<_EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  late final TextEditingController _nameController;
  late final TextEditingController _branchesController;
  late final TextEditingController _distanceController;

  late String name;
  late String branches;
  late String distance;
  late bool isOpend;
  late bool isAvailable;
  File? newImage;

  @override
  void initState() {
    super.initState();
    // pre-fill from existing product
    name = widget.product.name;
    branches = widget.product.branches;
    distance = widget.product.distance;
    isOpend = widget.product.isOpend;
    isAvailable = widget.product.isAvailable;

    _nameController = TextEditingController(text: widget.product.name);
    _branchesController = TextEditingController(text: widget.product.branches);
    _distanceController = TextEditingController(text: widget.product.distance);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _branchesController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Current image header ──
          _ImageHeader(
            imageUrl: widget.product.imageUrl,
            name: widget.product.name,
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Basic Info ──
                  _SectionTitle(title: 'Basic Information'),
                  const SizedBox(height: 12),

                  CustomTextFormField(
                    controller: _nameController,
                    hintText: 'Restaurant Name',
                    textInputType: TextInputType.text,
                    onSaved: (v) => name = v ?? '',
                    prefixIcon: const Icon(
                      Icons.restaurant_rounded,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),

                  CustomTextFormField(
                    controller: _branchesController,
                    hintText: 'Number of Branches',
                    textInputType: TextInputType.number,
                    onSaved: (v) => branches = v ?? '',
                    prefixIcon: const Icon(
                      Icons.store_mall_directory_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),

                  CustomTextFormField(
                    controller: _distanceController,
                    hintText: 'Branch Distance',
                    textInputType: TextInputType.text,
                    onSaved: (v) => distance = v ?? '',
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Status ──
                  _SectionTitle(title: 'Status'),
                  const SizedBox(height: 12),

                  _ToggleRow(
                    label: 'Is Available',
                    value: isAvailable,
                    onChanged: (v) => setState(() => isAvailable = v),
                  ),
                  const SizedBox(height: 10),
                  _ToggleRow(
                    label: 'Is Open',
                    value: isOpend,
                    onChanged: (v) => setState(() => isOpend = v),
                  ),

                  const SizedBox(height: 24),

                  // ── Update Image ──
                  _SectionTitle(title: 'Update Image'),
                  const SizedBox(height: 4),
                  Text(
                    'Leave empty to keep the current image',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 12),

                  ImageField(
                    onFileChange: (file) => newImage = file,
                  ),

                  const SizedBox(height: 28),

                  // ── Save Button ──
                  CustomButton(
                    onPressed: _onSave,
                    text: 'Save Changes',
                    useGradient: true,
                    fontSize: 16,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.always);
      return;
    }
    _formKey.currentState!.save();

    final updatedEntity = AddProductInputEntity(
      docId: widget.product.docId,
      name: name,
      branches: branches,
      distance: distance,
      isOpend: isOpend,
      isAvailable: isAvailable,
      image: newImage,                   // null = keep old image
      imageUrl: widget.product.imageUrl, // fallback to existing url
    );

    context.read<AddProductCubit>().updateProduct(
          widget.product.docId ?? '',
          updatedEntity,
        );
  }
}

// ── Image Header ──────────────────────────────────────────────────────────────
class _ImageHeader extends StatelessWidget {
  const _ImageHeader({required this.imageUrl, required this.name});
  final String? imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback(),
                )
              : _fallback(),
        ),
        // dark gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.55),
                ],
              ),
            ),
          ),
        ),
        // name label
        Positioned(
          bottom: 16,
          left: 20,
          right: 20,
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFF0F4F3),
      child: Icon(
        Icons.restaurant_rounded,
        size: 64,
        color: AppColors.primaryColor.withOpacity(0.25),
      ),
    );
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

// ── Toggle Row ────────────────────────────────────────────────────────────────
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppColors.primaryColor.withOpacity(0.3)
              : const Color(0xFFEEEEEE),
        ),
      ),
      child: Row(
        children: [
          Icon(
            value
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: value ? AppColors.primaryColor : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: value ? AppColors.primaryColor : Colors.grey[600],
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
}
