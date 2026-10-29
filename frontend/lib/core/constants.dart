import 'package:flutter/material.dart';

class AppColors {
  // Light Theme
  static const Color backgroundLight = Color(0xFFF7F9F3);
  static const Color cardLight = Color(0xFFEDF1E6);
  static const Color textLight = Color(0xFF16231A);
  static const Color textSecondaryLight = Color(0xFF4F5A4C);

  // Dark Theme
  static const Color backgroundDark = Color(0xFF121513);
  static const Color cardDark = Color(0xFF1F2420);
  static const Color surfaceDark = Color(0xFF181B19);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFA1ABA0);

  // Brand / Actions
  static const Color primaryGreen = Color(0xFF1B7F36);
  static const Color accentLime = Color(0xFFCCFF00); // Lime accent on dark theme
  static const Color accentGreenLight = Color(0xFFE2F3D8);

  // Macros
  static const Color protein = Color(0xFFD9532B); // Coral
  static const Color carbs = Color(0xFF1C86C4);   // Blue
  static const Color fat = Color(0xFFB97A00);     // Amber

  // Warning / Over Limit
  static const Color warning = Color(0xFFB97A00); // Amber 80% to 100%
  static const Color over = Color(0xFFC62828);    // Red > 100%
  static const Color warningBg = Color(0xFFFFF3CD);
  static const Color overBg = Color(0xFFFFEBEE);

  // Neutral
  static const Color borderSubtle = Color(0xFFE2E7DB);
  static const Color borderDark = Color(0xFF2C332D);
}

class AppDimensions {
  static const double cardRadius = 24.0;
  static const double buttonRadius = 28.0;
  static const double chipRadius = 16.0;
  static const double padding = 16.0;
  static const double pagePadding = 20.0;
}

