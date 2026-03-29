import 'package:flutter/material.dart';

class SpecialCard extends StatelessWidget {
  const SpecialCard({
    super.key,
    required this.child,
    this.gradient,
    this.borderRadius = 16,
    this.elevation = 4,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderColor,
    this.borderWidth = 0,
  });

  final Widget child;
  final LinearGradient? gradient;
  final double borderRadius;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    Widget cardWidget = Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? Colors.white : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: elevation.toDouble(),
            offset: Offset(0, elevation * 0.5),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardWidget);
    }

    return cardWidget;
  }
}
