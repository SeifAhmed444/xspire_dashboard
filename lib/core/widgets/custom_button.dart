import 'package:flutter/material.dart';
import 'package:xspire_dashboard/core/utils/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.borderRadius = 16,
    this.padding,
    this.fontSize = 16,
    this.useGradient = false,
    this.elevation = 4,
  });

  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double fontSize;
  final bool useGradient;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primaryColor;

    if (useGradient) {
      return _buildGradientButton(bgColor);
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          backgroundColor: bgColor,
          elevation: elevation,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(Color bgColor) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
