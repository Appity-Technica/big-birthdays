import 'package:flutter/material.dart';

class AppColors {
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
  static const lavender = Color(0xFFE8D5F5);
  static const mint = Color(0xFFD0F0E8);
  static const foreground = Color(0xFF1A1A2E);
  static const background = Color(0xFFFFFFFF);

  static const accentColors = [pink, teal, orange, coral, purpleLight];

  static Color accentForIndex(int index) =>
      accentColors[index % accentColors.length];
}
