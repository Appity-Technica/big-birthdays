import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

ThemeData buildAppTheme() {
  final nunitoTextTheme = GoogleFonts.nunitoTextTheme();

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      primary: AppColors.purple,
      secondary: AppColors.pink,
      tertiary: AppColors.teal,
      surface: AppColors.background,
      onSurface: AppColors.foreground,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: nunitoTextTheme.copyWith(
      headlineLarge: GoogleFonts.baloo2(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.purple,
      ),
      headlineMedium: GoogleFonts.baloo2(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.purple,
      ),
      headlineSmall: GoogleFonts.baloo2(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.purple,
      ),
      titleLarge: GoogleFonts.baloo2(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.foreground,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.purple,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleTextStyle: GoogleFonts.baloo2(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.purple,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.nunito(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.purple,
        side: const BorderSide(color: AppColors.lavender, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.purple,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lavender, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lavender, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.purple, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.purple,
      unselectedItemColor: AppColors.foreground,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 8,
    ),
  );
}
