import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTextStyles - Centralized text styles for the application
class AppTextStyles {
  AppTextStyles._();

  // ==================== Display Styles ====================
  static TextStyle displayLarge(bool isDark) => GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextPrimary(isDark),
        letterSpacing: -0.5,
      );

  static TextStyle displayMedium(bool isDark) => GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextPrimary(isDark),
        letterSpacing: -0.5,
      );

  static TextStyle displaySmall(bool isDark) => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.getTextPrimary(isDark),
      );

  // ==================== Heading Styles ====================
  static TextStyle headingLarge(bool isDark) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextPrimary(isDark),
      );

  static TextStyle headingMedium(bool isDark) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.getTextPrimary(isDark),
      );

  static TextStyle headingSmall(bool isDark) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.getTextPrimary(isDark),
      );

  // ==================== Body Styles ====================
  static TextStyle bodyLarge(bool isDark) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.getTextSecondary(isDark),
        height: 1.5,
      );

  static TextStyle bodyMedium(bool isDark) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.getTextSecondary(isDark),
        height: 1.5,
      );

  static TextStyle bodySmall(bool isDark) => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.getTextTertiary(isDark),
        height: 1.4,
      );

  // ==================== Japanese Text Styles ====================
  static TextStyle japaneseLarge(bool isDark) => GoogleFonts.notoSansJp(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        color: AppColors.getTextPrimary(isDark),
      );

  static TextStyle japaneseMedium(bool isDark) => GoogleFonts.notoSansJp(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: AppColors.getTextPrimary(isDark),
      );

  static TextStyle japaneseSmall(bool isDark) => GoogleFonts.notoSansJp(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.getTextSecondary(isDark),
      );

  static TextStyle japaneybody(bool isDark) => GoogleFonts.notoSansJp(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.getTextSecondary(isDark),
      );

  static TextStyle romajiStyle(bool isDark) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        color: AppColors.getTextTertiary(isDark),
        letterSpacing: 0.5,
      );

  // ==================== Special Styles ====================
  static TextStyle buttonText(bool isDark) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  static TextStyle caption(bool isDark) => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.getTextTertiary(isDark),
        letterSpacing: 0.5,
      );

  static TextStyle streakText(bool isDark) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.streakOrange,
      );

  static TextStyle xpText(bool isDark) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.xpGold,
      );

  static TextStyle levelBadge(bool isDark) => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1,
      );

  // ==================== Gradient Text ====================
  static Shader gradientTextShader(Rect bounds) {
    return const LinearGradient(
      colors: [
        AppColors.primaryDeepPurple,
        AppColors.primaryViolet,
        AppColors.primarySoftPurple,
      ],
    ).createShader(bounds);
  }
}
