import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../routes/route_generator.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sakura colour palette
// ─────────────────────────────────────────────────────────────────────────────
class _SakuraColors {
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Falling Petal logic
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
  _PetalPainter(this.petals);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in petals) {
      final paint = Paint()
        ..color = _SakuraColors.rose.withOpacity(p.opacity * 0.28)
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

class _PetalController extends ChangeNotifier {
  final _rng = math.Random();
  late List<_Petal> petals;
  Timer? _timer;

  _PetalController({int count = 18}) {
    petals = List.generate(count, (_) => _spawn(random: true));
    _timer = Timer.periodic(const Duration(milliseconds: 28), (_) => _tick());
  }

  _Petal _spawn({bool random = false}) => _Petal(
    x: _rng.nextDouble(),
    y: random ? _rng.nextDouble() : -0.05,
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
      if (p.y > 1.06 || p.x < -0.12 || p.x > 1.12) {
        petals[i] = _spawn();
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _DecoRing extends StatelessWidget {
  final double size;
  final Color color;
  const _DecoRing({required this.size, required this.color});

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

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding Screen – Sakura Theme (Fixed Alignment)
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;
  late final _PetalController _petals;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.menu_book_rounded,
      title: 'Learn Japanese',
      description: 'Master Japanese from JLPT N5 to N1 with structured lessons.',
      color: _SakuraColors.rose,
    ),
    OnboardingPageData(
      icon: Icons.flash_on_rounded,
      title: 'Flashcards',
      description: 'Learn with beautiful interactive flashcards.',
      color: _SakuraColors.roseSoft,
    ),
    OnboardingPageData(
      icon: Icons.quiz_rounded,
      title: 'Quiz & XP',
      description: 'Test yourself and earn XP daily.',
      color: _SakuraColors.sage,
    ),
    OnboardingPageData(
      icon: Icons.emoji_events_rounded,
      title: 'Track Progress',
      description: 'See your growth and achievements.',
      color: _SakuraColors.gold,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _petals = _PetalController(count: 20);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _petals.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) => setState(() => _currentPage = page);

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: 400.ms,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyHasSeenOnboarding, true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteGenerator.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_SakuraColors.cream, _SakuraColors.paper, Color(0xFFFFF0F7)],
              ),
            ),
          ),

          // Decorative rings
          Positioned(
            top: -90,
            right: -70,
            child: _DecoRing(size: 280, color: _SakuraColors.rose.withOpacity(0.1)),
          ),
          Positioned(
            bottom: -110,
            left: -80,
            child: _DecoRing(size: 320, color: _SakuraColors.roseSoft.withOpacity(0.08)),
          ),

          // Falling petals
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _petals,
              builder: (_, __) => CustomPaint(painter: _PetalPainter(_petals.petals)),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button row (aligned right)
                Padding(
                  padding: const EdgeInsets.only(top: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentPage < _totalPages - 1)
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: _SakuraColors.inkMuted,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // PageView (fills remaining space)
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _totalPages,
                    itemBuilder: (context, index) => _buildPage(_pages[index]),
                  ),
                ),

                // Bottom indicator + button (fixed alignment)
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: _totalPages,
                        effect: WormEffect(
                          dotHeight: 10,
                          dotWidth: 10,
                          activeDotColor: _SakuraColors.rose,
                          dotColor: _SakuraColors.rose.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _SakuraButton(
                        text: _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                        onPressed: _goToNextPage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPageData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glass icon
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: data.color.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: data.color.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 8)),
                  ],
                ),
                child: Icon(data.icon, size: 70, color: data.color),
              ),
            ),
          ).animate().scale(duration: 500.ms).fadeIn(),

          const SizedBox(height: 50),

          Text(
            data.title,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: _SakuraColors.ink),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

          const SizedBox(height: 20),

          Text(
            data.description,
            style: const TextStyle(fontSize: 16, color: _SakuraColors.inkMuted, height: 1.6),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }
}

/// Sakura‑styled button with proper alignment and ripple
class _SakuraButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _SakuraButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_SakuraColors.rose, _SakuraColors.roseSoft],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: _SakuraColors.rose.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  OnboardingPageData({required this.icon, required this.title, required this.description, required this.color});
}