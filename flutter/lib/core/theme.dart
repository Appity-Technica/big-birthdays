import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

ThemeData buildAppTheme() {
  final nunitoTextTheme = GoogleFonts.nunitoTextTheme();

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: Brightness.light,
      primary: AppColors.purple,
      secondary: AppColors.pink,
      tertiary: AppColors.teal,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.foregroundLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: _buildTextTheme(nunitoTextTheme, AppColors.foregroundLight),
    appBarTheme: _buildAppBarTheme(AppColors.surfaceLight),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    outlinedButtonTheme: _buildOutlinedButtonTheme(AppColors.lavenderLight),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.purple,
      foregroundColor: Colors.white,
    ),
    cardTheme: _buildCardTheme(AppColors.surfaceLight),
    inputDecorationTheme: _buildInputTheme(AppColors.lavenderLight, AppColors.surfaceLight),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: AppColors.purple,
      unselectedItemColor: AppColors.foregroundLight,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surfaceLight,
      elevation: 8,
    ),
  );
}

ThemeData buildDarkTheme() {
  final nunitoTextTheme = GoogleFonts.nunitoTextTheme(
    ThemeData(brightness: Brightness.dark).textTheme,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: Brightness.dark,
      primary: AppColors.purpleLight,
      secondary: AppColors.pink,
      tertiary: AppColors.teal,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.foregroundDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme: _buildTextTheme(nunitoTextTheme, AppColors.foregroundDark),
    appBarTheme: _buildAppBarTheme(AppColors.surfaceDark),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    outlinedButtonTheme: _buildOutlinedButtonTheme(AppColors.lavenderDark),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.purple,
      foregroundColor: Colors.white,
    ),
    cardTheme: _buildCardTheme(AppColors.surfaceDark),
    inputDecorationTheme: _buildInputTheme(AppColors.lavenderDark, AppColors.surfaceDark),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: AppColors.purpleLight,
      unselectedItemColor: AppColors.foregroundDark,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surfaceDark,
      elevation: 8,
    ),
  );
}

// Shared builders

TextTheme _buildTextTheme(TextTheme base, Color foreground) {
  return base.copyWith(
    headlineLarge: GoogleFonts.baloo2(
      fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.purple,
    ),
    headlineMedium: GoogleFonts.baloo2(
      fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.purple,
    ),
    headlineSmall: GoogleFonts.baloo2(
      fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.purple,
    ),
    titleLarge: GoogleFonts.baloo2(
      fontSize: 18, fontWeight: FontWeight.bold, color: foreground,
    ),
  );
}

AppBarTheme _buildAppBarTheme(Color surface) {
  return AppBarTheme(
    backgroundColor: surface,
    foregroundColor: AppColors.purple,
    elevation: 0,
    scrolledUnderElevation: 1,
    titleTextStyle: GoogleFonts.baloo2(
      fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.purple,
    ),
  );
}

ElevatedButtonThemeData _buildElevatedButtonTheme() {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.purple,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
    ),
  );
}

OutlinedButtonThemeData _buildOutlinedButtonTheme(Color borderColor) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.purple,
      side: BorderSide(color: borderColor, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  );
}

CardThemeData _buildCardTheme(Color surface) {
  return CardThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 0,
    color: surface,
  );
}

InputDecorationTheme _buildInputTheme(Color borderColor, Color fillColor) {
  return InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.purple, width: 2),
    ),
    filled: true,
    fillColor: fillColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
