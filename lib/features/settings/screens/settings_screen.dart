import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../providers/theme_provider.dart';

/// SettingsScreen - App settings with dark mode, language, and reset options
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage =
          prefs.getString(AppConstants.keyLanguagePreference) ?? 'English';
    });
  }

  Future<void> _saveLanguagePreference(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguagePreference, language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  Future<void> _resetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: 8),
            const Text('Reset Progress'),
          ],
        ),
        content: const Text(
          'This will reset all your learning progress, streaks, and XP. This action cannot be undone. Are you sure?',
        ),
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
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyDailyStreak);
      await prefs.remove(AppConstants.keyTotalXP);
      await prefs.remove(AppConstants.keyCompletedLessons);
      await prefs.remove(AppConstants.keyLastStudyDate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All progress has been reset'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

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
              // Custom App Bar
              SliverToBoxAdapter(
                child: CustomAppBar(
                  title: 'Settings',
                  showBackButton: true,
                ),
              ),

              // Appearance Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text(
                    'Appearance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),

              // Dark Mode Toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassCard(
                    blurAmount: 15,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primarySoftPurple.withOpacity(0.2)
                                : AppColors.primaryPalePurple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            color: isDark
                                ? AppColors.primarySoftPurple
                                : AppColors.primaryDeepPurple,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dark Mode',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isDark ? 'Currently dark' : 'Currently light',
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
                        Switch.adaptive(
                          value: isDark,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                          activeColor: AppColors.primarySoftPurple,
                          activeTrackColor:
                              AppColors.primarySoftPurple.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Language Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),

              // Language Options
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassCard(
                    blurAmount: 15,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        _buildLanguageOption(
                          'English',
                          'English',
                          isDark: isDark,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildLanguageOption(
                          '日本語',
                          'Japanese',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Account Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),

              // Reset Progress
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: _resetProgress,
                    child: GlassCard(
                      blurAmount: 15,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reset Progress',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Clear all learning data',
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
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.error,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // About Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),

              // App Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassCard(
                    blurAmount: 15,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // App logo
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Center(
                            child: Text(
                              '日',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version ${AppConstants.appVersion}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Learn Japanese from JLPT N5 to N1 with interactive lessons, flashcards, and quizzes.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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

  Widget _buildLanguageOption(
    String label,
    String value, {
    required bool isDark,
  }) {
    final isSelected = _selectedLanguage == value;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryDeepPurple.withOpacity(0.15)
              : (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.language,
          color: isSelected
              ? AppColors.primaryDeepPurple
              : (isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight),
          size: 22,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: AppColors.primaryDeepPurple,
              size: 22,
            )
          : null,
      onTap: () => _saveLanguagePreference(value),
    );
  }
}
