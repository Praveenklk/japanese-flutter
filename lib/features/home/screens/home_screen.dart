import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/progress/progress_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/route_generator.dart';
// import '../../quiz/screens/quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _email = '';
  int _dailyStreak = 0;
  int _totalXP = 0;
  int _totalSecondsSpent = 0;
  double _dailyProgress = 0.0;

  late Future<String> _tipFuture;
  late AnimationController _pulseController;

final List<_ProgressTab> _tabs = const [
  _ProgressTab(label: 'All', iconText: '全'),
  _ProgressTab(label: 'Hiragana', iconText: 'あ'),
  _ProgressTab(label: 'Katakana', iconText: 'カ'),
  _ProgressTab(label: 'Kanji', iconText: '漢'),
  _ProgressTab(label: 'Grammar', iconText: '文'),
  _ProgressTab(label: 'Vocabulary', iconText: '語'),
];

  int _selectedTabIndex = 0;


  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _loadStats();
    _tipFuture = _fetchTip();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final progress = ProgressService();
    setState(() {
      _email = prefs.getString('email') ??
          prefs.getString('user_email') ??
          prefs.getString('login_email') ??
          '';
      _dailyStreak = prefs.getInt(AppConstants.keyDailyStreak) ??
          (progress.streak > 0 ? progress.streak : 0);
      _totalXP = prefs.getInt(AppConstants.keyTotalXP) ?? 1250;
      _dailyProgress = prefs.getDouble('daily_progress') ?? 0.60;
      _totalSecondsSpent = progress.totalTimeSpent;
    });
  }

  Future<String> _fetchTip() async {
    try {
      final res = await ApiService.get(ApiEndpoints.dailyTip);
      return (res['tip'] ?? 'Stay consistent every day!').toString();
    } catch (_) {
      return 'Stay consistent — small steps daily!';
    }
  }


List<_DayPoint> _buildWeeklyData() {
  final progress = ProgressService();

  Map<String, int> data;

  // 🔥 SWITCH BASED ON SELECTED TAB
  if (_selectedTabIndex == 0) {
    // ALL
    data = progress.dailyTimeSpent;
  } else {
    final typeMap = {
      1: "hiragana",
      2: "katakana",
      3: "kanji",
      4: "grammar",
      5: "vocab",
    };

    String type = typeMap[_selectedTabIndex]!;

    data = progress.getDailyTimeByType(type);
  }

  final now = DateTime.now();

  return List.generate(7, (index) {
    final day = now.subtract(Duration(days: 6 - index));
    final key = day.toIso8601String().split('T')[0];
    final seconds = data[key] ?? 0;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return _DayPoint(
      label: '${day.day} ${months[day.month - 1]}',
      value: seconds / 60.0,
    );
  });
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    final dynamic rawName = authProvider.userName;
    final userName = (rawName?.toString() ?? '').trim().isNotEmpty
        ? rawName.toString().trim()
        : 'Learner';

    final weeklyData = _buildWeeklyData();
    final maxValue = weeklyData
        .map((e) => e.value)
        .fold<double>(0, (prev, v) => v > prev ? v : prev);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF12101E) : const Color(0xFFF5F4FD),
        body: Column(
          children: [
            // ── HEADER with wavy bottom ──────────────────────────────────
            _WavyHeader(
              isDark: isDark,
              userName: userName,
              email: _email,
              dailyStreak: _dailyStreak,
              totalSecondsSpent: _totalSecondsSpent,
              onMenuTap: () {},
              onProfileTap: () {
                HapticFeedback.selectionClick();
                Navigator.pushNamed(context, '/profile');
              },
            ).animate().fadeIn(duration: 400.ms),

            // ── SCROLLABLE CONTENT ────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadStats,
                color: AppColors.primaryDeepPurple,
                child: ListView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  children: [
                    // Tip card right at top of scroll content
                    FutureBuilder<String>(
                      future: _tipFuture,
                      builder: (context, snapshot) {
                        final tip = snapshot.connectionState ==
                                ConnectionState.waiting
                            ? 'Loading your tip...'
                            : (snapshot.data ?? 'Stay consistent — small steps daily!');
                        return _TipCard(isDark: isDark, tip: tip)
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 400.ms);
                      },
                    ),

                    const SizedBox(height: 18),

                    // Progress section title
                    _SectionTitle(
                      isDark: isDark,
                      title: 'Progress',
                      subtitle: 'Choose a category to continue',
                    ),

                    const SizedBox(height: 10),

                    // Compact horizontal tabs
                    SizedBox(
                      height: 76,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _tabs.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final tab = _tabs[index];
                          final selected = _selectedTabIndex == index;
                          return _ProgressChip(
  isDark: isDark,
  label: tab.label,
  icon: tab.icon,
  iconText: tab.iconText, // ✅ IMPORTANT
  selected: selected,
  onTap: () => setState(() => _selectedTabIndex = index),
);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Chart card
                    _ChartCard(
                      isDark: isDark,
                      title: _selectedTabIndex == 0
                          ? 'Study Progress'
                          : '${_tabs[_selectedTabIndex].label} Progress',
                      subtitle: 'Time spent during the last 7 days',
                      maxValue: maxValue <= 0 ? 90 : maxValue,
                      data: weeklyData,
                    ).animate().fadeIn(delay: 180.ms, duration: 400.ms),

                    const SizedBox(height: 12),

                    // Time spent card
                    _TimeSpentCard(
                      isDark: isDark,
                      totalSecondsSpent: _totalSecondsSpent,
                    ).animate().fadeIn(delay: 240.ms, duration: 400.ms),

                    const SizedBox(height: 12),

                    // Interactive learn card
                    _InteractiveLearnCard(
                      isDark: isDark,
                      progress: _dailyProgress,
onTap: () {
  // Do nothing OR show message
}
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WAVY HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _WavyHeader extends StatelessWidget {
  final bool isDark;
  final String userName;
  final String email;
  final int dailyStreak;
  final int totalSecondsSpent;
  final VoidCallback onMenuTap;
  final VoidCallback onProfileTap;

  const _WavyHeader({
    required this.isDark,
    required this.userName,
    required this.email,
    required this.dailyStreak,
    required this.totalSecondsSpent,
    required this.onMenuTap,
    required this.onProfileTap,
  });

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'N';
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Main gradient body
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

              // Top row: menu + avatar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onMenuTap,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.menu_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onProfileTap,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.18),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.35), width: 2),
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

              // Welcome + name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.80),
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
                      email.isNotEmpty ? email : 'Guest',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.70),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Stat pills row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _StatPill(
                      icon: Icons.schedule_rounded,
                      label: 'Study time',
                      value: _formatTime(totalSecondsSpent),
                    ),
                    const SizedBox(width: 10),
                    _StatPill(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Daily streak',
                      value: '$dailyStreak days',
                    ),
                  ],
                ),
              ),

              // Space for wave
              const SizedBox(height: 24),
            ],
          ),
        ),

        // Wave clipper painted on top
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            painter: _WavePainter(
                color: isDark ? const Color(0xFF12101E) : const Color(0xFFF5F4FD)),
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
    path.lineTo(0, size.height * 0.5);
    path.quadraticBezierTo(
        size.width * 0.25, 0, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.8, size.width, size.height * 0.3);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.color != color;
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.72),
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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

// ─────────────────────────────────────────────────────────────────────────────
// TIP CARD  (shown at top of scroll, just below header)
// ─────────────────────────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final bool isDark;
  final String tip;

  const _TipCard({required this.isDark, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1A38) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF6C5CE7).withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B3FC7).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4B3FC7), Color(0xFF6C5CE7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip of the Day',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4B3FC7),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tip,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? Colors.white70 : Colors.black54,
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

// ─────────────────────────────────────────────────────────────────────────────
// SECTION TITLE
// ─────────────────────────────────────────────────────────────────────────────

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
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
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

// ─────────────────────────────────────────────────────────────────────────────
// PROGRESS CHIP  (compact — no more giant 96px height)
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressChip extends StatelessWidget {
  final bool isDark;
  final String label;
  final IconData? icon;     // ✅ optional
  final String? iconText;   // ✅ NEW (for Japanese)
  final bool selected;
  final VoidCallback onTap;

  const _ProgressChip({
    required this.isDark,
    required this.label,
    this.icon,
    this.iconText,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4B3FC7);
    const violet = Color(0xFF6C5CE7);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 72,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? purple.withOpacity(isDark ? 0.22 : 0.10)
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? violet.withOpacity(0.55)
                : (isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06)),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selected
                    ? violet.withOpacity(0.15)
                    : (isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.withOpacity(0.08)),
                borderRadius: BorderRadius.circular(10),
              ),

              // 🔥 MAIN FIX HERE
              child: iconText != null
                  ? Center(
                      child: Text(
                        iconText!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: selected
                              ? purple
                              : (isDark ? Colors.white54 : Colors.black45),
                        ),
                      ),
                    )
                  : Icon(
                      icon ?? Icons.circle,
                      size: 17,
                      color: selected
                          ? purple
                          : (isDark ? Colors.white54 : Colors.black45),
                    ),
            ),

            const SizedBox(height: 6),

            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? purple
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHART CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final double maxValue;
  final List<_DayPoint> data;

  const _ChartCard({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.maxValue,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1A38) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF4B3FC7).withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B3FC7).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _StudyChartPainter(
                data: data,
                maxValue: maxValue,
                lineColor: const Color(0xFF6C5CE7),
                fillColor: const Color(0xFF6C5CE7).withOpacity(0.13),
                isDark: isDark,
              ),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyChartPainter extends CustomPainter {
  final List<_DayPoint> data;
  final double maxValue;
  final Color lineColor;
  final Color fillColor;
  final bool isDark;

  _StudyChartPainter({
    required this.data,
    required this.maxValue,
    required this.lineColor,
    required this.fillColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const paddingLeft = 36.0;
    const paddingRight = 14.0;
    const paddingTop = 14.0;
    const paddingBottom = 30.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    // Grid lines & y-axis labels
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.06)
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const ySteps = 3;
    for (int i = 0; i <= ySteps; i++) {
      final y = paddingTop + chartHeight - (chartHeight / ySteps) * i;
      canvas.drawLine(
          Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);
      // y-axis label
      final labelVal = ((maxValue / ySteps) * i).round();
      textPainter.text = TextSpan(
        text: '$labelVal',
        style: TextStyle(
          fontSize: 9,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(0, y - textPainter.height / 2));
    }

    // Build points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = paddingLeft + (chartWidth / (data.length - 1)) * i;
      final normalized = (data[i].value / maxValue).clamp(0.0, 1.0);
      final y = paddingTop + chartHeight - (chartHeight * normalized);
      points.add(Offset(x, y));
    }

    // Fill path
    final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1 = Offset(
          points[i].dx + (points[i + 1].dx - points[i].dx) / 2, points[i].dy);
      final cp2 = Offset(
          points[i].dx + (points[i + 1].dx - points[i].dx) / 2, points[i + 1].dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i + 1].dx, points[i + 1].dy);
    }
    fillPath
      ..lineTo(points.last.dx, size.height - paddingBottom)
      ..lineTo(points.first.dx, size.height - paddingBottom)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = fillColor..style = PaintingStyle.fill);

    // Line path
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1 = Offset(
          points[i].dx + (points[i + 1].dx - points[i].dx) / 2, points[i].dy);
      final cp2 = Offset(
          points[i].dx + (points[i + 1].dx - points[i].dx) / 2, points[i + 1].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i + 1].dx, points[i + 1].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots
    for (final pt in points) {
      canvas.drawCircle(pt, 4,
          Paint()..color = lineColor..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawCircle(pt, 2,
          Paint()..color = Colors.white..style = PaintingStyle.fill);
    }

    // X-axis labels
    for (int i = 0; i < data.length; i++) {
      textPainter.text = TextSpan(
        text: data[i].label,
        style: TextStyle(
          fontSize: 9,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(points[i].dx - textPainter.width / 2, size.height - 20));
    }

    // Tooltip badge on last point
    final last = points.last;
    final badgeVal = '${data.last.value.round()}m';
    textPainter.text = TextSpan(
      text: badgeVal,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1A1530)),
    );
    textPainter.layout();
    final bw = textPainter.width + 16;
    const bh = 22.0;
    final bx = last.dx - bw / 2;
    final by = last.dy - bh - 8;

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, by + 2, bw, bh), const Radius.circular(11)),
      Paint()
        ..color = Colors.black.withOpacity(0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, by, bw, bh), const Radius.circular(11)),
      Paint()..color = Colors.white,
    );
    textPainter.paint(canvas, Offset(bx + 8, by + (bh - textPainter.height) / 2));

    // Dashed vertical line from badge to dot
    final dashPaint = Paint()
      ..color = lineColor.withOpacity(0.4)
      ..strokeWidth = 1;
    double dashY = by + bh + 2;
    while (dashY < last.dy - 4) {
      canvas.drawLine(Offset(last.dx, dashY), Offset(last.dx, dashY + 4), dashPaint);
      dashY += 8;
    }
  }

  @override
  bool shouldRepaint(covariant _StudyChartPainter old) =>
      old.data != data || old.maxValue != maxValue || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// TIME SPENT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _TimeSpentCard extends StatelessWidget {
  final bool isDark;
  final int totalSecondsSpent;

  const _TimeSpentCard({required this.isDark, required this.totalSecondsSpent});

  @override
  Widget build(BuildContext context) {
    final minutes = (totalSecondsSpent / 60).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1A38) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF4B3FC7).withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.schedule_rounded,
                color: Color(0xFF4B3FC7), size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$minutes mins',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                'Total Time Spend So Far',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE LEARN CARD
// ─────────────────────────────────────────────────────────────────────────────

class _InteractiveLearnCard extends StatelessWidget {
  final bool isDark;
  final double progress;
  final VoidCallback onTap;

  const _InteractiveLearnCard({
    required this.isDark,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4B3FC7), Color(0xFF6C5CE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4B3FC7).withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.auto_awesome_motion_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interactive learn',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Tap to continue your lesson',
                    style: TextStyle(fontSize: 11.5, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Circular progress indicator
            SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    painter: _CirclePainter(progress: progress),
                    child: const SizedBox(width: 44, height: 44),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
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

class _CirclePainter extends CustomPainter {
  final double progress;
  const _CirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 19.0;
    const strokeWidth = 3.5;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA CLASSES
// ─────────────────────────────────────────────────────────────────────────────

class _DayPoint {
  final String label;
  final double value;
  const _DayPoint({required this.label, required this.value});
}

class _ProgressTab {
  final String label;
  final IconData? icon;     // optional
  final String? iconText;   // optional

  const _ProgressTab({
    required this.label,
    this.icon,
    this.iconText,
  });
}