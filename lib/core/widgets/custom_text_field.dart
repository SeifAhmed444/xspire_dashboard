import 'package:flutter/material.dart';
import 'package:xspire_dashboard/core/utils/app_text_style.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.textInputType,
    this.suffixIcon,
    this.maxLines = 1,
    this.onSaved,
    this.obscureText = false,
    this.prefixIcon,
    this.validator,
    this.controller,  // ← added
  });

  final String hintText;
  final TextInputType textInputType;
  final int? maxLines;
  final Widget? suffixIcon;
  final void Function(String?)? onSaved;
  final bool obscureText;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final TextEditingController? controller; // ← added

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller, // ← added
      maxLines: widget.maxLines,
      obscureText: widget.obscureText,
      onSaved: widget.onSaved,
      focusNode: _focusNode,
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },
      keyboardType: widget.textInputType,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: widget.prefixIcon,
              )
            : null,
        suffixIcon: widget.suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: widget.suffixIcon,
              )
            : null,
        hintStyle: TextStyles.bold13.copyWith(color: const Color(0xFF949D9E)),
        hintText: widget.hintText,
        filled: true,
        fillColor: const Color(0xFFF9FAFA),
        border: _buildBorder(borderColor: const Color(0xFFE6E9E9)),
        enabledBorder: _buildBorder(borderColor: const Color(0xFFE6E9E9)),
        focusedBorder: _buildBorder(
          borderColor: const Color(0xFF1F5E3B),
          width: 2,
        ),
        errorBorder: _buildBorder(borderColor: const Color(0xFFE53935)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder({
    required Color borderColor,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(width: width, color: borderColor),
    );
  }
}
