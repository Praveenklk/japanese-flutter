import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../quiz/screens/quiz_screen.dart';
import 'flashcard_screen.dart';
import 'package:nihongo_master/features/kanji/kanji_screen.dart';
import 'package:nihongo_master/features/grammar/n5_grammar_screen.dart';
import 'package:nihongo_master/features/vocabulary/n5_vocabulary_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sakura colour palette (identical to KanjiScreen)
// ─────────────────────────────────────────────────────────────────────────────
class _S {
  static const rose       = Color(0xFFE8527A);
  static const roseSoft   = Color(0xFFF0839F);
  static const petal      = Color(0xFFFFD6E3);
  static const sage       = Color(0xFF5F8B6E);
  static const gold       = Color(0xFFB8820C);

  static const cream      = Color(0xFFFFF8FA);
  static const paper      = Color(0xFFFFF0F5);
  static const ink        = Color(0xFF1C0E14);
  static const inkSoft    = Color(0xFF4A2535);
  static const inkMuted   = Color(0xFF7A5060);

  static const night      = Color(0xFF0F0810);
  static const nightSurf  = Color(0xFF1E1020);
  static const nightBord  = Color(0xFF3A1A28);
  static const moonRose   = Color(0xFFFF9DB8);
  static const moonMuted  = Color(0xFF7A4560);
  static const moonText   = Color(0xFFFFE8F0);
}

// ─────────────────────────────────────────────────────────────────────────────
// Falling petals (identical to KanjiScreen)
// ─────────────────────────────────────────────────────────────────────────────
class _Petal {
  double x, y, size, speed, sway, phase, rot, rotV, opacity;
  _Petal({
    required this.x, required this.y, required this.size,
    required this.speed, required this.sway, required this.phase,
    required this.rot, required this.rotV, required this.opacity,
  });
}

class _PetalPainter extends CustomPainter {
  final List<_Petal> petals;
  final bool isDark;
  _PetalPainter(this.petals, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in petals) {
      final paint = Paint()
        ..color = (isDark ? _S.moonRose : _S.rose)
            .withOpacity(p.opacity * (isDark ? 0.38 : 0.25))
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rot);
      final w = p.size, h = p.size * 1.55;
      final path = Path()
        ..moveTo(0, -h / 2)
        ..cubicTo( w / 2, -h / 4,  w / 2,  h / 4, 0,  h / 2)
        ..cubicTo(-w / 2,  h / 4, -w / 2, -h / 4, 0, -h / 2);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PetalPainter old) => true;
}

class _PetalCtrl extends ChangeNotifier {
  final _rng = math.Random();
  late List<_Petal> petals;
  Timer? _t;

  _PetalCtrl({int n = 18}) {
    petals = List.generate(n, (_) => _spawn(random: true));
    _t = Timer.periodic(const Duration(milliseconds: 28), (_) => _tick());
  }

  _Petal _spawn({bool random = false}) => _Petal(
    x: _rng.nextDouble(), y: random ? _rng.nextDouble() : -0.05,
    size:    4.5 + _rng.nextDouble() * 6,
    speed:   0.0007 + _rng.nextDouble() * 0.001,
    sway:    0.0003 + _rng.nextDouble() * 0.0004,
    phase:   _rng.nextDouble() * math.pi * 2,
    rot:     _rng.nextDouble() * math.pi * 2,
    rotV:    (_rng.nextDouble() - 0.5) * 0.03,
    opacity: 0.5 + _rng.nextDouble() * 0.5,
  );

  void _tick() {
    for (int i = 0; i < petals.length; i++) {
      final p = petals[i];
      p.y    += p.speed;
      p.x    += math.sin(p.phase + p.y * 7) * p.sway;
      p.rot  += p.rotV;
      p.phase += 0.011;
      if (p.y > 1.06 || p.x < -0.12 || p.x > 1.12) petals[i] = _spawn();
    }
    notifyListeners();
  }

  @override
  void dispose() { _t?.cancel(); super.dispose(); }
}

// ─────────────────────────────────────────────────────────────────────────────
// Level Detail Screen – Sakura Themed
// ─────────────────────────────────────────────────────────────────────────────
class LevelDetailScreen extends StatefulWidget {
  final String level;

  const LevelDetailScreen({super.key, required this.level});

  @override
  State<LevelDetailScreen> createState() => _LevelDetailScreenState();
}

class _LevelDetailScreenState extends State<LevelDetailScreen> {
  late final _PetalCtrl _petals;
  int _selectedNavIndex = 1;
  bool _isGridView = false;

  final List<_CategoryItem> _categories = [
    _CategoryItem(
      name: 'Hiragana',
      icon: 'あ',
      description: 'Basic Japanese characters from the hiragana alphabet.',
      routeBuilder: (ctx, level) => FlashcardScreen(level: level, category: 'Hiragana'),
    ),
    _CategoryItem(
      name: 'Katakana',
      icon: 'カ',
      description: 'Katakana characters used for foreign words and emphasis.',
      routeBuilder: (ctx, level) => FlashcardScreen(level: level, category: 'Katakana'),
    ),
    _CategoryItem(
      name: 'Kanji',
      icon: '漢',
      description: 'Essential JLPT N5 kanji with meanings and readings.',
      routeBuilder: (ctx, level) => const KanjiScreen(),
    ),
    _CategoryItem(
      name: 'Grammar',
      icon: '文',
      description: 'JLPT N5 grammar patterns and sentence examples.',
      routeBuilder: (ctx, level) => const N5GrammarScreen(),
    ),
    _CategoryItem(
      name: 'Vocabulary',
      icon: '語',
      description: 'Build your vocabulary with audio and example sentences.',
      routeBuilder: (ctx, level) => const N5VocabularyScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _petals = _PetalCtrl(n: 18);
  }

  @override
  void dispose() {
    _petals.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String name) {
    switch (name) {
      case 'Hiragana':
        return _S.rose;
      case 'Katakana':
        return _S.sage;
      case 'Kanji':
        return _S.gold;
      case 'Grammar':
        return _S.roseSoft;
      case 'Vocabulary':
        return _S.inkMuted;
      default:
        return _S.rose;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? _S.night : _S.cream;
    final surfaceColor = isDark ? _S.nightSurf : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const RadialGradient(
                        center: Alignment(-0.4, -0.6),
                        radius: 1.3,
                        colors: [Color(0xFF2A0A1E), _S.night],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_S.cream, _S.paper, Color(0xFFFFF0F7)],
                      ),
              ),
            ),
          ),
          // Decorative rings
          Positioned(
            top: -90,
            right: -70,
            child: _Ring(
              size: 280,
              color: isDark ? _S.moonRose.withOpacity(0.05) : _S.rose.withOpacity(0.06),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -80,
            child: _Ring(
              size: 320,
              color: isDark ? _S.moonRose.withOpacity(0.04) : _S.rose.withOpacity(0.04),
            ),
          ),
          // Falling petals
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _petals,
              builder: (_, __) => CustomPaint(
                painter: _PetalPainter(_petals.petals, isDark),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? _S.moonText : _S.ink,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    'JLPT ${widget.level}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? _S.moonText : _S.ink,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isGridView = !_isGridView);
                      },
                      icon: Icon(
                        _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                        color: isDark ? _S.moonMuted : _S.inkSoft,
                        size: 22,
                      ),
                      tooltip: _isGridView ? 'Switch to list' : 'Switch to grid',
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _S.rose,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.level,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Learning',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: isDark ? _S.moonText : _S.ink,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Choose a category to begin your ${widget.level} journey',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? _S.moonMuted : _S.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(level: widget.level, category: 'Hiragana'),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _S.rose,
                              _S.roseSoft,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: _S.rose.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.quiz_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quick Quiz',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Test your Hiragana knowledge and earn XP',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? _S.moonText : _S.ink,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_categories.length} sections',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? _S.moonMuted : _S.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isGridView)
                  _buildGrid(isDark, surfaceColor)
                else
                  _buildList(isDark, surfaceColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(bool isDark, Color surfaceColor) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = _categories[index];
            final catColor = _getCategoryColor(category.name);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => category.routeBuilder(context, widget.level),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surfaceColor.withOpacity(isDark ? 0.7 : 0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: catColor.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: catColor.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: catColor.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            category.icon,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: catColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? _S.moonText : _S.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category.description,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.3,
                                color: isDark ? _S.moonMuted : _S.inkMuted,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: catColor,
                      ),
                    ],
                  ),
                ),
              ).animate(delay: (index * 60).ms)
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.1, end: 0),
            );
          },
          childCount: _categories.length,
        ),
      ),
    );
  }

  Widget _buildGrid(bool isDark, Color surfaceColor) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = _categories[index];
            final catColor = _getCategoryColor(category.name);

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => category.routeBuilder(context, widget.level),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor.withOpacity(isDark ? 0.7 : 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: catColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: catColor.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: catColor.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category.icon,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: catColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? _S.moonText : _S.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        category.description,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: isDark ? _S.moonMuted : _S.inkMuted,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: catColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate(delay: (index * 50).ms)
                .fadeIn(duration: 300.ms)
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                  curve: Curves.easeOut,
                );
          },
          childCount: _categories.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.05,
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String name;
  final String icon;
  final String description;
  final Widget Function(BuildContext, String) routeBuilder;

  const _CategoryItem({
    required this.name,
    required this.icon,
    required this.description,
    required this.routeBuilder,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Ring widget (same as in KanjiScreen)
// ─────────────────────────────────────────────────────────────────────────────
class _Ring extends StatelessWidget {
  final double size;
  final Color color;

  const _Ring({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
    );
  }
}