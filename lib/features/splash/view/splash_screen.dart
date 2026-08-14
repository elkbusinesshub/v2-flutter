import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../cubit/splash_cubit.dart';

// ─── Design tokens (from elk_splash_screen_premium.html) ──────────────────────
const _ink950 = Color(0xFF050F0E);
const _ink900 = Color(0xFF0B211E);
const _teal = Color(0xFF4FC0B5);
const _tealSoft = Color(0xFF9FE7DD);
const _gold = Color(0xFFFFD93E);
const _goldSoft = Color(0xFFFFEA9C);
const _paper = Color(0xFFF6F4EC);
const _mist = Color(0xFF8FB0AB);

List<String> _loaderLabelsFor(AppLocalizations l10n) =>
    [l10n.splashSettingUp, l10n.splashFindingPros, l10n.splashAlmostThere];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onResolved});

  /// Called once the destination has been resolved.
  final void Function(SplashDestination destination) onResolved;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // one-shot intro choreography (slide-in, flash, rises)
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..forward();
  // logo glow pulse
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1900))
        ..repeat(reverse: true);
  // loader progress + window blink (2.6s like the CSS)
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();
  // shimmer stripe on the loader fill
  late final AnimationController _shimmer =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1700))..repeat();
  // floating gold particles
  late final AnimationController _particles =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 5000))..repeat();
  // light sweep across the screen
  late final AnimationController _sweep =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 7000))..repeat();

  Timer? _labelTimer;
  int _labelIx = 0;

  @override
  void initState() {
    super.initState();
    context.read<SplashCubit>().resolveDestination();
    _labelTimer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      if (mounted) setState(() => _labelIx = (_labelIx + 1) % 3);
    });
  }

  @override
  void dispose() {
    _labelTimer?.cancel();
    _intro.dispose();
    _pulse.dispose();
    _loop.dispose();
    _shimmer.dispose();
    _particles.dispose();
    _sweep.dispose();
    super.dispose();
  }

  // staggered interval helper (delays in ms over the 2000ms intro)
  Animation<double> _stage(int startMs, int endMs, [Curve curve = Curves.easeOutCubic]) {
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(startMs / 2000, endMs / 2000, curve: curve),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state.destination != null) {
          widget.onResolved(state.destination!);
        }
      },
      child: Scaffold(
        body: Stack(children: [
          // ── background ────────────────────────────────────────────────────
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.4, -1),
                  end: Alignment(0.4, 1),
                  colors: [_ink900, _ink950, Color(0xFF030908)],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.6, -0.8),
                  radius: 0.9,
                  colors: [Color(0x384FC0B5), Colors.transparent],
                  stops: [0.0, 0.6],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.72, 0.84),
                  radius: 0.7,
                  colors: [Color(0x17FFD93E), Colors.transparent],
                  stops: [0.0, 0.6],
                ),
              ),
            ),
          ),
          // ── light sweep ───────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _sweep,
            builder: (context, _) {
              final t = (_sweep.value / 0.38).clamp(0.0, 1.0);
              final w = MediaQuery.of(context).size.width;
              return Positioned(
                left: -0.7 * w + t * 2.0 * w,
                top: -100,
                bottom: -100,
                width: w * 0.55,
                child: IgnorePointer(
                  child: Transform.rotate(
                    angle: -12 * math.pi / 180,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0x0DFFFFFF),
                            Color(0x1AFFFFFF),
                            Color(0x0DFFFFFF),
                            Colors.transparent,
                          ],
                          stops: [0.42, 0.49, 0.5, 0.51, 0.58],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // ── skylines ──────────────────────────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: bottomPad + 108,
            height: 150,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: Opacity(
                opacity: 0.5,
                child: CustomPaint(painter: _SkylinePainter.back()),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: Listenable.merge([_intro, _loop]),
            builder: (context, _) {
              final rise = _stage(920, 1870).value;
              return Positioned(
                left: 0, right: 0, bottom: bottomPad + 118 - (1 - rise) * -24,
                height: 130,
                child: Opacity(
                  opacity: rise,
                  child: Transform.translate(
                    offset: Offset(0, (1 - rise) * 24),
                    child: CustomPaint(
                      painter: _SkylinePainter.front(blinkT: _loop.value),
                    ),
                  ),
                ),
              );
            },
          ),
          // ── brand block ───────────────────────────────────────────────────
          Positioned(
            top: topPad + 96, left: 0, right: 0,
            child: Column(children: [
              SizedBox(
                width: 280, height: 220,
                child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
                  // pulsing glow
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) {
                      final s = 1 + _pulse.value * 0.12;
                      return Transform.scale(
                        scale: s,
                        child: Container(
                          width: 280, height: 280,
                          decoration: const BoxDecoration(
                            gradient: RadialGradient(
                              colors: [Color(0x5C4FC0B5), Color(0x174FC0B5), Colors.transparent],
                              stops: [0.0, 0.45, 0.72],
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                  // floating particles
                  AnimatedBuilder(
                    animation: _particles,
                    builder: (context, _) {
                      Widget dot(double xFrac, double yFrac, double phase) {
                        final t = (_particles.value + phase) % 1.0;
                        final op = t < 0.15
                            ? t / 0.15 * 0.8
                            : t < 0.85
                                ? 0.8 - (t - 0.15) / 0.7 * 0.55
                                : (1 - t) / 0.15 * 0.25;
                        return Positioned(
                          left: 280 * xFrac,
                          top: 220 * yFrac - t * 86,
                          child: Opacity(
                            opacity: op.clamp(0.0, 1.0),
                            child: Container(
                              width: 3, height: 3,
                              decoration: const BoxDecoration(color: _goldSoft, shape: BoxShape.circle),
                            ),
                          ),
                        );
                      }

                      return Stack(clipBehavior: Clip.none, children: [
                        dot(0.28, 0.60, 0.00),
                        dot(0.68, 0.64, 0.45),
                        dot(0.46, 0.50, 0.20),
                        dot(0.80, 0.58, 0.70),
                      ]);
                    },
                  ),
                  // logo: two halves sliding together + snap flash
                  Positioned(
                    top: 40,
                    child: SizedBox(
                      width: 190, height: 60,
                      child: AnimatedBuilder(
                        animation: _intro,
                        builder: (context, _) {
                          final slide = _stage(160, 800, Curves.easeOutBack).value;
                          final flash = _stage(720, 1200, Curves.easeOut).value;
                          final dx = 46 * (1 - slide);
                          return Stack(clipBehavior: Clip.none, children: [
                            // left half (EL)
                            Opacity(
                              opacity: slide.clamp(0, 1),
                              child: Transform.translate(
                                offset: Offset(-dx, 0),
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: 0.64,
                                    child: SvgPicture.asset('assets/icons/elk_logo.svg', width: 190),
                                  ),
                                ),
                              ),
                            ),
                            // right half (K)
                            Positioned(
                              right: 0,
                              child: Opacity(
                                opacity: slide.clamp(0, 1),
                                child: Transform.translate(
                                  offset: Offset(dx, 0),
                                  child: ClipRect(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      widthFactor: 0.36,
                                      child: SvgPicture.asset('assets/icons/elk_logo.svg', width: 190),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // snap flash
                            if (flash > 0 && flash < 1)
                              Positioned(
                                left: 190 * 0.638 - 4,
                                top: 60 * 0.48 - 4,
                                child: Opacity(
                                  opacity: (flash < 0.35 ? flash / 0.35 * 0.85 : (1 - flash) / 0.65 * 0.85)
                                      .clamp(0.0, 1.0),
                                  child: Transform.scale(
                                    scale: 0.3 + flash * 4.3,
                                    child: Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(
                                        color: _goldSoft,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: _goldSoft.withValues(alpha: 0.8), blurRadius: 6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ]);
                        },
                      ),
                    ),
                  ),
                  // wordmark + divider + tagline
                  Positioned(
                    top: 118, left: 0, right: 0,
                    child: AnimatedBuilder(
                      animation: _intro,
                      builder: (context, _) {
                        final word = _stage(460, 1160).value;
                        final draw = _stage(640, 1100).value;
                        final tag = _stage(760, 1460).value;
                        return Column(children: [
                          Opacity(
                            opacity: word,
                            child: Transform.translate(
                              offset: Offset(0, (1 - word) * 10),
                              child: Text(
                                'BUSINESS HUB',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: _paper,
                                  letterSpacing: 6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // divider draws left → right
                          SizedBox(
                            width: 34, height: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 34 * draw,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [_teal, _gold]),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Opacity(
                            opacity: tag,
                            child: Transform.translate(
                              offset: Offset(0, (1 - tag) * 10),
                              child: Column(children: [
                                Text(
                                  'YOUR CITY · YOUR SERVICES',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: _tealSoft,
                                    letterSpacing: 3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Trusted local businesses,\none tap away.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: _mist,
                                    height: 1.55,
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ]);
                      },
                    ),
                  ),
                ]),
              ),
            ]),
          ),
          // ── loader ────────────────────────────────────────────────────────
          Positioned(
            left: 60, right: 60, bottom: bottomPad + 42,
            child: AnimatedBuilder(
              animation: Listenable.merge([_intro, _loop, _shimmer]),
              builder: (context, _) {
                final visible = _stage(1280, 1880).value;
                final t = _loop.value;
                final progress = t < 0.7 ? 0.06 + (t / 0.7) * 0.86 : 0.92;
                return Opacity(
                  opacity: visible,
                  child: Column(children: [
                    // track + fill + shimmer
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 4,
                        child: Stack(children: [
                          Positioned.fill(
                            child: ColoredBox(color: _paper.withValues(alpha: 0.12)),
                          ),
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Stack(children: [
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [_teal, _gold]),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(color: _teal.withValues(alpha: 0.5), blurRadius: 12),
                                    ],
                                  ),
                                ),
                              ),
                              // shimmer stripe
                              Positioned.fill(
                                child: LayoutBuilder(builder: (context, cons) {
                                  final w = cons.maxWidth;
                                  return Stack(children: [
                                    Positioned(
                                      left: -0.4 * w + _shimmer.value * 1.8 * w,
                                      top: 0, bottom: 0,
                                      width: w * 0.3,
                                      child: const DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.transparent, Color(0xA6FFFFFF), Colors.transparent],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]);
                                }),
                              ),
                            ]),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        child: Text(
                          _loaderLabelsFor(AppLocalizations.of(context))[_labelIx],
                          key: ValueKey(_labelIx),
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _mist,
                          ),
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _tealSoft,
                          fontFeatures: const [ui.FontFeature.tabularFigures()],
                        ),
                      ),
                    ]),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Skyline painter (polygons transcribed from the HTML SVGs) ────────────────
class _SkylinePainter extends CustomPainter {
  _SkylinePainter.back()
      : viewH = 150,
        blinkT = null,
        buildings = const [
          ([0, 150, 0, 60, 30, 60, 30, 40, 60, 40, 60, 150], 0.10),
          ([55, 150, 55, 20, 85, 20, 85, 4, 140, 4, 140, 150], 0.14),
          ([130, 150, 130, 72, 165, 72, 165, 54, 200, 54, 200, 150], 0.10),
          ([190, 150, 190, 10, 225, 10, 225, -4, 260, -4, 260, 150], 0.16),
          ([250, 150, 250, 58, 280, 58, 280, 38, 330, 38, 330, 150], 0.10),
          ([320, 150, 320, 84, 345, 84, 345, 68, 390, 68, 390, 150], 0.10),
        ];

  _SkylinePainter.front({required double this.blinkT})
      : viewH = 130,
        buildings = const [
          ([0, 130, 0, 78, 22, 78, 22, 64, 44, 64, 44, 130], 0.16),
          ([40, 130, 40, 50, 62, 50, 62, 36, 88, 36, 88, 130], 0.22),
          ([84, 130, 84, 88, 106, 88, 106, 72, 124, 72, 124, 130], 0.16),
          ([118, 130, 118, 30, 140, 30, 140, 16, 172, 16, 172, 130], 0.32),
          ([168, 130, 168, 60, 186, 60, 186, 44, 210, 44, 210, 130], 0.18),
          ([204, 130, 204, 20, 226, 20, 226, 8, 258, 8, 258, 130], 0.36),
          ([252, 130, 252, 66, 270, 66, 270, 50, 294, 50, 294, 130], 0.18),
          ([288, 130, 288, 42, 310, 42, 310, 26, 336, 26, 336, 130], 0.26),
          ([330, 130, 330, 84, 350, 84, 350, 70, 390, 70, 390, 130], 0.16),
        ];

  final double viewH;
  final double? blinkT; // 0..1 loop for blinking windows (front layer only)
  final List<(List<num>, double)> buildings;

  // blinking windows: x, y, delay fraction of the 2.6s cycle
  static const _blinkWins = [
    (130.0, 46.0, 0.077), // 0.2s / 2.6s
    (146.0, 70.0, 0.423),
    (216.0, 36.0, 0.231),
    (236.0, 58.0, 0.615),
    (298.0, 58.0, 0.346),
  ];
  static const _staticWins = [(146.0, 46.0, 0.35), (298.0, 36.0, 0.3)];

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 390;
    final sy = size.height / viewH;

    for (final (pts, op) in buildings) {
      final path = Path()..moveTo(pts[0] * sx, pts[1] * sy);
      for (var i = 2; i < pts.length; i += 2) {
        path.lineTo(pts[i] * sx, pts[i + 1] * sy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = _teal.withValues(alpha: op));
    }

    if (blinkT != null) {
      for (final (x, y, delay) in _blinkWins) {
        // CSS blink: 0.3 → 0.95 → 0.3 over the cycle
        final t = (blinkT! - delay) % 1.0;
        final op = 0.3 + 0.65 * math.sin(t * math.pi);
        canvas.drawRect(
          Rect.fromLTWH(x * sx, y * sy, 5 * sx, 5 * sy),
          Paint()..color = _gold.withValues(alpha: op.clamp(0.0, 1.0)),
        );
      }
      for (final (x, y, op) in _staticWins) {
        canvas.drawRect(
          Rect.fromLTWH(x * sx, y * sy, 5 * sx, 5 * sy),
          Paint()..color = _gold.withValues(alpha: op),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SkylinePainter old) => old.blinkT != blinkT;
}
