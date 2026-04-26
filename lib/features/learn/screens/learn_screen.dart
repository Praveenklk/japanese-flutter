import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/progress/progress_service.dart';
import '../../../providers/auth_provider.dart';
import '../../common/widgets/premium_bottom_nav.dart';
import '../data/learning_data.dart';
import 'level_detail_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  int _selectedNavIndex = 1;
  bool _isGridView = false;
  bool _isLoading = true;

  final ProgressService _progressService = ProgressService();
  Map<String, LevelProgress> _levelsProgress = {};

  @override
  void initState() {
    super.initState();
    _initProgress();
  }

  Future<void> _initProgress() async {
    await _progressService.init();
    await _loadRealProgress();
  }

  bool _isLevelLocked(String level) {
    return level != 'N5';
  }

  Future<void> _loadRealProgress() async {
    final wordsLearned = _progressService.wordsLearned;
    final kanjiLearned = _progressService.kanjiLearned;
    final grammarLearned = _progressService.grammarLearned;

    final targets = {
      'N5': {'words': 800, 'kanji': 100, 'grammar': 50},
      'N4': {'words': 1500, 'kanji': 300, 'grammar': 100},
      'N3': {'words': 3750, 'kanji': 650, 'grammar': 200},
      'N2': {'words': 6000, 'kanji': 1000, 'grammar': 300},
      'N1': {'words': 10000, 'kanji': 2000, 'grammar': 500},
    };

    final levels = LearningData.allLevels;
    final Map<String, LevelProgress> temp = {};

    int cumulativeWords = 0;
    int cumulativeKanji = 0;
    int cumulativeGrammar = 0;

    for (final level in levels) {
      final levelKey = level.level;
      final target = targets[levelKey]!;

      final wordsForLevel =
          (wordsLearned - cumulativeWords).clamp(0, target['words']!);
      final kanjiForLevel =
          (kanjiLearned - cumulativeKanji).clamp(0, target['kanji']!);
      final grammarForLevel =
          (grammarLearned - cumulativeGrammar).clamp(0, target['grammar']!);

      final totalItems =
          target['words']! + target['kanji']! + target['grammar']!;
      final completedItems = wordsForLevel + kanjiForLevel + grammarForLevel;
      final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

      temp[levelKey] = LevelProgress(
        completed: completedItems,
        total: totalItems,
        progress: progress,
      );

      cumulativeWords += target['words']!;
      cumulativeKanji += target['kanji']!;
      cumulativeGrammar += target['grammar']!;
    }

    if (!mounted) return;
    setState(() {
      _levelsProgress = temp;
      _isLoading = false;
    });
  }


  void _navigateToDetail(String level) {
    if (_isLevelLocked(level)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete N5 to unlock the next levels.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LevelDetailScreen(level: level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final levels = LearningData.allLevels;
    final authProvider = context.watch<AuthProvider>();

    final dynamic rawName = authProvider.userName;
    final userName = (rawName?.toString() ?? '').trim().isNotEmpty
        ? rawName.toString().trim()
        : 'Learner';
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'L';

    final surfaceColor =
        isDark ? const Color(0xFF1E1A38) : const Color(0xFFFFFFFF);
    final screenBg =
        isDark ? const Color(0xFF12101E) : const Color(0xFFF5F4FD);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: screenBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: screenBg,
        body: Column(
          children: [
            _WavyHeader(
              isDark: isDark,
              userName: userName,
              initials: initials,
              streak: _progressService.streak,
              reviews: _progressService.totalReviews,
              wordsLearned: _progressService.wordsLearned,
              isGridView: _isGridView,
              onToggleView: () {
                HapticFeedback.lightImpact();
                setState(() => _isGridView = !_isGridView);
              },
            ).animate().fadeIn(duration: 350.ms),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadRealProgress,
                color: AppColors.primaryDeepPurple,
                child: ListView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    _SectionTitle(
                      isDark: isDark,
                      title: 'Choose your level',
                      subtitle: 'N5 is open. Complete it to unlock the next stages.',
                    ),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: _isGridView
                          ? _buildGrid(levels, isDark, surfaceColor)
                          : _buildList(levels, isDark, surfaceColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildList(
  List<dynamic> levels,
  bool isDark,
  Color surfaceColor,
) {
  return Column(
    children: List.generate(levels.length, (index) {
      final level = levels[index];

      final progressData = _levelsProgress[level.level] ??
          const LevelProgress(completed: 0, total: 0, progress: 0);

      final isLocked = level.level != 'N5';

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _LevelListCard(
          isDark: isDark,
          surfaceColor: surfaceColor,
          level: level.level,
          title: level.description,
          subtitle: level.subtitle,
          description: 'Learning content',
          completedItems: progressData.completed,
          totalItems: progressData.total,
          progress: progressData.progress,
          isLocked: isLocked,
          onTap: () => _navigateToDetail(level.level),
          index: index,
        ),
      );
    }),
  );
}

  Widget _buildGrid(
    List<dynamic> levels,
    bool isDark,
    Color surfaceColor,
  ) {
    return GridView.builder(
      key: const ValueKey('grid'),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: levels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final level = levels[index];
        final progressData = _levelsProgress[level.level] ??
            const LevelProgress(completed: 0, total: 0, progress: 0);
        final isLocked = _isLevelLocked(level.level);

        return _LevelGridCard(
          isDark: isDark,
          surfaceColor: surfaceColor,
          level: level.level,
          title: level.description,
          subtitle: level.subtitle,
          completedItems: progressData.completed,
          totalItems: progressData.total,
          progress: progressData.progress,
          isLocked: isLocked,
          onTap: () => _navigateToDetail(level.level),
          index: index,
        );
      },
    );
  }

  String _levelDescription(dynamic level) {
    try {
      if (level.categories is List && level.categories.isNotEmpty) {
        return '${level.categories.length} learning categories';
      }
    } catch (_) {}
    return 'Learning content';
  }
}

class _WavyHeader extends StatelessWidget {
  final bool isDark;
  final String userName;
  final String initials;
  final int streak;
  final int reviews;
  final int wordsLearned;
  final bool isGridView;
  final VoidCallback onToggleView;

  const _WavyHeader({
    required this.isDark,
    required this.userName,
    required this.initials,
    required this.streak,
    required this.reviews,
    required this.wordsLearned,
    required this.isGridView,
    required this.onToggleView,
  });

  String _formatValue(int value) {
    if (value < 1000) return '$value';
    if (value < 1000000) return '${(value / 1000).toStringAsFixed(1)}K';
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4B3FC7), Color(0xFF6C5CE7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: topPadding + 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
  children: [
    Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          isGridView
              ? Icons.grid_view_rounded
              : Icons.view_agenda_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: onToggleView,
      ),
    ),

    const Spacer(),

    // 🔥 UPDATED PROFILE ICON (CLICKABLE)
    GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pushNamed(context, '/profile');
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.18),
          border: Border.all(
            color: Colors.white.withOpacity(0.35),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),
  ],
),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learning Path',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.82),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Master Japanese from N5 to N1',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.72),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _StatPill(
                      value: '$streak',
                      label: 'Day streak',
                      icon: Icons.local_fire_department_rounded,
                    ),
                    const SizedBox(width: 10),
                    _StatPill(
                      value: _formatValue(reviews),
                      label: 'Reviews',
                      icon: Icons.auto_awesome_rounded,
                    ),
                    const SizedBox(width: 10),
                    _StatPill(
                      value: _formatValue(wordsLearned),
                      label: 'Words',
                      icon: Icons.menu_book_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            painter: _WavePainter(
              color: isDark ? const Color(0xFF12101E) : const Color(0xFFF5F4FD),
            ),
            child: const SizedBox(height: 28),
          ),
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  const _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.55);
    path.quadraticBezierTo(
      size.width * 0.20,
      0,
      size.width * 0.50,
      size.height * 0.42,
    );
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height * 0.82,
      size.width,
      size.height * 0.30,
    );
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatPill({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.72),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.isDark,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ],
    );
  }
}

class _LevelListCard extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor; // kept for compatibility, not used
  final String level;
  final String title;
  final String subtitle;
  final String description;
  final double progress;
  final int totalItems;
  final int completedItems;
  final bool isLocked;
  final VoidCallback onTap;
  final int index;

  const _LevelListCard({
    required this.isDark,
    required this.surfaceColor,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.progress,
    required this.totalItems,
    required this.completedItems,
    required this.isLocked,
    required this.onTap,
    required this.index,
  });

  // Sakura colour palette (inline)
  static const _rose = Color(0xFFE8527A);
  static const _roseSoft = Color(0xFFF0839F);
  static const _sage = Color(0xFF5F8B6E);
  static const _gold = Color(0xFFB8820C);
  static const _inkMuted = Color(0xFF7A5060);
  static const _nightSurf = Color(0xFF1E1020);
  static const _moonText = Color(0xFFFFE8F0);
  static const _moonMuted = Color(0xFF7A4560);
  static const _ink = Color(0xFF1C0E14);

  Color _getLevelColor() {
    switch (level) {
      case 'N5': return _rose;
      case 'N4': return _sage;
      case 'N3': return _gold;
      case 'N2': return _inkMuted;
      case 'N1': return _roseSoft;
      default: return _rose;
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor();
    final percent = (progress * 100).round();

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This level is locked. Complete N5 to unlock it.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isDark
                ? [_nightSurf.withOpacity(0.9), levelColor.withOpacity(0.12)]
                : [Colors.white.withOpacity(0.9), levelColor.withOpacity(0.08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: levelColor.withOpacity(isDark ? 0.3 : 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: levelColor.withOpacity(0.15),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: levelColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isLocked ? Icons.lock_rounded : Icons.auto_awesome_rounded,
                            color: levelColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: levelColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            level,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: levelColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? _moonText : _ink,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? _moonMuted : _inkMuted,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11.2,
                        color: isDark ? _moonMuted.withOpacity(0.7) : _inkMuted.withOpacity(0.7),
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05),
                              valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$percent%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: levelColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _InfoChip(
                          label: '$completedItems/$totalItems',
                          icon: Icons.check_circle_rounded,
                          color: levelColor,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          label: isLocked ? 'Locked' : 'Continue',
                          icon: isLocked ? Icons.lock_rounded : Icons.play_arrow_rounded,
                          color: levelColor,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isLocked)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Complete N5 first',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 70).ms)
        .fadeIn(duration: 280.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}

class _LevelGridCard extends StatelessWidget {
  final bool isDark;
  final Color surfaceColor;
  final String level;
  final String title;
  final String subtitle;
  final double progress;
  final int totalItems;
  final int completedItems;
  final bool isLocked;
  final VoidCallback onTap;
  final int index;

  const _LevelGridCard({
    required this.isDark,
    required this.surfaceColor,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.totalItems,
    required this.completedItems,
    required this.isLocked,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = AppColors.getLevelColor(level);
    final percent = (progress * 100).round();

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This level is locked. Complete N5 to unlock it.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1E1A38),
                    levelColor.withOpacity(0.08),
                  ]
                : [
                    Colors.white,
                    levelColor.withOpacity(0.04),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: levelColor.withOpacity(isDark ? 0.18 : 0.14),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: levelColor.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: levelColor.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isLocked
                                ? Icons.lock_rounded
                                : Icons.auto_awesome_rounded,
                            color: levelColor,
                            size: 18,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: levelColor.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            level,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: levelColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.2,
                        color: isDark ? Colors.white54 : Colors.black45,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // const Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '$completedItems/$totalItems',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: levelColor,
                          ),
                        ),
                        // const Spacer(),
                        Text(
                          '$percent%',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isLocked)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.black.withOpacity(isDark ? 0.22 : 0.12),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Locked',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (index * 70).ms)
        .fadeIn(duration: 280.ms)
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
        );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _InfoChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.10 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LevelProgress {
  final int completed;
  final int total;
  final double progress;

  const LevelProgress({
    required this.completed,
    required this.total,
    required this.progress,
  });
}