import 'dart:convert';
import 'dart:ui';

import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/progress/progress_service.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  late Future<void> _assetsFuture;

  List<Map<String, dynamic>> _vocabularyList = [];
  List<Map<String, dynamic>> _kanjiList = [];

  final List<String> _weekDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _assetsFuture = _loadAssets();
  }

  Future<void> _loadAssets() async {
    final vocabJson = await rootBundle.loadString('assets/data/n5_vocabulary.json');
    final kanjiJson = await rootBundle.loadString('assets/data/n5_kanji.json');

    final vocabDecoded = (json.decode(vocabJson) as List).cast<dynamic>();
    final kanjiDecoded = (json.decode(kanjiJson) as List).cast<dynamic>();

    _vocabularyList = vocabDecoded
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    _kanjiList = kanjiDecoded
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<Map<String, dynamic>> _getBookmarkedWords(Box box) {
    final vocabStored = _toMap(box.get('vocab_progress'));
    final kanjiStored = _toMap(box.get('kanji_progress'));

    final Map<String, Map<String, dynamic>> progressMap = {};

    if (vocabStored != null) {
      for (final entry in vocabStored.entries) {
        final value = _toMap(entry.value);
        if (value != null) {
          progressMap['vocab_${entry.key}'] = value;
        }
      }
    }

    if (kanjiStored != null) {
      for (final entry in kanjiStored.entries) {
        final value = _toMap(entry.value);
        if (value != null) {
          progressMap['kanji_${entry.key}'] = value;
        }
      }
    }

    final bookmarkedWords = <Map<String, dynamic>>[];

    for (final entry in progressMap.entries) {
      final key = entry.key;
      final data = entry.value;

      if (data['isBookmarked'] != true) continue;

      final parts = key.split('_');
      if (parts.length < 2) continue;

      final type = parts.first;
      final index = int.tryParse(parts[1]) ?? -1;

      if (type == 'vocab') {
        if (index >= 0 && index < _vocabularyList.length) {
          bookmarkedWords.add({
            ..._vocabularyList[index],
            'type': 'vocab',
          });
        }
      } else if (type == 'kanji') {
        if (index >= 0 && index < _kanjiList.length) {
          bookmarkedWords.add({
            ..._kanjiList[index],
            'type': 'kanji',
          });
        }
      }
    }

    return bookmarkedWords;
  }

  List<int> _weeklyActivityValues() {
    final progress = ProgressService();
    final now = DateTime.now();

    final daysToMonday = now.weekday - 1;
    final monday = now.subtract(Duration(days: daysToMonday));

    return List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      final key = date.toIso8601String().split('T')[0];
      return progress.dailyActivity[key] ?? 0;
    });
  }

  Color _sakuraPink = const Color(0xFFFFC7D9);
  Color _sakuraPinkDark = const Color(0xFFFF9FBE);
  Color _sakuraBgLight = const Color(0xFFFFF7FA);
  Color _sakuraBgDark = const Color(0xFF1B1020);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColors = isDark
        ? [
            _sakuraBgDark,
            const Color(0xFF2A1631),
            AppColors.backgroundDark,
          ]
        : [
            _sakuraBgLight,
            const Color(0xFFFFEEF5),
            AppColors.backgroundLight,
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
        child: FutureBuilder<void>(
          future: _assetsFuture,
          builder: (context, assetSnapshot) {
            if (assetSnapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            return ValueListenableBuilder<Box>(
              valueListenable: Hive.box('progressBox').listenable(
                keys: const ['vocab_progress', 'kanji_progress'],
              ),
              builder: (context, box, _) {
                final bookmarkedWords = _getBookmarkedWords(box);
                final weeklyActivity = _weeklyActivityValues();

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                    await Future<void>.delayed(const Duration(milliseconds: 300));
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    children: [
                      _buildHeader(isDark),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatChip(
                              label: 'Bookmarked',
                              value: '${bookmarkedWords.length} words',
                              icon: Icons.bookmark_rounded,
                              color: _sakuraPinkDark,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatChip(
                              label: 'Saved Today',
                              value: '${weeklyActivity.reduce((a, b) => a + b)}',
                              icon: Icons.local_florist_rounded,
                              color: AppColors.primaryViolet,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildActivityChart(
                        isDark: isDark,
                        weeklyActivity: weeklyActivity,
                      ),

                      const SizedBox(height: 20),

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

                      if (bookmarkedWords.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: _buildEmptyState(isDark),
                        )
                      else
                        ...bookmarkedWords.asMap().entries.map((entry) {
                          return _buildBookmarkCard(
                            item: entry.value,
                            isDark: isDark,
                            index: entry.key,
                          );
                        }),
                    ],
                  ),
                );
              },
            );
          },
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
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.white.withOpacity(0.68),
            border: Border(
              bottom: BorderSide(
                color: _sakuraPinkDark.withOpacity(0.14),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _sakuraPink.withOpacity(0.9),
                      _sakuraPinkDark.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _sakuraPinkDark.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bookmarks_rounded,
                  color: Colors.white,
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
                    'Soft pink study shelf',
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

  Widget _buildStatChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.72),
        border: Border.all(color: color.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
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
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart({
    required bool isDark,
    required List<int> weeklyActivity,
  }) {
    final maxValue = weeklyActivity.isEmpty
        ? 1
        : weeklyActivity.reduce((a, b) => a > b ? a : b);

    const chartHeight = 150.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.72),
        border: Border.all(
          color: _sakuraPinkDark.withOpacity(0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.08 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: _sakuraPinkDark,
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
                final barWidth = (constraints.maxWidth / 7) * 0.65;

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
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOutCubic,
                            height: barHeight,
                            width: barWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  _sakuraPinkDark,
                                  _sakuraPink,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _sakuraPinkDark.withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _weekDays[index],
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
                              fontWeight: FontWeight.w800,
                              color: _sakuraPinkDark,
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

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.72),
        border: Border.all(
          color: _sakuraPinkDark.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _sakuraPink.withOpacity(0.18),
            ),
            child: Icon(
              Icons.local_florist_rounded,
              size: 40,
              color: _sakuraPinkDark,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No bookmarked words yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the bookmark icon on any word and it will bloom here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildBookmarkCard({
    required Map<String, dynamic> item,
    required bool isDark,
    required int index,
  }) {
    final displayText = (item['kanji'] ?? item['word'] ?? 'W').toString();
    final title = (item['kanji'] ?? item['word'] ?? '').toString();
    final meaning = (item['meaning'] ?? '').toString();
    final firstChar = displayText.characters.isNotEmpty
        ? displayText.characters.first.toUpperCase()
        : 'W';

    return Animate(
      effects: [
        FadeEffect(duration: 300.ms),
        SlideEffect(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
          duration: 300.ms,
          delay: Duration(milliseconds: index * 45),
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.white.withOpacity(0.82),
                  border: Border.all(
                    color: _sakuraPinkDark.withOpacity(0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.08 : 0.03),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          _sakuraPink.withOpacity(0.35),
                          _sakuraPinkDark.withOpacity(0.22),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: _sakuraPinkDark.withOpacity(0.14),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        firstChar,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _sakuraPinkDark,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      meaning,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _sakuraPink.withOpacity(0.18),
                    ),
                    child: Icon(
                      Icons.bookmark_rounded,
                      color: _sakuraPinkDark,
                      size: 20,
                    ),
                  ),
                  onTap: () {
                    // Add your navigation or details screen here.
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}