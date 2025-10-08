import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// App theme configuration
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimary,
      onError: AppColors.white,
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.background,

    // App Bar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.appBarTitle,
      iconTheme: IconThemeData(color: AppColors.white),
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: AppTextStyles.inputHint,
      labelStyle: AppTextStyles.inputLabel,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: AppColors.primary, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTextStyles.buttonSecondary,
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: AppTextStyles.button,
      ),
    ),

    // Icon Button
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.white,
      elevation: 4,
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Tab Bar
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.accent,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTextStyles.tabActive,
      unselectedLabelStyle: AppTextStyles.tabInactive,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.accent, width: 3),
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.greyLight,
      thickness: 1,
      space: 1,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.buttonSecondary,
      labelStyle: AppTextStyles.bodySmall,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.white,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.h1,
      displayMedium: AppTextStyles.h2,
      displaySmall: AppTextStyles.h3,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.button,
      labelSmall: AppTextStyles.caption,
    ),
  );

  // Dark theme can be added later if needed
  // static ThemeData darkTheme = ThemeData(...);
}
