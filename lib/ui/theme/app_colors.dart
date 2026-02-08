import 'package:flutter/material.dart';

/// App color palette for premium dark theme.
class AppColors {
  AppColors._();

  // Primary gradient colors
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryCyan = Color(0xFF06B6D4);
  static const Color primaryPink = Color(0xFFEC4899);

  // Background colors
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color backgroundCard = Color(0xFF1A1A2E);
  static const Color backgroundElevated = Color(0xFF252542);

  // Surface colors (glassmorphism)
  static const Color surfaceGlass = Color(0x1AFFFFFF);
  static const Color surfaceBorder = Color(0x33FFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B4C4);
  static const Color textMuted = Color(0xFF6B6B80);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color gold = Color(0xFFFFD700);
  static const Color progressBarBackground = Color(0xFF2A2A40);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [primaryPink, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(124, 58, 237, 0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color.fromRGBO(124, 58, 237, 0.4),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
