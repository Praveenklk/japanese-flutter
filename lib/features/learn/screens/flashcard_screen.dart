import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/progress/progress_service.dart';
import '../data/learning_repository.dart';
import '../models/learning_models.dart';

/// FlashcardScreen - Japanese stationery / sakura aesthetic
/// Inspired by physical hiragana card decks with cherry blossom design.
class FlashcardScreen extends StatefulWidget {
  final String level;
  final String category;

  const FlashcardScreen({
    super.key,
    required this.level,
    required this.category,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _transitionDirection = 1;

  List<Flashcard> _flashcards = [];
  bool _isLoading = true;
  bool _markingRead = false;
  String? _error;

  final Set<String> _locallyReadIds = {};

  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  // Sakura petal positions for decoration
  final List<_SakuraPetal> _petals = List.generate(
    8,
    (i) => _SakuraPetal(
      x: (i * 0.137 + 0.05) % 1.0,
      y: (i * 0.213 + 0.1) % 1.0,
      size: 8.0 + (i % 3) * 4.0,
      rotation: i * 0.7,
      opacity: 0.15 + (i % 4) * 0.07,
    ),
  );

  @override
  void initState() {
    super.initState();
    ProgressService().startSession();

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );

    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutCubic,
    );

    _loadFlashcards();
  }

  @override
  void dispose() {
    unawaited(_saveSession());
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _saveSession() async {
    final category = widget.category.toLowerCase();
    if (category == "hiragana" || category == "katakana") {
      await ProgressService().endSession(type: category);
    } else {
      await ProgressService().endSession(type: "vocab");
    }
  }

  bool _isCardRead(Flashcard card) {
    return card.isRead || _locallyReadIds.contains(card.id);
  }

  Future<void> _loadFlashcards() async {
    try {
      List<Flashcard> data;
      if (widget.category.toLowerCase() == 'hiragana') {
        data = await LearningRepository.getHiragana();
      } else if (widget.category.toLowerCase() == 'katakana') {
        data = await LearningRepository.getKatakana();
      } else {
        data = [];
      }

      if (!mounted) return;
      setState(() {
        _flashcards = data;
        _isLoading = false;
        _error = null;
        _currentIndex = 0;
        _isFlipped = false;
      });
      _flipController.reverse(from: 1);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _flipCard() {
    if (_flashcards.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _isFlipped = !_isFlipped);
    if (_isFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _goToNextCard() {
    if (_currentIndex >= _flashcards.length - 1) return;
    HapticFeedback.lightImpact();
    setState(() {
      _transitionDirection = 1;
      _currentIndex++;
      _isFlipped = false;
    });
    _flipController.reverse(from: 1);
  }

  void _goToPreviousCard() {
    if (_currentIndex <= 0) return;
    HapticFeedback.lightImpact();
    setState(() {
      _transitionDirection = -1;
      _currentIndex--;
      _isFlipped = false;
    });
    _flipController.reverse(from: 1);
  }

  void _handleSwipeEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -250) _goToNextCard();
    else if (velocity > 250) _goToPreviousCard();
  }

  Future<void> _markCurrentCardAsRead() async {
    if (_flashcards.isEmpty || _markingRead) return;
    final currentCard = _flashcards[_currentIndex];
    if (_isCardRead(currentCard)) return;

    setState(() => _markingRead = true);

    try {
      if (widget.category.toLowerCase() == 'hiragana') {
        await LearningRepository.markHiraganaAsRead(currentCard.id);
      } else if (widget.category.toLowerCase() == 'katakana') {
        await LearningRepository.markKatakanaAsRead(currentCard.id);
      }

      final category = widget.category.toLowerCase();
      await ProgressService().recordReview(type: category);

      if (!mounted) return;
      setState(() => _locallyReadIds.add(currentCard.id));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓ Marked as learned'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFFE8748A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _markingRead = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F0F4),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE8748A)),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F0F4),
        body: Center(
          child: Text('Error: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF5A3E4B))),
        ),
      );
    }

    if (_flashcards.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F0F4),
        body: Center(
          child: Text(
            'No flashcards found for ${widget.category}.',
            style: const TextStyle(color: Color(0xFF5A3E4B)),
          ),
        ),
      );
    }

    final currentCard = _flashcards[_currentIndex];
    final progress = _flashcards.length <= 1
        ? 1.0
        : (_currentIndex + 1) / _flashcards.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F4),
      body: Stack(
        children: [
          // Soft sakura background
          Positioned.fill(
            child: CustomPaint(
              painter: _SakuraBackgroundPainter(_petals),
            ),
          ),

          // Top gradient fade
          Positioned(
            top: 0, left: 0, right: 0,
            height: 220,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE8EF), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _SakuraTopBar(
                    category: widget.category,
                    level: widget.level,
                    index: _currentIndex + 1,
                    total: _flashcards.length,
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),
                ),

                const SizedBox(height: 12),

                // ── Dot progress ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _DotProgressRow(
                    total: _flashcards.length,
                    current: _currentIndex,
                  ).animate().fadeIn(delay: 80.ms),
                ),

                const SizedBox(height: 10),

                // ── Hint ──
                AnimatedSwitcher(
                  duration: 250.ms,
                  child: Text(
                    _isFlipped
                        ? 'Tap to return to front'
                        : 'Tap the card to reveal',
                    key: ValueKey(_isFlipped),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB07A8E),
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ).animate().fadeIn(delay: 120.ms),

                const SizedBox(height: 14),

                // ── Card ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onHorizontalDragEnd: _handleSwipeEnd,
                      onTap: _flipCard,
                      child: AnimatedSwitcher(
                        duration: 380.ms,
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: Offset(
                              _transitionDirection > 0 ? 0.15 : -0.15,
                              0,
                            ),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ));
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(position: slide, child: child),
                          );
                        },
                        child: _isFlipped
                            ? _CardBack(
                                key: ValueKey('back-${currentCard.id}-$_currentIndex'),
                                card: currentCard,
                                isRead: _isCardRead(currentCard),
                                markingRead: _markingRead,
                                onMarkAsRead: _markCurrentCardAsRead,
                              )
                            : _CardFront(
                                key: ValueKey('front-${currentCard.id}-$_currentIndex'),
                                card: currentCard,
                                cardNumber: _currentIndex + 1,
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Navigation ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: _NavigationRow(
                    onPrev: _currentIndex > 0 ? _goToPreviousCard : null,
                    onNext: _currentIndex < _flashcards.length - 1
                        ? _goToNextCard
                        : null,
                    isFlipped: _isFlipped,
                    onFlip: _flipCard,
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

// ─────────────────────────────────────────────
//  TOP BAR
// ─────────────────────────────────────────────
class _SakuraTopBar extends StatelessWidget {
  final String category;
  final String level;
  final int index;
  final int total;

  const _SakuraTopBar({
    required this.category,
    required this.level,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back button
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE8748A).withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFF5A3E4B),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$level • Learning',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFB07A8E),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D1F2D),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),

        // Counter pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE8748A).withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌸', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Text(
                '$index / $total',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE8748A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  DOT PROGRESS
// ─────────────────────────────────────────────
class _DotProgressRow extends StatelessWidget {
  final int total;
  final int current;

  const _DotProgressRow({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    // Show max 12 dots, rest as line
    final showDots = total <= 12;

    if (showDots) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final active = i == current;
          final done = i < current;
          return AnimatedContainer(
            duration: 250.ms,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 18 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFFE8748A)
                  : done
                      ? const Color(0xFFF4AABB)
                      : const Color(0xFFDEC6CE),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      );
    }

    // Progress bar for large sets
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 8,
        color: const Color(0xFFDEC6CE),
        child: TweenAnimationBuilder<double>(
          tween: Tween(
            begin: 0,
            end: ((current + 1) / total).clamp(0.0, 1.0),
          ),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
          builder: (_, value, __) => FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE8748A), Color(0xFFF4AABB)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CARD FRONT  (Japanese stationery style)
// ─────────────────────────────────────────────
class _CardFront extends StatelessWidget {
  final Flashcard card;
  final int cardNumber;

  const _CardFront({super.key, required this.card, required this.cardNumber});

  @override
  Widget build(BuildContext context) {
    return _StationeryCard(
      child: Stack(
        children: [
          // 🔥 TOP IMAGE BACKGROUND
         Positioned.fill(
  child: ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: Image.asset(
      'assets/images/image3.png',
      fit: BoxFit.cover,
    ),
  ),
),

          // 🔥 WHITE OVERLAY (important for readability)
Positioned.fill(
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.4),
          Colors.white.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  ),
),

          // ================= EXISTING UI =================

          // Card number badge
          Positioned(
            top: 42,
            right: 16,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFE8748A),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8748A).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$cardNumber',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Category label
          Positioned(
            top: 18,
            left: 20,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8748A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 7),
             const Text(
  '平仮名',
  style: TextStyle(
    fontFamily: 'NotoSansJP', // 🔥 ADD
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: Color(0xFFB07A8E),
    letterSpacing: 1.0,
  ),
),
              ],
            ),
          ),

          // Decorative petals
          const Positioned(
            bottom: 12,
            right: 12,
            child: _CornerPetals(),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // Romaji
                if (card.romaji != null && card.romaji!.trim().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE8748A).withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      card.romaji!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFB07A8E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                // Big character
             Text(
  card.front,
  style: TextStyle(
    fontFamily: 'NotoSansJP', // 🔥 ADD THIS
    fontSize: _charFontSize(card.front),
    fontWeight: FontWeight.w500, // 🔥 change (looks better)
    color: const Color(0xFF2C1820),
    height: 1.0,
  ),
),

                const SizedBox(height: 28),

                // Hint
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 14,
                      color: const Color(0xFFB07A8E).withOpacity(0.7),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Tap to reveal meaning',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFB07A8E).withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CARD BACK
// ─────────────────────────────────────────────
class _CardBack extends StatelessWidget {
  final Flashcard card;
  final bool isRead;
  final bool markingRead;
  final Future<void> Function() onMarkAsRead;

  const _CardBack({
    super.key,
    required this.card,
    required this.isRead,
    required this.markingRead,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return _StationeryCard(
      accentColor: const Color(0xFF5B9BD5),
      child: Stack(
        children: [
          // 🔥 BACK IMAGE
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/images/image4.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔥 OVERLAY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 🔥 TOP CONTENT (ALL DATA — CLEAN)
          Positioned(
            top: 140, // 👈 NOT too high
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Kana
                Text(
                  card.front,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontSize: 38,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C1820),
                  ),
                ),

                const SizedBox(height: 4),

                // Romaji
                if (card.romaji != null && card.romaji!.isNotEmpty)
                  Text(
                    card.romaji!,
                    style: const TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFB07A8E),
                    ),
                  ),

                const SizedBox(height: 12),

                // Explanation
                if (card.back.isNotEmpty)
                  Text(
                    card.back,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5B9BD5),
                    ),
                  ),

                const SizedBox(height: 8),

                // Example (small + subtle)
                if (card.example != null && card.example!.isNotEmpty)
                  Text(
                    card.example!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: 14,
                      color: Color(0xFF4A7A9B),
                    ),
                  ),
              ],
            ),
          ),

          // CATEGORY LABEL
          Positioned(
            top: 18,
            left: 20,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B9BD5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  '答え',
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5B9BD5),
                  ),
                ),
              ],
            ),
          ),

          // PETALS
          const Positioned(
            bottom: 12,
            right: 12,
            child: _CornerPetals(color: Color(0xFFADD8F0)),
          ),

          // 🔥 CENTER → ONLY BUTTON
          Center(
            child: Padding(
             padding: const EdgeInsets.fromLTRB(24, 170, 24, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isRead)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Learned ✓',
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF52C788),
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: markingRead ? null : onMarkAsRead,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8748A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Mark as Learned',
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ─────────────────────────────────────────────
//  STATIONERY CARD BASE
// ─────────────────────────────────────────────
class _StationeryCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;

  const _StationeryCard({
    required this.child,
    this.accentColor = const Color(0xFFE8748A),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: accentColor.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Subtle grid lines (like real flashcard paper)
            Positioned.fill(
              child: CustomPaint(
                painter: _CardLinePainter(
                  lineColor: accentColor.withOpacity(0.04),
                ),
              ),
            ),
            // Pink corner fold
            Positioned(
              top: 0,
              left: 0,
              child: CustomPaint(
                size: const Size(60, 60),
                painter: _CornerFoldPainter(color: accentColor),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NAVIGATION ROW
// ─────────────────────────────────────────────
class _NavigationRow extends StatelessWidget {
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final bool isFlipped;
  final VoidCallback onFlip;

  const _NavigationRow({
    required this.onPrev,
    required this.onNext,
    required this.isFlipped,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavButton(
          icon: Icons.arrow_back_ios_new_rounded,
          label: 'Prev',
          enabled: onPrev != null,
          onTap: onPrev ?? () {},
        ),
        const SizedBox(width: 10),

        // Center flip indicator
        Expanded(
          child: GestureDetector(
            onTap: onFlip,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8748A), Color(0xFFF4AABB)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8748A).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isFlipped
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isFlipped ? 'See front' : 'Flip card',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        _NavButton(
          icon: Icons.arrow_forward_ios_rounded,
          label: 'Next',
          enabled: onNext != null,
          onTap: onNext ?? () {},
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.35,
        duration: 200.ms,
        child: Container(
          width: 72,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE8748A).withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: const Color(0xFFE8748A)),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8748A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DECORATIVE CORNER PETALS
// ─────────────────────────────────────────────
class _CornerPetals extends StatelessWidget {
  final Color color;
  const _CornerPetals({this.color = const Color(0xFFF4AABB)});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Text(
        '🌸',
        style: TextStyle(fontSize: 28, color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CUSTOM PAINTERS
// ─────────────────────────────────────────────
class _CardLinePainter extends CustomPainter {
  final Color lineColor;
  _CardLinePainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8;

    // Horizontal ruled lines
    for (double y = 40; y < size.height; y += 28) {
      canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerFoldPainter extends CustomPainter {
  final Color color;
  _CornerFoldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.08);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(50, 0)
      ..lineTo(0, 50)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SakuraBackgroundPainter extends CustomPainter {
  final List<_SakuraPetal> petals;
  _SakuraBackgroundPainter(this.petals);

  @override
  void paint(Canvas canvas, Size size) {
    for (final petal in petals) {
      final paint = Paint()
        ..color = const Color(0xFFE8748A).withOpacity(petal.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(petal.x * size.width, petal.y * size.height);
      canvas.rotate(petal.rotation);

      // Draw a simple 5-petal sakura
      _drawSakura(canvas, paint, petal.size);
      canvas.restore();
    }
  }

  void _drawSakura(Canvas canvas, Paint paint, double r) {
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi) / 5;
      final cx = cos(angle) * r * 0.5;
      final cy = sin(angle) * r * 0.5;
      canvas.drawCircle(Offset(cx, cy), r * 0.45, paint);
    }
    // Center
    canvas.drawCircle(
      Offset.zero,
      r * 0.22,
      paint..color = paint.color.withOpacity(paint.color.opacity * 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────
class _SakuraPetal {
  final double x, y, size, rotation, opacity;
  _SakuraPetal({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.opacity,
  });
}

double _charFontSize(String text) {
  final length = text.runes.length;
  if (length <= 1) return 120;
  if (length <= 2) return 96;
  if (length <= 4) return 72;
  if (length <= 6) return 58;
  return 46;
}