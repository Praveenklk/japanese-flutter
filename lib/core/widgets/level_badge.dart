import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// LevelBadge - Displays a JLPT level badge with appropriate color
class LevelBadge extends StatelessWidget {
  final String level;
  final double size;
  final bool showLabel;

  const LevelBadge({
    super.key,
    required this.level,
    this.size = 32,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.getLevelColor(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            level,
            style: TextStyle(
              color: color,
              fontSize: size * 0.44,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
