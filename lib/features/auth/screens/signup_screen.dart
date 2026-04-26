import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/route_generator.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sakura colour palette (same as LoginScreen)
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
// Falling Petal logic (same as before)
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
// Sakura Button (same as LoginScreen)
// ─────────────────────────────────────────────────────────────────────────────
class _SakuraButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double width;

  const _SakuraButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 54,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
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
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SignupScreen – Sakura Themed
// ─────────────────────────────────────────────────────────────────────────────
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  late final _PetalController _petals;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: _SakuraColors.rose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signup(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacementNamed(context, RouteGenerator.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Signup failed'),
            backgroundColor: _SakuraColors.rose,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );
      }
    }
  }

  void _goToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌸 Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_SakuraColors.cream, _SakuraColors.paper, Color(0xFFFFF0F7)],
              ),
            ),
          ),

          // 🌸 Decorative rings
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

          // 🌸 Falling petals
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _petals,
              builder: (_, __) => CustomPaint(painter: _PetalPainter(_petals.petals)),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: _goToLogin,
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: _SakuraColors.ink,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Title
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _SakuraColors.ink,
                      ),
                    ).animate().fadeIn(duration: 500.ms),

                    const SizedBox(height: 8),

                    Text(
                      'Start your Japanese learning journey',
                      style: TextStyle(
                        fontSize: 14,
                        color: _SakuraColors.inkMuted,
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

                    const SizedBox(height: 30),

                    // Signup Form (glass card)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: _SakuraColors.rose.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _SakuraColors.rose.withOpacity(0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name field
                                Text(
                                  'Full Name',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _SakuraColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _nameController,
                                  style: TextStyle(color: _SakuraColors.ink),
                                  decoration: _sakuraInputDecoration(
                                    hintText: 'Enter your full name',
                                    icon: Icons.person_outline,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    if (value.length < 2) {
                                      return 'Name must be at least 2 characters';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Email field
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _SakuraColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(color: _SakuraColors.ink),
                                  decoration: _sakuraInputDecoration(
                                    hintText: 'Enter your email',
                                    icon: Icons.email_outlined,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Password field
                                Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _SakuraColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(color: _SakuraColors.ink),
                                  decoration: _sakuraInputDecoration(
                                    hintText: 'Create a password',
                                    icon: Icons.lock_outline,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: _SakuraColors.inkMuted,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Confirm password field
                                Text(
                                  'Confirm Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _SakuraColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  style: TextStyle(color: _SakuraColors.ink),
                                  decoration: _sakuraInputDecoration(
                                    hintText: 'Confirm your password',
                                    icon: Icons.lock_outline,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: _SakuraColors.inkMuted,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Terms checkbox
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _agreeToTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          _agreeToTerms = value ?? false;
                                        });
                                      },
                                      activeColor: _SakuraColors.rose,
                                      side: BorderSide(color: _SakuraColors.rose),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'I agree to the Terms of Service and Privacy Policy',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _SakuraColors.inkMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Signup button
                                Consumer<AuthProvider>(
                                  builder: (context, auth, child) {
                                    return _SakuraButton(
                                      text: 'Create Account',
                                      onPressed: _signup,
                                      isLoading: auth.isLoading,
                                      width: double.infinity,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 500.ms)
                        .slideY(begin: 0.3, end: 0, delay: 200.ms),

                    const SizedBox(height: 24),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: _SakuraColors.inkMuted,
                          ),
                        ),
                        GestureDetector(
                          onTap: _goToLogin,
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: _SakuraColors.rose,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build consistent input decoration
  InputDecoration _sakuraInputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: _SakuraColors.inkMuted),
      prefixIcon: Icon(icon, color: _SakuraColors.inkMuted),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _SakuraColors.rose.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _SakuraColors.rose, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _SakuraColors.rose, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _SakuraColors.rose, width: 1.5),
      ),
    );
  }
}