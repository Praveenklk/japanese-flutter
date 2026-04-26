import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

/// AnimatedProgressBar - A customizable animated progress bar
class AnimatedProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final bool showPercentage;
  final String? label;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.height = 12,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 10,
    this.showPercentage = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                if (showPercentage)
                  Text(
                    '${(clampedProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDeepPurple,
                    ),
                  ),
              ],
            ),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ??
                (isDark
                    ? AppColors.surfaceDark
                    : AppColors.primaryPalePurple.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: clampedProgress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: foregroundColor != null
                        ? LinearGradient(
                            colors: [foregroundColor!, foregroundColor!],
                          )
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: (foregroundColor ?? AppColors.primaryDeepPurple)
                            .withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ).animate().scaleX(
                    begin: 0,
                    end: 1,
                    duration: 800.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
