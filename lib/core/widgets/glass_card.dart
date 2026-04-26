import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// GlassCard - A glassmorphism card widget with blur effect
/// Creates a frosted glass look with optional gradient border
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double blurAmount;
  final bool useGradientBorder;
  final Color? customColor;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.blurAmount = 15,
    this.useGradientBorder = false,
    this.customColor,
    this.width,
    this.height,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = customColor ?? AppColors.getGlassColor(isDark);

    Widget cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          margin: margin,
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(
                  color: AppColors.getGlassBorder(isDark),
                  width: 1,
                ),
          ),
          child: child,
        ),
      ),
    );

    if (useGradientBorder) {
      cardContent = Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(1.5),
        margin: margin,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(borderRadius + 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: AppColors.getBackgroundColor(isDark).withOpacity(0.9),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: child,
            ),
          ),
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 150),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
