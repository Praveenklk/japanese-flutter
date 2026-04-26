import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/progress/progress_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sakura colour palette
// ─────────────────────────────────────────────────────────────────────────────
class _S {
  // Shared
  static const rose       = Color(0xFFE8527A);
  static const roseSoft   = Color(0xFFF0839F);
  static const petal      = Color(0xFFFFD6E3);
  static const sage       = Color(0xFF5F8B6E);
  static const gold       = Color(0xFFB8820C);

  // Light
  static const cream      = Color(0xFFFFF8FA);
  static const paper      = Color(0xFFFFF0F5);
  static const ink        = Color(0xFF1C0E14);
  static const inkSoft    = Color(0xFF4A2535);
  static const inkMuted   = Color(0xFF7A5060);

  // Dark
  static const night      = Color(0xFF0F0810);
  static const nightSurf  = Color(0xFF1E1020);
  static const nightBord  = Color(0xFF3A1A28);
  static const moonRose   = Color(0xFFFF9DB8);
  static const moonMuted  = Color(0xFF7A4560);
  static const moonText   = Color(0xFFFFE8F0);
}

// ─────────────────────────────────────────────────────────────────────────────
// Falling petals
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
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class KanjiScreen extends StatefulWidget {
  const KanjiScreen({super.key});
  @override
  State<KanjiScreen> createState() => _KanjiScreenState();
}

class _KanjiScreenState extends State<KanjiScreen> {
  final AudioPlayer _player = AudioPlayer();
  late final _PetalCtrl _petals;

  List<Map<String, dynamic>> kanjiList  = [];
  Map<int, Map<String, dynamic>> progressMap = {};
  List<int> dueIndices = [];

  int  currentIndex = 0;
  bool showBack  = false;
  bool isLoading = true;
  String? errorMessage;

  Box get _box => Hive.box('progressBox');

  // ── life‑cycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _petals = _PetalCtrl(n: 18);
    ProgressService().startSession();
    _loadKanji();
  }

  @override
  void dispose() {
    unawaited(_saveLastPosition());
    ProgressService().endSession(type: 'kanji');
    _player.dispose();
    _petals.dispose();
    super.dispose();
  }

  // ── data ────────────────────────────────────────────────────────────────────
  Future<void> _loadKanji() async {
    try {
      final stored = _box.get('kanji_progress');
      final Map<int, Map<String, dynamic>> loaded = {};
      if (stored != null) {
        final decoded = Map<String, dynamic>.from(stored as Map);
        for (final e in decoded.entries) {
          loaded[int.parse(e.key)] =
              Map<String, dynamic>.from(e.value as Map);
        }
      }
      final raw  = await rootBundle.loadString('assets/data/n5_kanji.json');
      final data = (json.decode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        progressMap = loaded;
        kanjiList   = data;
        _refreshDue();
        _restorePos();
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { errorMessage = 'Failed to load kanji data'; isLoading = false; });
    }
  }

  Map<String, dynamic> _serialize() =>
      progressMap.map((k, v) => MapEntry(k.toString(), v));

  Future<void> _saveProgress()    async => _box.put('kanji_progress', _serialize());
  Future<void> _saveLastPosition() async {
    final i = _realIdx; if (i == null) return;
    await _box.put('last_kanji_real_index', i);
  }

  void _restorePos() {
    if (dueIndices.isEmpty) { currentIndex = 0; return; }
    final saved = _box.get('last_kanji_real_index');
    if (saved is int) {
      final r = dueIndices.indexOf(saved);
      currentIndex = r >= 0 ? r : 0;
    } else if (currentIndex >= dueIndices.length) {
      currentIndex = 0;
    }
    currentIndex = currentIndex.clamp(0, dueIndices.length - 1);
  }

  void _refreshDue() {
    final now = DateTime.now();
    dueIndices = [];
    for (int i = 0; i < kanjiList.length; i++) {
      final p  = progressMap[i];
      if (p == null) { dueIndices.add(i); continue; }
      final nr = DateTime.tryParse(p['nextReview']?.toString() ?? '');
      if (nr == null || !nr.isAfter(now)) dueIndices.add(i);
    }
    if (dueIndices.isEmpty) { currentIndex = 0; showBack = false; return; }
    currentIndex = currentIndex.clamp(0, dueIndices.length - 1);
  }

  int? get _realIdx =>
      dueIndices.isEmpty ? null :
      (currentIndex >= 0 && currentIndex < dueIndices.length
          ? dueIndices[currentIndex] : null);

  Map<String, dynamic>? get _item =>
      _realIdx == null ? null : kanjiList[_realIdx!];

  bool _bkd(int i) => progressMap[i]?['isBookmarked'] == true;

  // ── actions ─────────────────────────────────────────────────────────────────
  Future<void> _toggleBkd(int i) async {
    if (i < 0 || i >= kanjiList.length) return;
    final ex = Map<String, dynamic>.from(progressMap[i] ?? {});
    ex['isBookmarked'] = !(ex['isBookmarked'] == true);
    ex['type'] = 'kanji';
    progressMap[i] = ex;
    await _saveProgress();
    if (mounted) setState(() {});
  }

  Future<void> _scheduleReview(int i, Duration delay) async {
    if (i < 0 || i >= kanjiList.length) return;
    final now = DateTime.now();
    final ex  = progressMap[i];
    progressMap[i] = {
      'nextReview':     now.add(delay).toIso8601String(),
      'lastReviewedAt': now.toIso8601String(),
      'reviewCount':    ((ex?['reviewCount'] as num?)?.toInt() ?? 0) + 1,
      'intervalMinutes':delay.inMinutes,
      'isBookmarked':   ex?['isBookmarked'] == true,
    };
    await _saveProgress();
    await ProgressService().recordReview(type: 'kanji');
    await _saveLastPosition();
    if (!mounted) return;
    setState(() { showBack = false; _refreshDue(); _restorePos(); });
  }

  Future<void> _again()    async { final i = _realIdx; if (i != null) await _scheduleReview(i, const Duration(minutes: 10)); }
  Future<void> _tomorrow() async { final i = _realIdx; if (i != null) await _scheduleReview(i, const Duration(days: 1)); }
  Future<void> _in3Days()  async { final i = _realIdx; if (i != null) await _scheduleReview(i, const Duration(days: 3)); }

  void _next() {
    if (dueIndices.isEmpty) return;
    setState(() { currentIndex = (currentIndex + 1) % dueIndices.length; showBack = false; });
    unawaited(_saveLastPosition());
  }
  void _prev() {
    if (dueIndices.isEmpty) return;
    setState(() { currentIndex = (currentIndex - 1 + dueIndices.length) % dueIndices.length; showBack = false; });
    unawaited(_saveLastPosition());
  }
  void _flip() => setState(() => showBack = !showBack);

  void _onH(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (v < -220) _next(); else if (v > 220) _prev();
  }
  void _onV(DragEndDetails d) { if ((d.primaryVelocity ?? 0).abs() > 180) _flip(); }

  Future<void> _audio(Map<String, dynamic> k) async {
    final on  = _lst(k['onyomi']);
    final kun = _lst(k['kunyomi']);
    final t   = on.isNotEmpty ? on.first : kun.isNotEmpty ? kun.first : k['kanji']?.toString() ?? '';
    if (t.isEmpty) return;
    final uri = Uri.https('translate.google.com', '/translate_tts',
        {'ie': 'UTF-8', 'client': 'tw-ob', 'q': t, 'tl': 'ja'});
    await _player.stop();
    await _player.play(UrlSource(uri.toString()));
  }

  List<String> _lst(dynamic v) =>
      v is List ? v.map((e) => e.toString()).toList() : const [];

  // ── build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item   = _item;

    return Scaffold(
      backgroundColor: isDark ? _S.night : _S.cream,
      body: Stack(children: [

        // Background
        Positioned.fill(child: Container(
          decoration: BoxDecoration(gradient: isDark
            ? const RadialGradient(
                center: Alignment(-0.4, -0.6), radius: 1.3,
                colors: [Color(0xFF2A0A1E), _S.night])
            : const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [_S.cream, _S.paper, Color(0xFFFFF0F7)])),
        )),

        // Decorative rings
        Positioned(top: -90, right: -70,
          child: _Ring(size: 280, color: isDark
              ? _S.moonRose.withOpacity(0.05) : _S.rose.withOpacity(0.06))),
        Positioned(bottom: -110, left: -80,
          child: _Ring(size: 320, color: isDark
              ? _S.moonRose.withOpacity(0.04) : _S.rose.withOpacity(0.04))),

        // Petals
        Positioned.fill(child: AnimatedBuilder(
          animation: _petals,
          builder: (_, __) => CustomPaint(
            painter: _PetalPainter(_petals.petals, isDark)),
        )),

        // Content
        SafeArea(child: Column(children: [

          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: _TopBar(
              isDark:  isDark,
              total:   dueIndices.length,
              current: currentIndex,
              onPrev:  _prev,
              onNext:  _next,
              onAudio: item == null ? null : () => _audio(item),
            ),
          ),

          // Side pill
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: _SidePill(isDark: isDark, showBack: showBack),
          ),

          const SizedBox(height: 10),

          // Card
          Expanded(
            child: isLoading
              ? Center(child: CircularProgressIndicator(color: _S.rose, strokeWidth: 2))
              : errorMessage != null
                  ? _msg(errorMessage!, isDark)
                  : kanjiList.isEmpty
                      ? _msg('No kanji found', isDark)
                      : dueIndices.isEmpty
                          ? _allDone(isDark)
                          : GestureDetector(
                              onHorizontalDragEnd: _onH,
                              onVerticalDragEnd:   _onV,
                              onTap:               _flip,
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 330),
                                  transitionBuilder: (child, anim) {
                                    final c = CurvedAnimation(
                                        parent: anim, curve: Curves.easeOut);
                                    return FadeTransition(opacity: c,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.05, 0),
                                          end: Offset.zero,
                                        ).animate(c),
                                        child: child));
                                  },
                                  child: _KanjiCard(
                                    key:         ValueKey('${currentIndex}_$showBack'),
                                    kanji:       item!,
                                    kanjiIdx:    _realIdx!,
                                    isDark:      isDark,
                                    showBack:    showBack,
                                    isBookmarked:_bkd(_realIdx!),
                                    onBookmark:  () => _toggleBkd(_realIdx!),
                                    lst:         _lst,
                                  ),
                                ),
                              ),
                            ),
          ),

          // ── Review bar — ALWAYS VISIBLE, NEVER inside the scrollable card ──
          if (!isLoading && dueIndices.isNotEmpty)
            _ReviewBar(
              isDark:     isDark,
              onAgain:    _again,
              onTomorrow: _tomorrow,
              on3Days:    _in3Days,
            ),

          const SizedBox(height: 10),
        ])),
      ]),
    );
  }

  Widget _msg(String t, bool isDark) => Center(
    child: Text(t, style: TextStyle(
        color: isDark ? _S.moonText : _S.inkSoft)));

  Widget _allDone(bool isDark) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🌸', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 18),
        Text('All caught up!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: isDark ? _S.moonText : _S.ink)),
        const SizedBox(height: 8),
        Text('No kanji to review right now.\nCheck back later!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.6,
            color: isDark ? _S.moonMuted : _S.inkMuted)),
      ]).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isDark;
  final int total, current;
  final VoidCallback onPrev, onNext;
  final VoidCallback? onAudio;

  const _TopBar({
    required this.isDark, required this.total, required this.current,
    required this.onPrev, required this.onNext, this.onAudio,
  });

  @override
  Widget build(BuildContext context) {
    final display = total == 0 ? 0 : current + 1;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? _S.nightSurf.withOpacity(0.82)
                : Colors.white.withOpacity(0.68),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? _S.nightBord
                  : _S.petal.withOpacity(0.60)),
          ),
          child: Row(children: [
            _IBtn(icon: Icons.arrow_back_rounded, onTap: onPrev, isDark: isDark),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Kanji Learning',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                  color: isDark ? _S.moonText : _S.ink)),
              const SizedBox(height: 1),
              Text('$display of $total cards due',
                style: TextStyle(fontSize: 11.5,
                  color: isDark ? _S.moonMuted : _S.inkMuted)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _S.rose.withOpacity(isDark ? 0.18 : 0.10),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: _S.rose.withOpacity(0.22))),
              child: Text('$display / $total',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                  color: isDark ? _S.moonRose : _S.rose)),
            ),
            if (onAudio != null) ...[
              const SizedBox(width: 8),
              _IBtn(icon: Icons.volume_up_rounded, onTap: onAudio!,
                  isDark: isDark, primary: true),
            ],
            const SizedBox(width: 6),
            _IBtn(icon: Icons.arrow_forward_rounded, onTap: onNext, isDark: isDark),
          ]),
        ),
      ),
    );
  }
}

class _IBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark, primary;
  const _IBtn({required this.icon, required this.onTap, required this.isDark,
      this.primary = false});

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        gradient: primary ? const LinearGradient(
          colors: [_S.rose, Color(0xFFC03060)],
          begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        color: primary ? null
            : (isDark ? _S.moonRose.withOpacity(0.10) : _S.rose.withOpacity(0.09)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _S.rose.withOpacity(primary ? 0 : 0.18)),
        boxShadow: primary
            ? [BoxShadow(color: _S.rose.withOpacity(0.30),
                blurRadius: 10, offset: const Offset(0, 4))]
            : null,
      ),
      child: Icon(icon, size: 17,
        color: primary ? Colors.white : (isDark ? _S.moonRose : _S.rose)),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Side pill
// ─────────────────────────────────────────────────────────────────────────────
class _SidePill extends StatelessWidget {
  final bool isDark, showBack;
  const _SidePill({required this.isDark, required this.showBack});

  @override
  Widget build(BuildContext context) {
    final color = showBack ? _S.sage : _S.rose;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18))),
      child: Row(children: [
        Icon(showBack ? Icons.layers_rounded : Icons.style_rounded,
          size: 15, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(
          showBack
              ? 'Back — details, mnemonics & examples'
              : 'Front — kanji, readings & meaning',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
            color: isDark ? _S.moonText : _S.ink))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(99)),
          child: Text(showBack ? 'BACK' : 'FRONT',
            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900,
              letterSpacing: 0.6, color: color)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review bar — fixed at bottom, OUTSIDE the card
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAgain, onTomorrow, on3Days;
  const _ReviewBar({required this.isDark, required this.onAgain,
      required this.onTomorrow, required this.on3Days});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: BoxDecoration(
              color: isDark
                  ? _S.nightSurf.withOpacity(0.90)
                  : Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? _S.nightBord : _S.petal.withOpacity(0.55)),
              boxShadow: [BoxShadow(
                color: _S.rose.withOpacity(isDark ? 0.12 : 0.08),
                blurRadius: 22, offset: const Offset(0, -4))],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Label row
              Row(children: [
                Expanded(child: Container(height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      _S.rose.withOpacity(0.28)])))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Review again in…',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      color: isDark ? _S.moonMuted : _S.inkMuted))),
                Expanded(child: Container(height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      _S.rose.withOpacity(0.28),
                      Colors.transparent])))),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _RBtn(
                  label: 'Again',   sub: '10 min',  emoji: '🔁',
                  color: const Color(0xFFD95B28), isDark: isDark, onTap: onAgain)),
                const SizedBox(width: 8),
                Expanded(child: _RBtn(
                  label: 'Tomorrow', sub: '1 day',  emoji: '🌤',
                  color: _S.rose,  isDark: isDark, onTap: onTomorrow)),
                const SizedBox(width: 8),
                Expanded(child: _RBtn(
                  label: '3 Days',  sub: '3 days',  emoji: '⭐',
                  color: _S.sage,  isDark: isDark, onTap: on3Days)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

class _RBtn extends StatelessWidget {
  final String label, sub, emoji;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _RBtn({required this.label, required this.sub, required this.emoji,
      required this.color, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.14 : 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.22))),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800,
            color: color)),
        const SizedBox(height: 1),
        Text(sub, style: TextStyle(fontSize: 10.5,
            color: color.withOpacity(0.65))),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Kanji card (scrollable, but review bar is NOT inside it)
// ─────────────────────────────────────────────────────────────────────────────
class _KanjiCard extends StatelessWidget {
  final Map<String, dynamic> kanji;
  final int kanjiIdx;
  final bool isDark, showBack, isBookmarked;
  final VoidCallback onBookmark;
  final List<String> Function(dynamic) lst;

  const _KanjiCard({
    super.key,
    required this.kanji, required this.kanjiIdx, required this.isDark,
    required this.showBack, required this.isBookmarked,
    required this.onBookmark, required this.lst,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      constraints: const BoxConstraints(maxWidth: 520),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: isDark
                  ? LinearGradient(
                      colors: [_S.nightSurf.withOpacity(0.92), _S.night.withOpacity(0.82)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight)
                  : LinearGradient(
                      colors: [Colors.white.withOpacity(0.90), _S.paper.withOpacity(0.78)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(
                color: isDark ? _S.nightBord : _S.petal.withOpacity(0.55),
                width: 1.2),
              boxShadow: [BoxShadow(
                color: _S.rose.withOpacity(isDark ? 0.16 : 0.09),
                blurRadius: 36, offset: const Offset(0, 14))],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: showBack ? _back() : _front(),
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 260.ms)
        .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1),
            duration: 260.ms, curve: Curves.easeOut);
  }

  // ── FRONT ──────────────────────────────────────────────────────────────────
  Widget _front() {
    final onyomi   = lst(kanji['onyomi']);
    final kunyomi  = lst(kanji['kunyomi']);
    final examples = (kanji['examples'] as List?) ?? const [];

    return Column(mainAxisSize: MainAxisSize.min, children: [

      // Header
      Row(children: [
        _Chip(text: kanji['jlpt']?.toString() ?? 'N5',    color: _S.rose),
        const SizedBox(width: 6),
        _Chip(text: '${kanji['strokes'] ?? 0} strokes',   color: _S.sage),
        const SizedBox(width: 6),
        _Chip(text: 'Rank ${kanji['frequency'] ?? '—'}',  color: _S.gold),
        const Spacer(),
        _BookmarkBtn(isBookmarked: isBookmarked, onTap: onBookmark, isDark: isDark),
      ]),

      const SizedBox(height: 16),

      // Hero
      _KanjiHero(kanji: kanji, isDark: isDark, isBookmarked: isBookmarked),

      const SizedBox(height: 14),

      // Readings
      Row(children: [
        Expanded(child: _Reading(label: "On'yomi",
            value: onyomi.isEmpty  ? '—' : onyomi.join(' · '),
            isDark: isDark, accent: _S.rose)),
        const SizedBox(width: 10),
        Expanded(child: _Reading(label: "Kun'yomi",
            value: kunyomi.isEmpty ? '—' : kunyomi.join(' · '),
            isDark: isDark, accent: _S.sage)),
      ]),

      const SizedBox(height: 12),
      _Div(isDark: isDark),
      const SizedBox(height: 10),

      _Label(text: 'Meaning', isDark: isDark),
      const SizedBox(height: 6),
      _TextBox(text: kanji['description']?.toString() ?? '', isDark: isDark),

      if (examples.isNotEmpty) ...[
        const SizedBox(height: 12),
        _Label(text: 'Example', isDark: isDark),
        const SizedBox(height: 6),
        _ExCard(ex: _toEx(examples.first), isDark: isDark),
      ],

      const SizedBox(height: 10),
      _Hint(text: 'Tap or swipe up/down to flip  •  swipe left/right to navigate',
          isDark: isDark),
    ]);
  }

  // ── BACK ───────────────────────────────────────────────────────────────────
  Widget _back() {
    final examples = (kanji['examples'] as List?) ?? const [];
    final similar  = lst(kanji['similarKanji']);
    final tags     = lst(kanji['tags']);

    return Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, children: [

      Row(children: [
        _Chip(text: 'Radical: ${kanji['radical'] ?? '—'}', color: _S.rose),
        const SizedBox(width: 6),
        _Chip(text: '${kanji['strokes'] ?? 0} strokes', color: _S.sage),
        const Spacer(),
        _BookmarkBtn(isBookmarked: isBookmarked, onTap: onBookmark, isDark: isDark),
      ]),

      if (isBookmarked) ...[
        const SizedBox(height: 12),
        _BkdBanner(isDark: isDark),
      ],

      const SizedBox(height: 14),
      _Label(text: 'Memory Hint', isDark: isDark),
      const SizedBox(height: 6),
      _TextBox(text: kanji['memoryHint']?.toString() ?? '', isDark: isDark),

      const SizedBox(height: 10),
      _Label(text: 'Mnemonic', isDark: isDark),
      const SizedBox(height: 6),
      _TextBox(text: kanji['mnemonic']?.toString() ?? '', isDark: isDark),

      const SizedBox(height: 12),
      _Div(isDark: isDark),
      const SizedBox(height: 10),
      _Label(text: 'Details', isDark: isDark),
      const SizedBox(height: 8),
      _DetailGrid(kanji: kanji, isDark: isDark),

      if (examples.isNotEmpty) ...[
        const SizedBox(height: 12),
        _Label(text: 'Examples', isDark: isDark),
        const SizedBox(height: 6),
        ...examples.take(2).map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ExCard(ex: _toEx(e), isDark: isDark))),
      ],

      if (similar.isNotEmpty) ...[
        const SizedBox(height: 10),
        _Label(text: 'Similar Kanji', isDark: isDark),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8,
          children: similar.map((s) => _Chip(text: s, color: _S.rose)).toList()),
      ],

      if (tags.isNotEmpty) ...[
        const SizedBox(height: 10),
        _Label(text: 'Tags', isDark: isDark),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8,
          children: tags.map((t) => _Chip(text: t, color: _S.sage)).toList()),
      ],

      const SizedBox(height: 10),
      _Hint(text: 'Tap to return to front', isDark: isDark),
    ]);
  }

  Map<String, dynamic> _toEx(dynamic e) =>
      e is Map<String, dynamic> ? e
          : {'word': e.toString(), 'reading': '', 'meaning': ''};
}

// ─────────────────────────────────────────────────────────────────────────────
// Kanji hero
// ─────────────────────────────────────────────────────────────────────────────
class _KanjiHero extends StatelessWidget {
  final Map<String, dynamic> kanji;
  final bool isDark, isBookmarked;
  const _KanjiHero({required this.kanji, required this.isDark,
      required this.isBookmarked});

  @override
  Widget build(BuildContext context) {
    final accent = isBookmarked ? _S.gold : _S.rose;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isBookmarked
              ? [_S.gold.withOpacity(isDark ? 0.16 : 0.10),
                 _S.rose.withOpacity(isDark ? 0.10 : 0.07)]
              : [_S.rose.withOpacity(isDark ? 0.16 : 0.08),
                 _S.roseSoft.withOpacity(isDark ? 0.08 : 0.05)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(
            color: accent.withOpacity(isDark ? 0.22 : 0.28)),
      ),
      child: Column(children: [
        // Decorative petal dots
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(width: 4, height: 4,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: _S.rose.withOpacity(isDark ? 0.35 : 0.45)))))),
        const SizedBox(height: 12),
        Text(kanji['kanji']?.toString() ?? '',
          style: TextStyle(fontSize: 86, fontWeight: FontWeight.w900, height: 1,
            color: isDark ? _S.moonText : _S.ink,
            shadows: [Shadow(color: _S.rose.withOpacity(0.22),
                blurRadius: 18, offset: const Offset(0, 8))])),
        const SizedBox(height: 10),
        Text(kanji['meaning']?.toString() ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: isDark ? _S.moonRose : _S.rose)),
        const SizedBox(height: 3),
        Text(kanji['composition']?.toString() ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11.5,
            color: isDark ? _S.moonMuted : _S.inkMuted)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small reusable components
// ─────────────────────────────────────────────────────────────────────────────

class _Ring extends StatelessWidget {
  final double size;
  final Color color;
  const _Ring({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color, width: 1.5)));
}

class _BookmarkBtn extends StatelessWidget {
  final bool isBookmarked, isDark;
  final VoidCallback onTap;
  const _BookmarkBtn({required this.isBookmarked, required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = isBookmarked ? _S.gold : _S.rose;
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: c.withOpacity(isDark ? 0.14 : 0.10),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: c.withOpacity(0.22)),
          boxShadow: isBookmarked
              ? [BoxShadow(color: c.withOpacity(0.22),
                  blurRadius: 10, offset: const Offset(0, 4))]
              : []),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            key: ValueKey(isBookmarked), size: 18, color: c)),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: color.withOpacity(0.22))),
    child: Text(text,
      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800,
          color: color)));
}

class _Reading extends StatelessWidget {
  final String label, value;
  final Color accent;
  final bool isDark;
  const _Reading({required this.label, required this.value,
      required this.accent, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: accent.withOpacity(isDark ? 0.10 : 0.07),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accent.withOpacity(0.18))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900,
          color: accent, letterSpacing: 0.3)),
      const SizedBox(height: 5),
      Text(value, maxLines: 2, overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
          height: 1.35, color: isDark ? _S.moonText : _S.ink)),
    ]));
}

class _Label extends StatelessWidget {
  final String text;
  final bool isDark;
  const _Label({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 3, height: 14,
      decoration: BoxDecoration(
          color: _S.rose, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(text,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
        color: isDark ? _S.moonText : _S.ink)),
  ]);
}

class _Div extends StatelessWidget {
  final bool isDark;
  const _Div({required this.isDark});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Container(height: 1,
      color: (isDark ? _S.moonRose : _S.rose)
          .withOpacity(isDark ? 0.13 : 0.20))),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text('✿',
        style: TextStyle(fontSize: 11,
            color: _S.rose.withOpacity(0.55)))),
    Expanded(child: Container(height: 1,
      color: (isDark ? _S.moonRose : _S.rose)
          .withOpacity(isDark ? 0.13 : 0.20))),
  ]);
}

class _TextBox extends StatelessWidget {
  final String text;
  final bool isDark;
  const _TextBox({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDark
          ? Colors.white.withOpacity(0.04)
          : _S.rose.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
          color: _S.rose.withOpacity(isDark ? 0.09 : 0.16))),
    child: Text(text.isEmpty ? '—' : text,
      style: TextStyle(fontSize: 13.5, height: 1.55,
        color: isDark ? _S.moonMuted : _S.inkSoft)));
}

class _ExCard extends StatelessWidget {
  final Map<String, dynamic> ex;
  final bool isDark;
  const _ExCard({required this.ex, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        colors: [
          _S.rose.withOpacity(isDark ? 0.10 : 0.06),
          _S.roseSoft.withOpacity(isDark ? 0.06 : 0.04)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      border: Border.all(
          color: _S.rose.withOpacity(isDark ? 0.12 : 0.22))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(ex['word']?.toString() ?? '',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900,
          color: isDark ? _S.moonText : _S.ink)),
      const SizedBox(height: 3),
      Text(ex['reading']?.toString() ?? '',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
          color: isDark ? _S.moonRose : _S.rose)),
      const SizedBox(height: 6),
      Text(ex['meaning']?.toString() ?? '',
        style: TextStyle(fontSize: 13, height: 1.4,
          color: isDark ? _S.moonMuted : _S.inkSoft)),
    ]));
}

class _DetailGrid extends StatelessWidget {
  final Map<String, dynamic> kanji;
  final bool isDark;
  const _DetailGrid({required this.kanji, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Radical',     kanji['radical']?.toString()     ?? '—'),
      ('Composition', kanji['composition']?.toString() ?? '—'),
      ('JLPT',        kanji['jlpt']?.toString()        ?? '—'),
      ('Frequency',   kanji['frequency']?.toString()   ?? '—'),
    ];
    return Wrap(spacing: 8, runSpacing: 8,
      children: rows.map((r) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _S.rose.withOpacity(isDark ? 0.08 : 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _S.rose.withOpacity(isDark ? 0.12 : 0.18))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.$1,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
              color: isDark ? _S.moonRose : _S.rose)),
          const SizedBox(height: 3),
          Text(r.$2,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700,
              color: isDark ? _S.moonText : _S.ink)),
        ]))).toList());
  }
}

class _BkdBanner extends StatelessWidget {
  final bool isDark;
  const _BkdBanner({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: _S.gold.withOpacity(isDark ? 0.12 : 0.09),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _S.gold.withOpacity(0.22))),
    child: Row(children: [
      Icon(Icons.bookmark_rounded, size: 16, color: _S.gold),
      const SizedBox(width: 8),
      Text('Saved to bookmarks',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
          color: isDark ? _S.moonText : _S.ink)),
    ]));
}

class _Hint extends StatelessWidget {
  final String text;
  final bool isDark;
  const _Hint({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) => Text(text,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 11,
      color: (isDark ? _S.moonMuted : _S.inkMuted).withOpacity(0.60)));
}