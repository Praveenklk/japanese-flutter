import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/progress/progress_service.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Map<String, dynamic>> vocabularyList = [];
  List<Map<String, dynamic>> bookmarkedWords = [];
  bool isLoading = true;

  // Activity data for chart
  List<int> weeklyActivity = List.filled(7, 0);
  List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

Future<void> _loadBookmarks() async {
  try {
    final box = Hive.box('progressBox');

    final vocabStored = box.get('vocab_progress');
    final kanjiStored = box.get('kanji_progress');

   Map<String, Map<String, dynamic>> progressMap = {};
    // ✅ Load vocab progress
// vocab
if (vocabStored != null) {
  final decoded = Map<String, dynamic>.from(vocabStored);
  for (final entry in decoded.entries) {
    progressMap['vocab_${entry.key}'] =
        Map<String, dynamic>.from(entry.value);
  }
}

// kanji
if (kanjiStored != null) {
  final decoded = Map<String, dynamic>.from(kanjiStored);
  for (final entry in decoded.entries) {
    progressMap['kanji_${entry.key}'] =
        Map<String, dynamic>.from(entry.value);
  }
}

    // ✅ Load JSON data
    final vocabJson =
        await rootBundle.loadString('assets/data/n5_vocabulary.json');
    final kanjiJson =
        await rootBundle.loadString('assets/data/n5_kanji.json');

    final List<Map<String, dynamic>> vocabularyList =
        (json.decode(vocabJson) as List).cast<Map<String, dynamic>>();

    final List<Map<String, dynamic>> kanjiList =
        (json.decode(kanjiJson) as List).cast<Map<String, dynamic>>();

    bookmarkedWords = [];

    // ✅ Merge bookmarks
for (final entry in progressMap.entries) {
  final key = entry.key;
  final data = entry.value;

  if (data['isBookmarked'] == true) {
    final parts = key.split('_');
    final type = parts[0]; // vocab or kanji
    final index = int.parse(parts[1]);

    if (type == 'vocab') {
      if (index < vocabularyList.length) {
        bookmarkedWords.add({
          ...vocabularyList[index],
          'type': 'vocab',
        });
      }
    } else if (type == 'kanji') {
      if (index < kanjiList.length) {
        bookmarkedWords.add({
          ...kanjiList[index],
          'type': 'kanji',
        });
      }
    }
  }
}

    _loadWeeklyActivity();

    setState(() {
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
    });
  }
}
  void _loadWeeklyActivity() {
    final progress = ProgressService();
    final now = DateTime.now();
    // Find Monday of current week
    int daysToMonday = now.weekday - 1;
    final monday = now.subtract(Duration(days: daysToMonday));

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final key = date.toIso8601String().split('T')[0];
      weeklyActivity[i] = progress.dailyActivity[key] ?? 0;
    }
  }

  int _totalBookmarks() => bookmarkedWords.length;

@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final bgColors = isDark
      ? [
          AppColors.backgroundDark,
          AppColors.surfaceDark.withOpacity(0.95),
        ]
      : [
          AppColors.backgroundLight,
          AppColors.surfaceLight.withOpacity(0.97),
        ];

  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: bgColors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              children: [
                /// HEADER
                _buildHeader(isDark),
                const SizedBox(height: 16),

                /// STATS
                Row(
                  children: [
                    Expanded(
                      child: _buildStatChip(
                        '📖 Bookmarked',
                        '${_totalBookmarks()} words',
                        Icons.bookmark_rounded,
                        AppColors.xpGold,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatChip(
                        '⭐ Favorites',
                        '${bookmarkedWords.length}',
                        Icons.star_rounded,
                        AppColors.primaryViolet,
                        isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// CHART
                _buildActivityChart(isDark),

                const SizedBox(height: 20),

                /// TITLE
                Row(
                  children: [
                    Icon(
                      Icons.bookmarks_rounded,
                      color: AppColors.primaryDeepPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your saved words',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${bookmarkedWords.length} items',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// EMPTY STATE
                if (bookmarkedWords.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bookmark_border_rounded,
                          size: 64,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No bookmarked words yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap bookmark on any word to save it here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
                  )

                /// LIST
                else
                  ...bookmarkedWords.asMap().entries.map((entry) {
                    return _buildBookmarkCard(
                      entry.value,
                      isDark,
                      entry.key,
                    );
                  }).toList(),
              ],
            ),
    ),
  );
}

  Widget _buildHeader(bool isDark) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.65),
            border: Border(
              bottom: BorderSide(
                color: AppColors.primaryDeepPurple.withOpacity(0.12),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryViolet.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.bookmarks_rounded,
                  color: AppColors.primaryViolet,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Bookmarks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    'Vocabulary you loved',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
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

  Widget _buildStatChip(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildActivityChart(bool isDark) {
  final maxValue = weeklyActivity.isEmpty
      ? 1
      : weeklyActivity.reduce((a, b) => a > b ? a : b);
  final chartHeight = 140.0; // increased to give more room

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
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
              Icons.bar_chart_rounded,
              color: AppColors.primaryViolet,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Weekly Activity',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const Spacer(),
            Text(
              'reviews per day',
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: chartHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = (constraints.maxWidth / 7) * 0.7;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final value = weeklyActivity[index];
                  final barHeight = maxValue == 0
                      ? 0.0
                      : ((value / maxValue) * (chartHeight - 40)).toDouble();
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: barHeight,
                          width: barWidth,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryDeepPurple,
                                AppColors.primaryViolet,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          weekDays[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryViolet,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildBookmarkCard(
    Map<String, dynamic> item, bool isDark, int index) {
  return Animate(
    effects: [
      FadeEffect(duration: const Duration(milliseconds: 300)),
      SlideEffect(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
        duration: const Duration(milliseconds: 300),
        delay: Duration(milliseconds: index * 50),
      ),
    ],
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),

          /// 🔥 FIX: Add Material here
          child: Material(
            color: Colors.transparent, // keeps glass effect
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.white.withOpacity(0.8),
                border: Border.all(
                  color: AppColors.primaryDeepPurple.withOpacity(0.12),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),

                /// 🔹 Leading Icon Box
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryDeepPurple.withOpacity(0.2),
                        AppColors.primaryViolet.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      (item['kanji'] ?? item['word'] ?? 'W')
                          .toString()
                          .characters
                          .first
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryViolet,
                      ),
                    ),
                  ),
                ),

                /// 🔹 Title
                title: Text(
                  item['kanji'] ?? item['word'] ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),

                /// 🔹 Subtitle
                subtitle: Text(
                  item['meaning'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),

                /// 🔹 Bookmark Icon
                trailing: Icon(
                  Icons.bookmark_rounded,
                  color: AppColors.xpGold,
                  size: 22,
                ),

                /// 🔹 Tap Effect (now works because of Material)
                onTap: () {
                  // Optional: navigate or show details
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
}}