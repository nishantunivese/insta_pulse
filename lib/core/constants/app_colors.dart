import 'package:flutter/material.dart';

class AppColors {
  // Brand Gradients (Instagram Signature Gradient)
  static const List<Color> instagramGradient = [
    Color(0xFFFEDA75), // Yellow
    Color(0xFFFA7E1E), // Orange
    Color(0xFFD62976), // Pinkish Red
    Color(0xFF962FBF), // Purple
    Color(0xFF4F5BD5), // Deep Blue/Purple
  ];

  static const List<Color> storyGradient = [
    Color(0xFFFF8A00),
    Color(0xFFE52E71),
    Color(0xFFFF007A),
  ];

  static const List<Color> liveGradient = [
    Color(0xFFE20338),
    Color(0xFFC6017E),
  ];

  // Primary Accents
  static const Color primaryBlue = Color(0xFF0095F6); // Instagram Primary Blue
  static const Color primaryBlueHover = Color(0xFF1877F2);
  static const Color verifiedBlue = Color(0xFF3897F0); // Blue checkmark
  static const Color likeRed = Color(0xFFED4956); // Heart red
  static const Color bookmarkYellow = Color(0xFFFFB800);

  // Analytics Specific Accents
  static const Color analyticsPurple = Color(0xFF8B5CF6);
  static const Color deltaPositive = Color(0xFF10B981); // Emerald green for growth
  static const Color deltaNegative = Color(0xFFEF4444); // Red for drop
  static const Color deltaWarning = Color(0xFFF59E0B);
  static const Color editedBadge = Color(0xFF6366F1); // Indigo for locally edited

  // Dark Theme Palette (Instagram OLED Dark Mode)
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceElevated = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0xFF262626);
  static const Color darkDivider = Color(0xFF363636);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFA8A8A8);
  static const Color darkTextMuted = Color(0xFF737373);
  static const Color darkInputBg = Color(0xFF262626);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFAFAFA);
  static const Color lightSurfaceElevated = Color(0xFFF0F2F5);
  static const Color lightBorder = Color(0xFFDBDBDB);
  static const Color lightDivider = Color(0xFFEFEFEF);
  static const Color lightTextPrimary = Color(0xFF262626);
  static const Color lightTextSecondary = Color(0xFF737373);
  static const Color lightTextMuted = Color(0xFF8E8E8E);
  static const Color lightInputBg = Color(0xFFEFEFEF);
}
