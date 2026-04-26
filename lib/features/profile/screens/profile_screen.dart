import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/animated_card.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/route_generator.dart';

/// ProfileScreen - User profile with avatar, stats, achievements, and settings
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _dailyStreak = 0;
  int _totalXP = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyStreak = prefs.getInt(AppConstants.keyDailyStreak) ?? 5;
      _totalXP = prefs.getInt(AppConstants.keyTotalXP) ?? 1250;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteGenerator.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final userName =
        authProvider.userName.isNotEmpty ? authProvider.userName : 'Guest';
    final isGuest = authProvider.isGuest;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: [AppColors.backgroundDark, AppColors.surfaceDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : LinearGradient(
                  colors: [AppColors.backgroundLight, AppColors.surfaceLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Profile Header
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDeepPurple.withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : 'N',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .scale(duration: 500.ms),

                      const SizedBox(height: 20),

                      // Name
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

                      const SizedBox(height: 8),

                      // Email (not shown for guest)
                      if (!isGuest && authProvider.userEmail.isNotEmpty)
                        Text(
                          authProvider.userEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                      if (isGuest)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Guest Account',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Level badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.n5Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'N5 - Beginner',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.local_fire_department,
                          value: '$_dailyStreak',
                          label: 'Day Streak',
                          color: AppColors.streakOrange,
                          index: 0,
                        ),
                      ),
                      Expanded(
                        child: StatCard(
                          icon: Icons.star,
                          value: '$_totalXP',
                          label: 'Total XP',
                          color: AppColors.xpGold,
                          index: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Achievements Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),

              // Achievement Cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: _achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = _achievements[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AnimatedCard(
                        index: index,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: achievement.unlocked
                                    ? AppColors.primaryGradient
                                    : LinearGradient(
                                        colors: [
                                          Colors.grey.withOpacity(0.3),
                                          Colors.grey.withOpacity(0.1),
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                achievement.icon,
                                color: achievement.unlocked
                                    ? Colors.white
                                    : Colors.grey,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    achievement.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    achievement.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (achievement.unlocked)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 24,
                              )
                            else
                              Icon(
                                Icons.lock_outline,
                                color: isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Menu Items
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),

              // Settings Menu
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassCard(
                    blurAmount: 15,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.settings,
                          title: 'App Settings',
                          subtitle: 'Theme, language, and more',
                          onTap: () => Navigator.pushNamed(
                            context,
                            RouteGenerator.settings,
                          ),
                          isDark: isDark,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'FAQs and contact',
                          onTap: () {
                            // TODO: Navigate to help
                          },
                          isDark: isDark,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildMenuItem(
                          icon: Icons.info_outline,
                          title: 'About',
                          subtitle: 'App version and info',
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: AppConstants.appName,
                              applicationVersion: AppConstants.appVersion,
                              applicationIcon: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    '日',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                              children: [
                                const Text(
                                    'Nihongo Master - Your Japanese learning companion.'),
                              ],
                            );
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Logout Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GradientButton(
                    text: 'Logout',
                    onPressed: _logout,
                    width: double.infinity,
                    icon: Icons.logout,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryDeepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryDeepPurple,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
      ),
      onTap: onTap,
    );
  }
}

/// Achievement data model
class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;

  _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });
}

final List<_Achievement> _achievements = [
  _Achievement(
    title: 'First Steps',
    description: 'Complete your first lesson',
    icon: Icons.emoji_events,
    unlocked: true,
  ),
  _Achievement(
    title: 'On Fire',
    description: 'Maintain a 3-day streak',
    icon: Icons.local_fire_department,
    unlocked: true,
  ),
  _Achievement(
    title: 'Quiz Master',
    description: 'Score 100% on a quiz',
    icon: Icons.psychology,
    unlocked: false,
  ),
  _Achievement(
    title: 'Dedicated',
    description: 'Maintain a 7-day streak',
    icon: Icons.calendar_today,
    unlocked: false,
  ),
  _Achievement(
    title: 'N5 Complete',
    description: 'Complete all N5 lessons',
    icon: Icons.school,
    unlocked: false,
  ),
];
