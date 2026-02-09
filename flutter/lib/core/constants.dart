import 'package:flutter/material.dart';

class AppColors {
  // Brand / accent colors (same in light and dark)
  static const purple = Color(0xFF7B2D8E);
  static const purpleLight = Color(0xFF9B59B6);
  static const purpleDark = Color(0xFF5B1D6E);
  static const pink = Color(0xFFE91E8C);
  static const pinkLight = Color(0xFFFF6BB5);
  static const teal = Color(0xFF2EC4B6);
  static const orange = Color(0xFFF4845F);
  static const orangeLight = Color(0xFFFBBF7D);
  static const coral = Color(0xFFFF6B6B);
  static const yellow = Color(0xFFF9C74F);
  static const yellowLight = Color(0xFFFDE68A);

  // Light structural colors
  static const backgroundLight = Color(0xFFFFFFFF);
  static const foregroundLight = Color(0xFF1A1A2E);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const lavenderLight = Color(0xFFE8D5F5);
  static const mintLight = Color(0xFFD0F0E8);

  // Dark structural colors
  static const backgroundDark = Color(0xFF121218);
  static const foregroundDark = Color(0xFFE8E8F0);
  static const surfaceDark = Color(0xFF1C1C24);
  static const lavenderDark = Color(0xFF3D2A4D);
  static const mintDark = Color(0xFF1A3028);

  // Legacy static references (keep for non-context code)
  static const foreground = foregroundLight;
  static const background = backgroundLight;
  static const lavender = lavenderLight;
  static const mint = mintLight;

  // Context-aware helpers
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color fg(BuildContext context) =>
      _isDark(context) ? foregroundDark : foregroundLight;

  static Color bg(BuildContext context) =>
      _isDark(context) ? backgroundDark : backgroundLight;

  static Color surface(BuildContext context) =>
      _isDark(context) ? surfaceDark : surfaceLight;

  static Color lav(BuildContext context) =>
      _isDark(context) ? lavenderDark : lavenderLight;

  static Color mn(BuildContext context) =>
      _isDark(context) ? mintDark : mintLight;

  static const accentColors = [pink, teal, orange, coral, purpleLight];

  static Color accentForIndex(int index) =>
      accentColors[index % accentColors.length];
}
