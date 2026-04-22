import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/services/get_it_services.dart';
import 'package:xspire_dashboard/core/services/user_session.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/features/products/domain/entities/product_entity.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/add_product_usecase.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/get_products_usecase.dart';
import 'package:xspire_dashboard/features/products/domain/usecases/update_product_usecase.dart';
import 'package:xspire_dashboard/features/products/presentation/cubit/product_cubit.dart';

class AddItemView extends StatelessWidget {
  const AddItemView({super.key});
  static const routeName = 'add_item';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductCubit(
        addProductUseCase: getIt<AddProductUseCase>(),
        getProductsUseCase: getIt<GetProductsUseCase>(),
        updateProductUseCase: getIt<UpdateProductUseCase>(),
        deleteProductUseCase: getIt<DeleteProductUseCase>(),
      ),
      child: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is AddProductSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text('Product added successfully!'),
                ]),
                backgroundColor: AppColors.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is ProductError) {
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
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7F5),
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text('Add Product',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: state is ProductLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                : const _AddItemForm(),
          );
        },
      ),
    );
  }
}

class _AddItemForm extends StatefulWidget {
  const _AddItemForm();

  @override
  State<_AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<_AddItemForm> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Product Details'),
            const SizedBox(height: 16),
            _buildField(
              controller: _nameController,
              label: 'Product Name',
              hint: 'e.g. Margherita Pizza',
              icon: Icons.label_outline_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _descController,
              label: 'Description',
              hint: 'Describe the product...',
              icon: Icons.description_outlined,
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _priceController,
              label: 'Price (EGP)',
              hint: 'e.g. 149.99',
              icon: Icons.attach_money_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Price is required';
                if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                if (double.parse(v.trim()) < 0) return 'Price cannot be negative';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _imageUrlController,
              label: 'Image URL',
              hint: 'https://example.com/image.jpg',
              icon: Icons.image_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Image URL is required';
                final uri = Uri.tryParse(v.trim());
                if (uri == null || !uri.hasAbsolutePath) return 'Enter a valid URL';
                return null;
              },
            ),
            const SizedBox(height: 8),
            // Preview
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _imageUrlController,
              builder: (_, value, __) {
                final url = value.text.trim();
                if (url.isEmpty) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      url,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(child: Text('Invalid image URL', style: TextStyle(color: Colors.grey))),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            _buildSubmitButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF424242))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Icon(icon, size: 20, color: AppColors.primaryColor)),
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryColor, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.errorColor)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.errorColor, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
          label: const Text('Add Product', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          onPressed: _submit,
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.always);
      return;
    }

    final product = ProductEntity(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      imageUrl: _imageUrlController.text.trim(),
      userId: UserSession.instance.currentUserId,
    );

    context.read<ProductCubit>().addProduct(product);
  }
}
