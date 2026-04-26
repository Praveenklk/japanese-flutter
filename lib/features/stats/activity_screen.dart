import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:ui';

import '../../core/constants/app_colors.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  Box get _box => Hive.box('progressBox');

  Map<String, int> activity = {};
  int streak = 0;
  int bestStreak = 0;
  int totalReviews = 0;
  List<int> heatmapData = [];

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  void _loadActivity() {
    final stored = _box.get('daily_activity') ?? {};
    activity = Map<String, int>.from(stored);
    _calculateStats();
    setState(() {});
  }

  void _calculateStats() {
    // Generate heatmap data (last 90 days)
    heatmapData = [];
    for (int i = 89; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = date.toIso8601String().split('T')[0];
      heatmapData.add(activity[key] ?? 0);
    }

    // Calculate current streak
    streak = 0;
    for (int i = 0; i < 90; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = date.toIso8601String().split('T')[0];
      if ((activity[key] ?? 0) > 0) {
        streak++;
      } else {
        break;
      }
    }

    // Calculate best streak (over last 90 days)
    bestStreak = 0;
    int current = 0;
    for (int i = 0; i < 90; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = date.toIso8601String().split('T')[0];
      if ((activity[key] ?? 0) > 0) {
        current++;
        bestStreak = bestStreak > current ? bestStreak : current;
      } else {
        current = 0;
      }
    }

    // Total reviews
    totalReviews = activity.values.fold(0, (a, b) => a + b);
  }

  Color _getHeatmapColor(int value, bool isDark) {
    if (value == 0) {
      return isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.05);
    }
    if (value < 3) return AppColors.primaryViolet.withOpacity(0.4);
    if (value < 6) return AppColors.primaryViolet.withOpacity(0.65);
    if (value < 10) return AppColors.primaryViolet.withOpacity(0.85);
    return AppColors.primaryViolet;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColors = isDark
        ? [
            AppColors.backgroundDark,
            AppColors.surfaceDark.withOpacity(0.95),
            AppColors.backgroundDark,
          ]
        : [
            AppColors.backgroundLight,
            AppColors.surfaceLight.withOpacity(0.97),
            AppColors.backgroundLight,
          ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated glowing orbs
              Positioned(
                top: -50,
                left: -30,
                child: _glowOrb(
                  AppColors.primaryDeepPurple.withOpacity(0.12),
                  180,
                ),
              ),
              Positioned(
                bottom: -60,
                right: -40,
                child: _glowOrb(
                  AppColors.primaryViolet.withOpacity(0.10),
                  200,
                ),
              ),
              Positioned(
                top: 200,
                right: -20,
                child: _glowOrb(
                  AppColors.xpGold.withOpacity(0.06),
                  140,
                ),
              ),

              // Main content
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(isDark),
                    const SizedBox(height: 24),

                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '🔥 Streak',
                            '$streak days',
                            Icons.local_fire_department_rounded,
                            AppColors.primaryViolet,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildStatCard(
                            '🏆 Best',
                            '$bestStreak days',
                            Icons.emoji_events_rounded,
                            AppColors.xpGold,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '📚 Reviews',
                            '$totalReviews',
                            Icons.school_rounded,
                            AppColors.primaryDeepPurple,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildStatCard(
                            '📅 Active Days',
                            '${activity.length}',
                            Icons.calendar_today_rounded,
                            Colors.teal,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Heatmap Card
                    _buildHeatmapCard(isDark),
                    const SizedBox(height: 20),

                    // Motivation Card
                    _buildMotivationCard(isDark),
                    const SizedBox(height: 12),

                    // Small tip
                    Text(
                      'Keep reviewing daily to grow your streak!',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.primaryDeepPurple.withOpacity(0.12),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: AppColors.primaryViolet,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Activity Dashboard',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color accentColor,
    bool isDark,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.65),
              border: Border.all(
                color: accentColor.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: accentColor, size: 24),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeatmapCard(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.7),
            border: Border.all(
              color: AppColors.primaryDeepPurple.withOpacity(0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_view_month_rounded,
                    color: AppColors.primaryViolet,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Activity Heatmap',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.primaryViolet.withOpacity(0.15),
                    ),
                    child: Text(
                      'Last 90 days',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryViolet,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Heatmap grid
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: heatmapData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  return Tooltip(
                    message: '${90 - index} days ago: $value reviews',
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _getHeatmapColor(value, isDark),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Less',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getHeatmapColor(0, isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getHeatmapColor(2, isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getHeatmapColor(5, isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getHeatmapColor(8, isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getHeatmapColor(12, isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'More',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationCard(bool isDark) {
    String message;
    if (streak == 0) {
      message = "Start your streak today! 🚀";
    } else if (streak < 7) {
      message = "You're on fire! Keep it up 🔥";
    } else if (streak < 30) {
      message = "Amazing $streak day streak! Don't stop now 💪";
    } else {
      message = "Legendary! $streak days – you're unstoppable! 🏆";
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDeepPurple.withOpacity(0.8),
                AppColors.primaryViolet.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  streak > 0 ? Icons.whatshot_rounded : Icons.rocket_launch,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      streak > 0 ? 'Keep it rolling!' : 'Ready to begin?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

Widget _glowOrb(Color color, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
    ),
  ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
        duration: 4000.ms,
        begin: const Offset(0.92, 0.92),
        end: const Offset(1.08, 1.08),
        curve: Curves.easeInOut,
      );
}