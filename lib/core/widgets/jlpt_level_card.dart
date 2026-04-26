import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // ← ADD THIS
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import 'level_badge.dart';

class JLPTLevelCard extends StatelessWidget {
  final String level;
  final String description;
  final String subtitle;
  final double progress;
  final int totalItems;
  final int completedItems;
  final VoidCallback onTap;
  final int index;

  const JLPTLevelCard({
    super.key,
    required this.level,
    required this.description,
    required this.subtitle,
    required this.progress,
    required this.totalItems,
    required this.completedItems,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final levelColor = AppColors.getLevelColor(level);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1A38) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: levelColor.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: levelColor.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LevelBadge(level: level),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: levelColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$completedItems/$totalItems',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: levelColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% completed',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    ).animate(
      delay: (index * 100).ms,
    ).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }
}