import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xspire_dashboard/core/services/user_session.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';
import 'package:xspire_dashboard/features/manage_data/domain/entities/restaurant_entity.dart';
import 'package:xspire_dashboard/features/manage_data/presentation/cubit/restaurant_cubit.dart';

/// Single bottom sheet used for both Add and Edit flows.
/// Pass [existing] to enter edit mode.
class RestaurantFormSheet extends StatefulWidget {
  const RestaurantFormSheet({super.key, this.existing});
  final RestaurantEntity? existing;

  @override
  State<RestaurantFormSheet> createState() => _RestaurantFormSheetState();
}

class _RestaurantFormSheetState extends State<RestaurantFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _branchesCtrl;
  late final TextEditingController _distanceCtrl;

  bool _isOpend = false;
  bool _isAvailable = false;
  File? _pickedImage;
  bool _isSubmitting = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _branchesCtrl = TextEditingController(text: e?.branches ?? '');
    _distanceCtrl = TextEditingController(text: e?.distance ?? '');
    _isOpend = e?.isOpend ?? false;
    _isAvailable = e?.isAvailable ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _branchesCtrl.dispose();
    _distanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RestaurantCubit, RestaurantState>(
      listener: (context, state) {
        if (state is RestaurantOperationSuccess) {
          Navigator.pop(context); // close sheet
        }
        if (state is RestaurantError) {
          setState(() => _isSubmitting = false);
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Handle ─────────────────────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // ── Title ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      _isEdit ? 'Edit Restaurant' : 'Add Restaurant',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Divider(),

              // ── Form ───────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField(
                          controller: _nameCtrl,
                          label: 'Restaurant Name',
                          hint: 'e.g. Burger Palace',
                          icon: Icons.storefront_rounded,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: _branchesCtrl,
                          label: 'Number of Branches',
                          hint: 'e.g. 5',
                          icon: Icons.store_mall_directory_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          controller: _distanceCtrl,
                          label: 'Distance / Location',
                          hint: 'e.g. 2.5 km from city center',
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 16),

                        // ── Toggles ───────────────────────────────────────
                        _buildToggleRow(
                          label: 'Is Open',
                          icon: Icons.access_time_rounded,
                          value: _isOpend,
                          onChanged: (v) => setState(() => _isOpend = v),
                        ),
                        const SizedBox(height: 10),
                        _buildToggleRow(
                          label: 'Is Available',
                          icon: Icons.check_circle_outline_rounded,
                          value: _isAvailable,
                          onChanged: (v) =>
                              setState(() => _isAvailable = v),
                        ),
                        const SizedBox(height: 20),

                        // ── Image picker ──────────────────────────────────
                        _buildImagePicker(),
                        const SizedBox(height: 24),

                        // ── Submit ────────────────────────────────────────
                        _buildSubmitButton(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? '$label is required' : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(icon, size: 20, color: AppColors.primaryColor),
            ),
            hintStyle:
                TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFA),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.primaryColor, width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.errorColor)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    final existingUrl = widget.existing?.imageUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Restaurant Image',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242))),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.4),
                  width: 1.5,
                  style: BorderStyle.solid),
              color: AppColors.primaryColor.withOpacity(0.03),
            ),
            child: _pickedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.file(_pickedImage!, fit: BoxFit.cover),
                  )
                : existingUrl != null && existingUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(existingUrl, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _imagePlaceholder()),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Tap to change',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _imagePlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 40, color: AppColors.primaryColor.withOpacity(0.5)),
        const SizedBox(height: 8),
        Text('Tap to select image',
            style: TextStyle(
                fontSize: 13, color: Colors.grey[500])),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xfile != null) {
      setState(() => _pickedImage = File(xfile.path));
    }
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  _isEdit ? 'Save Changes' : 'Add Restaurant',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final cubit = context.read<RestaurantCubit>();

    if (_isEdit) {
      cubit.updateRestaurant(
        existing: widget.existing!,
        name: _nameCtrl.text.trim(),
        branches: _branchesCtrl.text.trim(),
        distance: _distanceCtrl.text.trim(),
        isOpend: _isOpend,
        isAvailable: _isAvailable,
        newImageFile: _pickedImage,
      );
    } else {
      cubit.addRestaurant(
        name: _nameCtrl.text.trim(),
        branches: _branchesCtrl.text.trim(),
        distance: _distanceCtrl.text.trim(),
        isOpend: _isOpend,
        isAvailable: _isAvailable,
        userEmail: UserSession.instance.currentEmail,
        imageFile: _pickedImage,
      );
    }
  }
}