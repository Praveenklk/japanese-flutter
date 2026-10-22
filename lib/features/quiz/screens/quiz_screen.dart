import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/progress/progress_service.dart';
import '../../../providers/quiz_provider.dart';
import 'quiz_result_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sakura colour palette (light + dark)
// ─────────────────────────────────────────────────────────────────────────────
class _S {
  // Light mode
  static const roseLight = Color(0xFFE85D8A);
  static const roseSoftLight = Color(0xFFF08AAD);
  static const pinkBgLight = Color(0xFFFCE8EE);
  static const cardBgLight = Color(0xFFFFFFFF);
  static const textDarkLight = Color(0xFF1A1A2E);
  static const textMutedLight = Color(0xFF888888);
  static const optionBgLight = Color(0xFFF5E8EE);
  static const hintBgLight = Color(0xFFFFF0F5);
  static const dividerLight = Color(0xFFF5E8EE);
  static const correctGreen = Color(0xFF3DC47E);
  static const wrongOrange = Color(0xFFF0A050);
  static const goldXP = Color(0xFFFFB627);
  static const streakRed = Color(0xFFFF5252);

  // Dark mode equivalents
  static const roseDark = Color(0xFFFF9DB8);
  static const roseSoftDark = Color(0xFFD46B8E);
  static const pinkBgDark = Color(0xFF2D1A2A);
  static const cardBgDark = Color(0xFF2A1D28);
  static const textDarkDark = Color(0xFFFFF0F5);
  static const textMutedDark = Color(0xFFBFA0AF);
  static const optionBgDark = Color(0xFF3D2A36);
  static const hintBgDark = Color(0xFF3A1E30);
  static const dividerDark = Color(0xFF3D2A36);
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
    final petalColor = isDark ? _S.roseDark : _S.roseLight;
    for (final p in petals) {
      final paint = Paint()
        ..color = petalColor.withOpacity(p.opacity * (isDark ? 0.38 : 0.25))
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rot);
      final w = p.size, h = p.size * 1.55;
      final path = Path()
        ..moveTo(0, -h / 2)
        ..cubicTo(w / 2, -h / 4, w / 2, h / 4, 0, h / 2)
        ..cubicTo(-w / 2, h / 4, -w / 2, -h / 4, 0, -h / 2);
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
        x: _rng.nextDouble(),
        y: random ? _rng.nextDouble() : -0.05,
        size: 4.5 + _rng.nextDouble() * 6,
        speed: 0.0007 + _rng.nextDouble() * 0.001,
        sway: 0.0003 + _rng.nextDouble() * 0.0004,
        phase: _rng.nextDouble() * math.pi * 2,
        rot: _rng.nextDouble() * math.pi * 2,
        rotV: (_rng.nextDouble() - 0.5) * 0.03,
        opacity: 0.5 + _rng.nextDouble() * 0.5,
      );

  void _tick() {
    for (int i = 0; i < petals.length; i++) {
      final p = petals[i];
      p.y += p.speed;
      p.x += math.sin(p.phase + p.y * 7) * p.sway;
      p.rot += p.rotV;
      p.phase += 0.011;
      if (p.y > 1.06 || p.x < -0.12 || p.x > 1.12) petals[i] = _spawn();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }
}

// ─── Theme helper ───────────────────────────────────────────────────────────
class _QuizTheme {
  final bool isDark;
  _QuizTheme(this.isDark);

  Color get primary => isDark ? _S.roseDark : _S.roseLight;
  Color get primaryLight => isDark ? _S.roseSoftDark : _S.roseSoftLight;
  Color get primarySoft => isDark ? _S.pinkBgDark : _S.pinkBgLight;
  Color get cardBg => isDark ? _S.cardBgDark : _S.cardBgLight;
  Color get textDark => isDark ? _S.textDarkDark : _S.textDarkLight;
  Color get textMuted => isDark ? _S.textMutedDark : _S.textMutedLight;
  Color get optionBg => isDark ? _S.optionBgDark : _S.optionBgLight;
  Color get hintBg => isDark ? _S.hintBgDark : _S.hintBgLight;
  Color get divider => isDark ? _S.dividerDark : _S.dividerLight;
  Color get correctGreen => _S.correctGreen;
  Color get wrongOrange => _S.wrongOrange;
  Color get goldXP => _S.goldXP;
  Color get streakRed => _S.streakRed;
  Color get progressBg => isDark ? const Color(0xFF4A2A3A) : const Color(0xFFF0C8D5);
  Color get optionNumColor => isDark ? const Color(0xFFFFB8D0) : const Color(0xFFC85A8A);
  Color get shadowColor => isDark ? Colors.black.withOpacity(0.3) : _S.roseLight.withOpacity(0.12);
}

/// Helper for generating hints
String _generateHintText(dynamic question) {
  final q = question.question.toString().toLowerCase();
  if (q.contains("how do you say")) return "💡 Think about the Japanese verb for this action";
  if (q.contains("what does")) return "💡 This word is commonly used in daily life";
  if (q.contains("reading")) return "💡 Try recalling the Hiragana reading";
  return "💡 Eliminate wrong answers and think carefully";
}

// ─── Main Quiz Screen ───────────────────────────────────────────────────────
class QuizScreen extends StatefulWidget {
  final String level;
  final String category;
  const QuizScreen({super.key, required this.level, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late final _PetalCtrl _petals;

  @override
  void initState() {
    super.initState();
    _petals = _PetalCtrl(n: 18);
    ProgressService().startSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().startQuiz(widget.level, widget.category);
    });
  }

  @override
  void dispose() {
    String type = widget.category.toLowerCase();
    if (type == "vocabulary") type = "vocab";
    ProgressService().endSession(type: type);
    _petals.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = _QuizTheme(isDark);
    final bottomExtraSpace = MediaQuery.of(context).padding.bottom + 120;

    return Scaffold(
      backgroundColor: theme.primarySoft,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1A0F18), const Color(0xFF2D1A2A)]
                      : [const Color(0xFFFCE8EE), const Color(0xFFFDF1F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
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
              color: theme.primary.withOpacity(isDark ? 0.08 : 0.06),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -80,
            child: _Ring(
              size: 320,
              color: theme.primary.withOpacity(isDark ? 0.06 : 0.04),
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
            child: Consumer<QuizProvider>(
              builder: (context, quizProvider, child) {
                if (quizProvider.isLoading) {
                  return _LoadingView(isDark: isDark);
                }
                if (quizProvider.isQuizComplete) {
                  return const QuizResultScreen();
                }
                final question = quizProvider.currentQuestion;
                if (question == null) {
                  return const Center(child: Text('No questions available'));
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _SakuraTopBar(
                        level: widget.level,
                        category: widget.category,
                        quizProvider: quizProvider,
                        isDark: isDark,
                      ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.06, end: 0),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
                        child: _SakuraProgressBar(
                          quizProvider: quizProvider,
                          isDark: isDark,
                        ).animate().fadeIn(delay: 80.ms, duration: 320.ms).slideY(begin: 0.05, end: 0),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: _KanjiDisplayCard(
                          question: question,
                          quizProvider: quizProvider,
                          isDark: isDark,
                        ).animate().fadeIn(delay: 120.ms, duration: 360.ms).scale(begin: const Offset(0.97, 0.97), end: const Offset(1.0, 1.0)),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
                        child: _QuestionText(question: question, isDark: isDark)
                            .animate()
                            .fadeIn(delay: 150.ms, duration: 320.ms)
                            .slideY(begin: 0.05, end: 0),
                      ),
                    ),
                    if (quizProvider.showHint)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                          child: _HintBox(
                            hint: _generateHintText(question),
                            isDark: isDark,
                          ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.06, end: 0),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                        child: Column(
                          children: question.options.asMap().entries.map((entry) {
                            return _SakuraAnswerOption(
                              option: entry.value,
                              optionIndex: entry.key,
                              quizProvider: quizProvider,
                              isDark: isDark,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    if (quizProvider.selectedAnswer != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: _FeedbackBox(
                            quizProvider: quizProvider,
                            question: question,
                            isDark: isDark,
                          ).animate().fadeIn(duration: 240.ms).slideY(begin: 0.08, end: 0),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: quizProvider.selectedAnswer != null
                            ? _SakuraNextButton(quizProvider: quizProvider, isDark: isDark)
                                .animate()
                                .fadeIn(duration: 220.ms)
                                .slideY(begin: 0.06, end: 0)
                            : _HintButton(quizProvider: quizProvider, isDark: isDark)
                                .animate()
                                .fadeIn(duration: 220.ms)
                                .slideY(begin: 0.06, end: 0),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: _SakuraStatsBar(quizProvider: quizProvider, isDark: isDark)
                            .animate()
                            .fadeIn(delay: 160.ms, duration: 320.ms)
                            .slideY(begin: 0.05, end: 0),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: bottomExtraSpace)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading View ───────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  final bool isDark;
  const _LoadingView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = _QuizTheme(isDark);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌸', style: TextStyle(fontSize: 48)).animate(onPlay: (c) => c.repeat()).rotate(duration: 3000.ms),
          const SizedBox(height: 20),
          CircularProgressIndicator(color: theme.primary, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'Preparing your quiz...',
            style: TextStyle(color: theme.textMuted, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── Top Bar ────────────────────────────────────────────────────────────────
class _SakuraTopBar extends StatelessWidget {
  final String level, category;
  final QuizProvider quizProvider;
  final bool isDark;
  const _SakuraTopBar({required this.level, required this.category, required this.quizProvider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = _QuizTheme(isDark);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).canPop() ? Navigator.of(context).pop() : Navigator.of(context).pushReplacementNamed('/home'),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: theme.cardBg,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [BoxShadow(color: theme.shadowColor, blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: theme.textDark),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text('$category Quiz', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: theme.textDark)),
                const SizedBox(height: 1),
                Text('$level Level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.primary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: theme.cardBg,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [BoxShadow(color: theme.shadowColor, blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌸', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text('${quizProvider.score}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: theme.primary)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => quizProvider.startQuiz(level, category, resetProgress: true),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: theme.shadowColor, blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Icon(Icons.refresh_rounded, size: 18, color: theme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Bar ───────────────────────────────────────────────────────────
class _SakuraProgressBar extends StatelessWidget {
  final QuizProvider quizProvider;
  final bool isDark;
  const _SakuraProgressBar({required this.quizProvider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = _QuizTheme(isDark);
    final progressValue = quizProvider.progress.clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Text('Question ${quizProvider.currentQuestionIndex + 1} of ${quizProvider.totalQuestions}',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: theme.textMuted)),
          const SizedBox(width: 10),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progressValue),
              duration: 450.ms,
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: value, minHeight: 7,
                  backgroundColor: theme.progressBg,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.cardBg,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [BoxShadow(color: theme.shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_rounded, color: theme.primary, size: 14),
                const SizedBox(width: 4),
                Text('3', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: theme.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Kanji/Card Display ─────────────────────────────────────────────────────
class _KanjiDisplayCard extends StatelessWidget {
  final dynamic question;
  final QuizProvider quizProvider;
  final bool isDark;
  const _KanjiDisplayCard({required this.question, required this.quizProvider, required this.isDark});

  bool hasJapanese(String text) => RegExp(r'[\u3040-\u30ff\u4e00-\u9faf]').hasMatch(text);
  String extractKanji(String text) => RegExp(r'[\u3040-\u30ff\u4e00-\u9faf]+').firstMatch(text)?.group(0) ?? text;
  double getFontSize(String text) {
    if (text.length <= 2) return 82;
    if (text.length <= 6) return 46;
    if (text.length <= 12) return 30;
    return 22;
  }

  @override
  Widget build(BuildContext context) {
    final theme = _QuizTheme(isDark);
    final raw = question.question;
    final displayText = hasJapanese(raw) ? extractKanji(raw) : "🌸";
    return Container(
      height: 178,
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: theme.shadowColor, blurRadius: 22, offset: const Offset(0, 7))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark ? [const Color(0xFF2A1A24), const Color(0xFF3A2530)] : [const Color(0xFFFFF0F5), const Color(0xFFFDE0EC)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
            ),
            Center(
              child: Container(
                width: 138, height: 138,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: theme.primary.withOpacity(0.10), width: 2.3)),
              ),
            ),
            const Positioned(top: 8, right: 8, child: Text('🌸', style: TextStyle(fontSize: 48))),
            const Positioned(bottom: 10, left: 12, child: Text('🏯', style: TextStyle(fontSize: 34))),
            Center(
              child: AnimatedSwitcher(
                duration: 240.ms,
                transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: ScaleTransition(scale: anim, child: child)),
                child: Text(
                  displayText,
                  key: ValueKey(displayText),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: displayText == "🌸" ? 42 : getFontSize(displayText),
                    fontWeight: FontWeight.w900,
                    color: theme.textDark,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12, right: 12,
              child: GestureDetector(
                onTap: () {/* TODO: TTS */},
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: theme.cardBg, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 3))]),
                  child: Icon(Icons.volume_up_rounded, size: 19, color: theme.textMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Question Text ──────────────────────────────────────────────────────────
class _QuestionText extends StatelessWidget {
  final dynamic question;
  final bool isDark;
  const _QuestionText({required this.question, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = _QuizTheme(isDark);
    return Column(
      children: [
        AnimatedSwitcher(
          duration: 220.ms,
          child: Text(question.question, key: ValueKey(question.question),
              style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.w800, color: theme.textDark, height: 1.25), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 3),
        Text('Choose the correct answer', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: theme.primary)),
      ],
    );
  }
}

// ─── Answer Option ──────────────────────────────────────────────────────────
class _SakuraAnswerOption extends StatelessWidget {
  final String option;
  final int optionIndex;
  final QuizProvider quizProvider;
  final bool isDark;
  const _SakuraAnswerOption({required this.option, required this.optionIndex, required this.quizProvider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = _QuizTheme(isDark);
    final selected = quizProvider.selectedAnswer;
    final correct = quizProvider.currentQuestion?.correctAnswer;
    final bool isSelected = selected == option;
    final bool isCorrect = correct == option;
    final bool answered = selected != null;

    Color borderColor, backgroundColor, textColor, numBgColor, numTextColor;
    Widget? trailing;

    if (!answered) {
      borderColor = Colors.transparent;
      backgroundColor = theme.cardBg;
      textColor = theme.textDark;
      numBgColor = theme.optionBg;
      numTextColor = theme.optionNumColor;
      trailing = const Text('🌸', style: TextStyle(fontSize: 16));
    } else if (isCorrect) {
      borderColor = theme.correctGreen;
      backgroundColor = isDark ? const Color(0xFF1E2A1E) : const Color(0xFFF0FFF4);
      textColor = theme.correctGreen;
      numBgColor = theme.correctGreen;
      numTextColor = Colors.white;
      trailing = Icon(Icons.check_circle_rounded, color: theme.correctGreen, size: 21);
    } else if (isSelected) {
      borderColor = theme.wrongOrange;
      backgroundColor = isDark ? const Color(0xFF2A1E1A) : const Color(0xFFFFF8F0);
      textColor = theme.wrongOrange;
      numBgColor = theme.wrongOrange;
      numTextColor = Colors.white;
      trailing = Icon(Icons.cancel_rounded, color: theme.wrongOrange, size: 21);
    } else {
      borderColor = Colors.transparent;
      backgroundColor = theme.cardBg.withOpacity(0.7);
      textColor = theme.textMuted;
      numBgColor = theme.optionBg.withOpacity(0.5);
      numTextColor = theme.optionNumColor.withOpacity(0.5);
      trailing = const Text('🌸', style: TextStyle(fontSize: 16, color: Colors.transparent));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: answered ? null : () => quizProvider.selectAnswer(option),
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: 200.ms,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [BoxShadow(color: (answered && isCorrect) ? theme.correctGreen.withOpacity(0.1) : theme.primary.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: 200.ms,
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: numBgColor, shape: BoxShape.circle),
                  child: Center(child: Text('${optionIndex + 1}', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: numTextColor))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(option, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: textColor, height: 1.25))),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (optionIndex * 60).ms).fadeIn(duration: 220.ms).slideY(begin: 0.08, end: 0);
  }
}

// ─── Feedback Box ───────────────────────────────────────────────────────────
class _FeedbackBox extends StatelessWidget {
  final QuizProvider quizProvider;
  final dynamic question;
  final bool isDark;
  const _FeedbackBox({required this.quizProvider, required this.question, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = _QuizTheme(isDark);
    final isCorrect = quizProvider.selectedAnswer == question.correctAnswer;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: theme.shadowColor, blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Text('🐱', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isCorrect ? 'Correct!' : 'Not quite!', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: isCorrect ? theme.primary : theme.wrongOrange)),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: theme.textMuted),
                    children: [
                      TextSpan(text: '"${question.question}" means '),
                      TextSpan(text: question.correctAnswer, style: TextStyle(color: theme.primary, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                if (question.hint != null && quizProvider.showHint) ...[
                  const SizedBox(height: 6),
                  _HintBox(hint: question.hint!, isDark: isDark),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hint Box ───────────────────────────────────────────────────────────────
class _HintBox extends StatelessWidget {
  final String hint;
  final bool isDark;
  const _HintBox({required this.hint, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = _QuizTheme(isDark);
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: theme.hintBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primary.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: theme.primary, size: 15),
          const SizedBox(width: 7),
          Expanded(child: Text(hint, style: TextStyle(fontSize: 12.5, color: theme.primary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

// ─── Hint Button ────────────────────────────────────────────────────────────
class _HintButton extends StatelessWidget {
  final QuizProvider quizProvider;
  final bool isDark;
  const _HintButton({required this.quizProvider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = _QuizTheme(isDark);
    return Center(
      child: TextButton.icon(
        onPressed: () => quizProvider.toggleHint(),
        icon: Icon(quizProvider.showHint ? Icons.visibility_off_rounded : Icons.lightbulb_outline_rounded, size: 20),
        label: Text(quizProvider.showHint ? 'Hide Hint' : 'Show Hint'),
        style: TextButton.styleFrom(
          foregroundColor: theme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ),
    );
  }
}

// ─── Next / Results Button ──────────────────────────────────────────────────
class _SakuraNextButton extends StatelessWidget {
  final QuizProvider quizProvider;
  final bool isDark;
  const _SakuraNextButton({required this.quizProvider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = _QuizTheme(isDark);
    final isLast = quizProvider.currentQuestionIndex >= quizProvider.totalQuestions - 1;
    return GestureDetector(
      onTap: () => quizProvider.nextQuestion(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [theme.primary, theme.primaryLight], begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: theme.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isLast ? 'See Results' : 'Next Question', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.2)),
            const SizedBox(width: 7),
            Icon(isLast ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded, color: Colors.white, size: 19),
          ],
        ),
      ),
    );
  }
}

// ─── Stats Bar ──────────────────────────────────────────────────────────────
class _SakuraStatsBar extends StatelessWidget {
  final QuizProvider quizProvider;
  final bool isDark;
  const _SakuraStatsBar({required this.quizProvider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = _QuizTheme(isDark);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: theme.shadowColor, blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(child: _StatItem(icon: '⭐', label: 'XP', value: '${quizProvider.score * 25}', isLast: false, isDark: isDark)),
          Expanded(child: _StatItem(icon: '🔥', label: 'Streak', value: '${quizProvider.streakCount}', isLast: false, isDark: isDark)),
          Expanded(child: _StatItem(icon: '🏆', label: 'Rank', value: '#${(quizProvider.score / 5).ceil().clamp(1, 99)}', isLast: true, isDark: isDark)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon, label, value;
  final bool isLast, isDark;
  const _StatItem({required this.icon, required this.label, required this.value, required this.isLast, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = _QuizTheme(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
      decoration: BoxDecoration(border: isLast ? null : Border(right: BorderSide(color: theme.divider, width: 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: theme.textDark)),
              Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: theme.textMuted, letterSpacing: 0.4)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Ring Decoration ────────────────────────────────────────────────────────
class _Ring extends StatelessWidget {
  final double size;
  final Color color;
  const _Ring({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 1.5)),
      );
}