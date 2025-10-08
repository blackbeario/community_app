import 'package:flutter/material.dart';

/// App color palette based on design specifications
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2E2750);
  static const Color background = Color(0xFFE8E4F3);
  static const Color surface = Color(0xFFF5F3FA);
  static const Color accent = Color(0xFF4A9FE8);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);

  // Interaction Colors
  static const Color like = Color(0xFF4A9FE8);
  static const Color comment = Color(0xFF4A9FE8);
  static const Color unread = Color(0xFFE85050);

  // Button Colors
  static const Color buttonPrimary = Color(0xFF2E2750);
  static const Color buttonSecondary = Color(0xFFE8E4F3);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE85050);
  static const Color info = Color(0xFF4A9FE8);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF616161);
}
