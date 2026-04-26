import 'package:flutter/material.dart';
import 'glass_card.dart';

/// CustomAppBar - A reusable glassmorphism app bar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double height;
  final bool transparent;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
    this.height = 64,
    this.transparent = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GlassCard(
          blurAmount: 20,
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                )
              else if (leading != null)
                leading!
              else
                const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (actions != null) ...actions!,
              if (actions == null) const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}
