import 'package:flutter/material.dart';
import 'app_constants.dart';

ThemeData get appTheme {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.accentYellow,
      primary: AppConstants.primaryDark,
      secondary: AppConstants.accentYellow,
      surface: Colors.white,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppConstants.primaryDark,
      foregroundColor: Colors.white,
      elevation: AppConstants.appBarElevation,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppConstants.cardBackground,
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.accentYellow,
        foregroundColor: AppConstants.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppConstants.primaryDark,
      selectedItemColor: AppConstants.accentYellow,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
