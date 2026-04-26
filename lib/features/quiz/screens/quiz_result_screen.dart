import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/quiz_provider.dart';
import '../../../routes/route_generator.dart';

/// QuizResultScreen - compact, premium, no-scroll result layout
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quizProvider = context.watch<QuizProvider>();

    final rating = quizProvider.getPerformanceRating();
    final ratingColor = quizProvider.getRatingColor();
    final message = quizProvider.getPerformanceMessage();

    final totalQuestions = quizProvider.totalQuestions == 0
        ? 1
        : quizProvider.totalQuestions;

    final accuracy = (quizProvider.score / totalQuestions * 100).round();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: [
                    AppColors.backgroundDark,
                    AppColors.surfaceDark.withOpacity(0.92),
                    AppColors.backgroundDark,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : LinearGradient(
                  colors: [
                    AppColors.backgroundLight,
                    AppColors.surfaceLight.withOpacity(0.96),
                    AppColors.backgroundLight,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                _TopBar(
                  isDark: isDark,
                  ratingColor: ratingColor,
                  rating: rating,
                ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.08, end: 0),

                const SizedBox(height: 12),

                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _HeroCard(
                          isDark: isDark,
                          rating: rating,
                          ratingColor: ratingColor,
                          message: message,
                          score: quizProvider.score,
                          totalQuestions: totalQuestions,
                          accuracy: accuracy,
                        )
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 420.ms)
                            .scale(begin: const Offset(0.96, 0.96)),
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        flex: 4,
                        child: _StatsGrid(
                          isDark: isDark,
                          quizProvider: quizProvider,
                        )
                            .animate()
                            .fadeIn(delay: 180.ms, duration: 420.ms)
                            .slideY(begin: 0.08, end: 0),
                      ),

                      const SizedBox(height: 12),

                      _MiniSummaryCard(
                        isDark: isDark,
                        quizProvider: quizProvider,
                      )
                          .animate()
                          .fadeIn(delay: 260.ms, duration: 380.ms)
                          .slideY(begin: 0.08, end: 0),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _PrimaryActionButton(
                        text: 'Play Again',
                        icon: Icons.refresh_rounded,
                        onPressed: () {
                          quizProvider.startQuiz(
                            quizProvider.currentLevel,
                            quizProvider.currentCategory,
                          );
                        },
                      ).animate().fadeIn(delay: 330.ms, duration: 350.ms).slideY(begin: 0.06, end: 0),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SecondaryActionButton(
                        text: 'Back to Home',
                        icon: Icons.home_rounded,
                        onPressed: () {
                          quizProvider.resetQuiz();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            RouteGenerator.home,
                            (route) => false,
                          );
                        },
                      ).animate().fadeIn(delay: 390.ms, duration: 350.ms).slideY(begin: 0.06, end: 0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isDark;
  final Color ratingColor;
  final String rating;

  const _TopBar({
    required this.isDark,
    required this.ratingColor,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.62),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: ratingColor.withOpacity(0.14)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ratingColor.withOpacity(0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz Complete!',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You finished the round successfully',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(isDark ? 0.16 : 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: ratingColor.withOpacity(0.18)),
                ),
                child: Text(
                  rating,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: ratingColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final bool isDark;
  final String rating;
  final Color ratingColor;
  final String message;
  final int score;
  final int totalQuestions;
  final int accuracy;

  const _HeroCard({
    required this.isDark,
    required this.rating,
    required this.ratingColor,
    required this.message,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ratingColor.withOpacity(isDark ? 0.16 : 0.10),
                Colors.transparent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.60),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: ratingColor.withOpacity(0.14)),
            boxShadow: [
              BoxShadow(
                color: ratingColor.withOpacity(0.10),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.85, end: 1.0),
                duration: 500.ms,
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        ratingColor,
                        ratingColor.withOpacity(0.72),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ratingColor.withOpacity(0.35),
                        blurRadius: 28,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Rating',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ratingColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _HeroStat(
                      isDark: isDark,
                      label: 'Correct',
                      value: '$score/$totalQuestions',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeroStat(
                      isDark: isDark,
                      label: 'Accuracy',
                      value: '$accuracy%',
                      icon: Icons.pie_chart_rounded,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HeroStat(
                      isDark: isDark,
                      label: 'XP',
                      value: '+${context.read<QuizProvider>().totalXP}',
                      icon: Icons.star_rounded,
                      color: AppColors.xpGold,
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
}

class _HeroStat extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _HeroStat({
    required this.isDark,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final bool isDark;
  final QuizProvider quizProvider;

  const _StatsGrid({
    required this.isDark,
    required this.quizProvider,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuestions = quizProvider.totalQuestions == 0
        ? 1
        : quizProvider.totalQuestions;
    final accuracy = (quizProvider.score / totalQuestions * 100).round();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryDeepPurple.withOpacity(0.10)),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.6,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
              isDark: isDark,
              label: 'Correct Answers',
              value: '${quizProvider.score}/$totalQuestions',
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
            ),
            _StatCard(
              isDark: isDark,
              label: 'XP Earned',
              value: '+${quizProvider.totalXP}',
              icon: Icons.star_rounded,
              color: AppColors.xpGold,
            ),
            _StatCard(
              isDark: isDark,
              label: 'Accuracy',
              value: '$accuracy%',
              icon: Icons.insights_rounded,
              color: AppColors.info,
            ),
            _StatCard(
              isDark: isDark,
              label: 'Best Streak',
              value: '${quizProvider.maxStreak}',
              icon: Icons.local_fire_department_rounded,
              color: AppColors.streakOrange,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.isDark,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.10 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.14),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
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
    );
  }
}

class _MiniSummaryCard extends StatelessWidget {
  final bool isDark;
  final QuizProvider quizProvider;

  const _MiniSummaryCard({
    required this.isDark,
    required this.quizProvider,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuestions = quizProvider.totalQuestions == 0
        ? 1
        : quizProvider.totalQuestions;
    final missed = totalQuestions - quizProvider.score;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDeepPurple.withOpacity(isDark ? 0.14 : 0.08),
                Colors.transparent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.white.withOpacity(0.52),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.primaryDeepPurple.withOpacity(0.14),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You missed $missed question${missed == 1 ? '' : 's'}. Review and play again to improve your score.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDeepPurple.withOpacity(0.24),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(duration: 120.ms, curve: Curves.easeOut);
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _SecondaryActionButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.62),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primaryDeepPurple.withOpacity(0.18),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.primaryDeepPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: AppColors.primaryDeepPurple,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(duration: 120.ms, curve: Curves.easeOut);
  }
}