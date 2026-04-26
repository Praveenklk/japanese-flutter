import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// GradientButton - A button with purple gradient background
/// Supports various sizes and animation on press
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final double borderRadius;
  final IconData? icon;
  final bool isOutlined;
  final Color? textColor;
  final EdgeInsetsGeometry padding;
  final bool isLoading;
  final double fontSize;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.icon,
    this.isOutlined = false,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    this.isLoading = false,
    this.fontSize = 16,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: widget.isOutlined
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: Border.all(
                        color: AppColors.primaryDeepPurple,
                        width: 2,
                      ),
                    )
                  : BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDeepPurple.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.isOutlined
                                  ? AppColors.primaryDeepPurple
                                  : (widget.textColor ?? Colors.white),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              color: widget.isOutlined
                                  ? AppColors.primaryDeepPurple
                                  : (widget.textColor ?? Colors.white),
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
