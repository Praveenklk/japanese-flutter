import 'package:flutter/material.dart';

/// AppColors - Centralized color palette for Nihongo Master
/// Uses a purple gradient theme with glassmorphism support
class AppColors {
  AppColors._();

  // ==================== Primary Gradient Colors ====================
  static const Color primaryDeepPurple = Color(0xFF7C3AED);
  static const Color primaryViolet = Color(0xFF9333EA);
  static const Color primarySoftPurple = Color(0xFFA855F7);
  static const Color primaryLightPurple = Color(0xFFC4B5FD);
  static const Color primaryPalePurple = Color(0xFFEDE9FE);

  // ==================== Gradient Definitions ====================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDeepPurple, primaryViolet, primarySoftPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientHorizontal = LinearGradient(
    colors: [primaryDeepPurple, primaryViolet, primarySoftPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x40FFFFFF),
      Color(0x20FFFFFF),
      Color(0x10FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== Background Colors ====================
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0B0F1A);
  static const Color backgroundSecondaryLight = Color(0xFFF8F7FC);
  static const Color backgroundSecondaryDark = Color(0xFF151B2B);
  static const Color surfaceLight = Color(0xFFF3F0FF);
  static const Color surfaceDark = Color(0xFF1E2740);
static const Color primary = primaryDeepPurple;
static const Color accent = primaryViolet;
  // ==================== Glass Effect Colors ====================
  static const Color glassLight = Color(0x40FFFFFF);
  static const Color glassDark = Color(0x301E2740);
  static const Color glassBorderLight = Color(0x60FFFFFF);
  static const Color glassBorderDark = Color(0x30404040);

  // ==================== Text Colors (Light Theme) ====================
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);

  // ==================== Text Colors (Dark Theme) ====================
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);

  // ==================== Accent Colors ====================
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ==================== JLPT Level Colors ====================
  // ✨ NEW: JLPT Level Colors (as specified)
  static const Color n5Color = Color(0xFF3B82F6); // Green - Beginner
  static const Color n4Color = Color(0xFF3B82F6); // Blue - Elementary
  static const Color n3Color = Color(0xFFF59E0B); // Yellow - Intermediate
  static const Color n2Color = Color(0xFFEF4444); // Red - Advanced
  static const Color n1Color = Color(0xFF7C3AED); // Purple - Mastery

  // ==================== Streak & XP Colors ====================
  static const Color streakOrange = Color(0xFFFF6B35);
  static const Color xpGold = Color(0xFFFFD700);

  // ==================== Card Colors ====================
  static List<Color> cardGradients = [
    const Color(0xFF7C3AED),
    const Color(0xFFEC4899),
    const Color(0xFF3B82F6),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
  ];

  // ==================== Shadow Colors ====================
  static const Color shadowLight = Color(0x1A7C3AED);
  static const Color shadowDark = Color(0x40000000);

  // ==================== Helper Methods ====================
  static Color getBackgroundColor(bool isDark) =>
      isDark ? backgroundDark : backgroundLight;

  static Color getSurfaceColor(bool isDark) =>
      isDark ? surfaceDark : surfaceLight;

  static Color getSecondaryBackground(bool isDark) =>
      isDark ? backgroundSecondaryDark : backgroundSecondaryLight;

  static Color getTextPrimary(bool isDark) =>
      isDark ? textPrimaryDark : textPrimaryLight;

  static Color getTextSecondary(bool isDark) =>
      isDark ? textSecondaryDark : textSecondaryLight;

  static Color getTextTertiary(bool isDark) =>
      isDark ? textTertiaryDark : textTertiaryLight;

  static Color getGlassColor(bool isDark) =>
      isDark ? glassDark : glassLight;

  static Color getGlassBorder(bool isDark) =>
      isDark ? glassBorderDark : glassBorderLight;

  static Color getLevelColor(String level) {
    switch (level) {
      case 'N5':
        return n5Color;
      case 'N4':
        return n4Color;
      case 'N3':
        return n3Color;
      case 'N2':
        return n2Color;
      case 'N1':
        return n1Color;
      default:
        return primaryDeepPurple;
    }
  }
}
