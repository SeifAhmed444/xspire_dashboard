import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF1F5E3B);
  static const Color primaryLight = Color(0xFF2E7D52);
  static const Color primaryDark = Color(0xFF154A2A);

  // Secondary Colors
  static const Color secoundryColor = Color(0XFFF4A91F);
  static const Color secoundryLight = Color(0xFFFFC107);
  static const Color secoundryDark = Color(0xFFD68A15);

  // Accent Colors
  static const Color accentColor = Color(0xFF00BCD4);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFA726);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1F5E3B), Color(0xFF2E7D52)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFF4A91F), Color(0xFFFFC107)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFF1F5E3B), Color(0xFFF4A91F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
