import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

/// AnimatedCard - A card with slide/fade animation on appearance
/// and scale animation on tap
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final int index;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const AnimatedCard({
    super.key,
    required this.child,
    this.index = 0,
    this.onTap,
    this.margin = const EdgeInsets.all(8),
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderRadius = 20,
    this.boxShadow,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = Container(
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: widget.boxShadow ??
            [
              BoxShadow(
                color: AppColors.shadowLight.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      card = GestureDetector(
        onTapDown: (_) => _tapController.forward(),
        onTapUp: (_) {
          _tapController.reverse();
          widget.onTap!();
        },
        onTapCancel: () => _tapController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: card,
            );
          },
        ),
      );
    }

    return card
        .animate(delay: (widget.index * 80).ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
