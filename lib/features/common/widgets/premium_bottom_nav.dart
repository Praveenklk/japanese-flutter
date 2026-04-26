import 'dart:ui';
import 'package:flutter/material.dart';

class PremiumBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const PremiumBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Light mode: purple/violet gradient (original)
    // Dark mode: sakura‑inspired deep rose/plum gradient
    final gradientColors = isDark
        ? const [Color(0xFF5C2A4A), Color(0xFF9B4D6E)]  // deep plum → muted rose
        : const [Color(0xFF4B3FC7), Color(0xFF6C5CE7)]; // original purple/violet

    final borderColor = Colors.white.withOpacity(isDark ? 0.12 : 0.14);
    final shadowColor = (isDark ? gradientColors[0] : const Color(0xFF4B3FC7)).withOpacity(isDark ? 0.25 : 0.30);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    selected: selectedIndex == 0,
                    onTap: () => onTap(0),
                    isDark: isDark,
                  ),
                  _NavItem(
                    icon: Icons.menu_book_rounded,
                    label: 'Study',
                    selected: selectedIndex == 1,
                    onTap: () => onTap(1),
                    isDark: isDark,
                  ),
                  _NavItem(
                    icon: Icons.quiz_rounded,
                    label: 'Test',
                    selected: selectedIndex == 2,
                    onTap: () => onTap(2),
                    isDark: isDark,
                  ),
                  _NavItem(
                    icon: Icons.show_chart_rounded,
                    label: 'Progress',
                    selected: selectedIndex == 3,
                    onTap: () => onTap(3),
                    isDark: isDark,
                  ),
                  _NavItem(
                    icon: Icons.grid_view_rounded,
                    label: 'More',
                    selected: selectedIndex == 4,
                    onTap: () => onTap(4),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Light mode: selected text/icon white, unselected white with opacity 0.72
    // Dark mode: same logic but using a slightly warmer white to match sakura
    final baseColor = Colors.white;
    final color = selected ? baseColor : baseColor.withOpacity(0.72);

    // Selected background: white with 0.12 opacity in both modes (looks good on both gradients)
    final selectedBgColor = baseColor.withOpacity(0.12);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? selectedBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: selected ? 1.1 : 1,
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}