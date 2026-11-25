import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

/// Opening section, styled after the brochure cover:
/// light background, AUTOwn'26 logo, theme line and an indigo "MAIN EVENT" banner.
class HeroSection extends StatefulWidget {
  const HeroSection({super.key, required this.event, required this.onRegister, required this.onExplore});

  final Json event;
  final VoidCallback onRegister;
  final VoidCallback onExplore;

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with TickerProviderStateMixin {
  // Fast loop for the road lines, slow loop for everything else in the scene.
  late final AnimationController _road =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  late final AnimationController _scene =
      AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();

  @override
  void dispose() {
    _road.dispose();
    _scene.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final mobile = isMobile(context);
    final minHeight = math.max(MediaQuery.sizeOf(context).height, 720.0);

    // Grows with its content; at least one screen tall, content centred.
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight, minWidth: double.infinity),
      child: Stack(alignment: Alignment.center, children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFFFF), Color(0xFFF1F2FA), Color(0xFFE3E6F4)],
              ),
            ),
          ),
        ),
        // Animated scene: glows, circuit traces, V2X rings, road with cars
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([_road, _scene]),
              builder: (_, __) => CustomPaint(
                painter: _ScenePainter(_scene.value, mobile: mobile),
                foregroundPainter: _RoadPainter(_road.value, _scene.value),
              ),
            ),
          ),
        ),
        // Floating automotive-tech icons along the sides (wide screens only)
        if (!mobile)
          Positioned.fill(
            child: RepaintBoundary(
              child: LayoutBuilder(
                builder: (_, c) => AnimatedBuilder(
                  animation: _scene,
                  builder: (_, __) => _FloatingIcons(size: c.biggest, t: _scene.value),
                ),
              ),
            ),
          ),
        SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, mobile ? 96 : 110, 20, 56),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/badge_46_years.png',
                      height: mobile ? 40 : 52,
                      semanticLabel: 'BITS Pilani – 46 years of delivering excellence',
                      errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                  const SizedBox(height: 14),
                  Text('BITS PILANI WILP PRESENTS',
                      textAlign: TextAlign.center,
                      style: bodyStyle(12.5, color: AppColors.red, weight: FontWeight.w700).copyWith(letterSpacing: 3)),
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: mobile ? 340 : 620),
                    child: AutownLogo(height: mobile ? 100 : 180),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Text(e['theme'] ?? '', textAlign: TextAlign.center, style: themeLineStyle(mobile ? 18 : 24)),
                  ),
                  const SizedBox(height: 22),
                  // Indigo banner, as on the brochure cover
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('MAIN EVENT: ${(e['date_label'] ?? '').toString().toUpperCase()}',
                        textAlign: TextAlign.center,
                        style: bodyStyle(mobile ? 14 : 17, color: Colors.white, weight: FontWeight.w700)
                            .copyWith(letterSpacing: 0.5)),
                  ),
                  const SizedBox(height: 12),
                  Text(e['tagline'] ?? '', textAlign: TextAlign.center, style: bodyStyle(mobile ? 13.5 : 15, color: AppColors.primary)),
                  if ((e['pre_event_label'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(e['pre_event_label'], textAlign: TextAlign.center, style: bodyStyle(mobile ? 12.5 : 13.5)),
                  ],
                  const SizedBox(height: 6),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.red),
                    const SizedBox(width: 4),
                    Flexible(child: Text(e['venue_short'] ?? '', style: bodyStyle(13.5, color: AppColors.primary))),
                  ]),
                  const SizedBox(height: 26),
                  if (e['start_date'] != null) Countdown(target: DateTime.parse(e['start_date'])),
                  const SizedBox(height: 24),
                  _PrizeBadge(amount: e['prize_pool'] ?? ''),
                  const SizedBox(height: 26),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 14,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: widget.onRegister,
                        icon: const Icon(Icons.how_to_reg_outlined),
                        label: const Text('Register Now'),
                      ),
                      OutlinedButton.icon(
                        onPressed: widget.onExplore,
                        icon: const Icon(Icons.explore_outlined),
                        label: const Text('Explore Events'),
                      ),
                    ],
                  ),
                  if ((e['registration_notice'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Pill(e['registration_notice'], color: AppColors.red, icon: Icons.campaign_outlined),
                  ],
                ],
              ),
            ),
        ),
      ]),
    );
  }
}

class _PrizeBadge extends StatelessWidget {
  const _PrizeBadge({required this.amount});
  final String amount;

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: mobile ? 18 : 26, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.yellow, width: 2),
        boxShadow: [BoxShadow(color: fade(AppColors.yellow, 0.25), blurRadius: 18)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.emoji_events, color: AppColors.yellow, size: 32),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('PRIZE MONEY UP TO',
              style: bodyStyle(11.5, color: AppColors.primary, weight: FontWeight.w700).copyWith(letterSpacing: 2)),
          Text(amount, style: displayStyle(mobile ? 24 : 28, color: AppColors.primary, weight: FontWeight.w800)),
        ]),
      ]),
    );
  }
}

/// Live countdown to the event start.
class Countdown extends StatefulWidget {
  const Countdown({super.key, required this.target});
  final DateTime target;

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  late Timer _timer;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _left = _remaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _left = _remaining()));
  }

  Duration _remaining() {
    final d = widget.target.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_left == Duration.zero) {
      return const Pill("Thank you for being part of AUTOwn'26!", icon: Icons.bolt);
    }
    final mobile = isMobile(context);
    final parts = [
      ('DAYS', _left.inDays),
      ('HOURS', _left.inHours % 24),
      ('MINS', _left.inMinutes % 60),
      ('SECS', _left.inSeconds % 60),
    ];
    return Wrap(
      spacing: mobile ? 8 : 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final p in parts)
          Container(
            width: mobile ? 70 : 90,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(children: [
              Text(p.$2.toString().padLeft(2, '0'),
                  style: displayStyle(mobile ? 24 : 30, color: Colors.white, weight: FontWeight.w700)),
              Text(p.$1, style: bodyStyle(10.5, color: AppColors.sky, weight: FontWeight.w700).copyWith(letterSpacing: 2)),
            ]),
          ),
      ],
    );
  }
}

/// Perspective road (indigo lanes + yellow centre line) with cars driving on it.
class _RoadPainter extends CustomPainter {
  _RoadPainter(this.t, this.slow);
  final double t; // fast loop: lane markings
  final double slow; // slow loop: cars

  @override
  void paint(Canvas canvas, Size size) {
    final horizon = size.height * 0.72;
    final depth = size.height - horizon;
    final vp = Offset(size.width / 2, horizon);
    final line = Paint()..strokeWidth = 1;

    for (int i = -14; i <= 14; i++) {
      if (i == 0) continue;
      final x = size.width / 2 + i * size.width / 9;
      line.color = fade(AppColors.primary, 0.08);
      canvas.drawLine(vp, Offset(x, size.height), line);
    }

    const n = 12;
    for (int i = 0; i < n; i++) {
      final f = (i + t) / n;
      final y = horizon + depth * f * f;
      line.color = fade(AppColors.sky, 0.10 + 0.30 * f);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }

    final dash = Paint()..color = fade(AppColors.yellow, 0.8);
    for (int i = 0; i < 8; i++) {
      final f1 = (i + t) / 8;
      final f2 = (i + t + 0.45) / 8;
      final y1 = horizon + depth * f1 * f1;
      final y2 = horizon + depth * math.min(1.0, f2 * f2);
      dash.strokeWidth = 1 + 4 * f1;
      canvas.drawLine(Offset(size.width / 2, y1), Offset(size.width / 2, y2), dash);
    }

    // Fade the top of the road into the background.
    final rect = Rect.fromLTWH(0, horizon - 2, size.width, 80);
    final fadeTop = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF1F2FA), Color(0x00F1F2FA)],
      ).createShader(rect);
    canvas.drawRect(rect, fadeTop);

    // Cars: two lanes driving towards the viewer, one lane driving away.
    const cars = [
      (-0.55, 0.00, AppColors.primary, true),
      (-0.55, 0.50, AppColors.red, true),
      (0.55, 0.25, AppColors.primaryLight, false),
      (0.55, 0.75, AppColors.red, false),
    ];
    for (final c in cars) {
      final towards = c.$4;
      var f = (slow * 5 + c.$2) % 1.0;
      if (!towards) f = 1 - f;
      final p = f * f; // perspective
      if (p < 0.02) continue;
      final y = horizon + depth * p;
      final laneX = size.width / 2 + c.$1 * size.width * 0.32;
      final x = vp.dx + (laneX - vp.dx) * p;
      _drawCar(canvas, Offset(x, y), 10 + 70 * p, c.$3, headlights: towards, opacity: math.min(1.0, p * 3));
    }
  }

  /// Simple car seen from the front/back: body, roof, wheels and lights.
  void _drawCar(Canvas canvas, Offset bottom, double w, Color color, {required bool headlights, double opacity = 1}) {
    final h = w * 0.42;
    final body = RRect.fromRectAndRadius(
        Rect.fromCenter(center: bottom.translate(0, -h * 0.55), width: w, height: h * 0.6), Radius.circular(w * 0.12));
    final roof = RRect.fromRectAndRadius(
        Rect.fromCenter(center: bottom.translate(0, -h * 1.0), width: w * 0.66, height: h * 0.45), Radius.circular(w * 0.14));
    final glass = RRect.fromRectAndRadius(
        Rect.fromCenter(center: bottom.translate(0, -h * 0.98), width: w * 0.52, height: h * 0.28), Radius.circular(w * 0.08));
    final paint = Paint()..color = fade(color, 0.9 * opacity);
    // shadow
    canvas.drawOval(Rect.fromCenter(center: bottom.translate(0, -h * 0.1), width: w * 1.1, height: h * 0.25),
        Paint()..color = fade(Colors.black, 0.12 * opacity));
    // wheels
    final wheel = Paint()..color = fade(const Color(0xFF14133F), opacity);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(bottom.dx - w * 0.44, bottom.dy - h * 0.35, w * 0.16, h * 0.3), Radius.circular(w * 0.03)),
        wheel);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(bottom.dx + w * 0.28, bottom.dy - h * 0.35, w * 0.16, h * 0.3), Radius.circular(w * 0.03)),
        wheel);
    canvas.drawRRect(roof, paint);
    canvas.drawRRect(glass, Paint()..color = fade(AppColors.sky, 0.75 * opacity));
    canvas.drawRRect(body, paint);
    // lights
    final lightColor = headlights ? AppColors.yellow : AppColors.stripeRed;
    final lp = Paint()..color = fade(lightColor, opacity);
    final glow = Paint()
      ..color = fade(lightColor, 0.35 * opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.08);
    for (final dx in [-w * 0.34, w * 0.34]) {
      final c = bottom.translate(dx, -h * 0.6);
      canvas.drawCircle(c, w * 0.12, glow);
      canvas.drawCircle(c, w * 0.055, lp);
    }
  }

  @override
  bool shouldRepaint(covariant _RoadPainter old) => old.t != t || old.slow != slow;
}

/// Background scene behind the hero text: drifting brand-colour glows, a dot grid,
/// circuit traces with travelling light pulses (from the logo's circuit car), and
/// pulsing V2X "signal" rings around connected nodes.
class _ScenePainter extends CustomPainter {
  _ScenePainter(this.t, {required this.mobile});
  final double t; // 0..1 over the slow loop
  final bool mobile;

  static const _traces = <List<Offset>>[
    [Offset(0, .16), Offset(.09, .16), Offset(.13, .22), Offset(.24, .22)],
    [Offset(0, .30), Offset(.05, .30), Offset(.09, .36), Offset(.17, .36), Offset(.20, .42)],
    [Offset(0, .52), Offset(.07, .52), Offset(.11, .46), Offset(.21, .46)],
    [Offset(.04, .66), Offset(.10, .60), Offset(.18, .60)],
    [Offset(1, .14), Offset(.91, .14), Offset(.87, .20), Offset(.76, .20)],
    [Offset(1, .32), Offset(.94, .32), Offset(.90, .38), Offset(.82, .38), Offset(.79, .44)],
    [Offset(1, .54), Offset(.93, .54), Offset(.89, .48), Offset(.79, .48)],
    [Offset(.96, .66), Offset(.90, .60), Offset(.82, .60)],
  ];

  static const _nodes = <Offset>[
    Offset(.26, .12), Offset(.33, .07), Offset(.40, .13),
    Offset(.60, .13), Offset(.67, .07), Offset(.74, .12),
  ];

  static const _pulseColors = [AppColors.sky, AppColors.red, AppColors.yellow, AppColors.primaryLight];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final tau = 2 * math.pi;

    // 1. Drifting glows in brand colours
    final glows = [
      (const Offset(.18, .30), AppColors.sky, 0.30),
      (const Offset(.82, .28), AppColors.peach, 0.42),
      (const Offset(.50, .62), AppColors.red, 0.10),
      (const Offset(.85, .70), AppColors.sky, 0.20),
    ];
    for (var i = 0; i < glows.length; i++) {
      final g = glows[i];
      final c = Offset(
        w * (g.$1.dx + 0.05 * math.sin(tau * (t + i / 4))),
        h * (g.$1.dy + 0.04 * math.cos(tau * (t + i / 4))),
      );
      final r = math.max(w, h) * 0.30;
      canvas.drawCircle(
          c,
          r,
          Paint()
            ..shader = RadialGradient(colors: [fade(g.$2, g.$3), fade(g.$2, 0)])
                .createShader(Rect.fromCircle(center: c, radius: r)));
    }

    // 2. Dot grid (upper area)
    final dot = Paint()..color = fade(AppColors.primary, 0.07);
    final step = mobile ? 22.0 : 28.0;
    for (double y = step; y < h * 0.70; y += step) {
      for (double x = step / 2; x < w; x += step) {
        canvas.drawCircle(Offset(x, y), 1.1, dot);
      }
    }

    // 3. Circuit traces with travelling pulses
    final tracePaint = Paint()
      ..color = fade(AppColors.primary, 0.16)
      ..strokeWidth = mobile ? 1.2 : 1.6
      ..style = PaintingStyle.stroke;
    final padNode = Paint()..color = AppColors.bg;
    final padRing = Paint()
      ..color = fade(AppColors.primary, 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var i = 0; i < _traces.length; i++) {
      if (mobile && i.isOdd) continue;
      final pts = [for (final o in _traces[i]) Offset(o.dx * w, o.dy * h)];
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final p in pts.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, tracePaint);
      canvas.drawCircle(pts.last, 4, padNode);
      canvas.drawCircle(pts.last, 4, padRing);

      // pulse
      final color = _pulseColors[i % _pulseColors.length];
      final pos = _pointAlong(pts, (t * 4 + i * 0.137) % 1.0);
      canvas.drawCircle(
          pos,
          9,
          Paint()
            ..color = fade(color, 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      canvas.drawCircle(pos, 3, Paint()..color = color);
    }

    // 4. Connected nodes with V2X signal rings (top area, either side of the logo)
    if (!mobile) {
      final link = Paint()
        ..color = fade(AppColors.sky, 0.45)
        ..strokeWidth = 1.2;
      final nodes = [for (final n in _nodes) Offset(n.dx * w, n.dy * h)];
      for (var i = 0; i < nodes.length - 1; i++) {
        if (i == 2) continue; // two separate clusters
        canvas.drawLine(nodes[i], nodes[i + 1], link);
      }
      for (var i = 0; i < nodes.length; i++) {
        for (var k = 0; k < 2; k++) {
          final p = (t * 6 + i * 0.21 + k * 0.5) % 1.0;
          canvas.drawCircle(
              nodes[i],
              5 + 26 * p,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5
                ..color = fade(i.isEven ? AppColors.sky : AppColors.red, 0.55 * (1 - p)));
        }
        canvas.drawCircle(nodes[i], 4.5, Paint()..color = i.isEven ? AppColors.primary : AppColors.red);
      }
    }
  }

  /// Point at fraction [f] (0..1) of the total length of a polyline.
  Offset _pointAlong(List<Offset> pts, double f) {
    var total = 0.0;
    for (var i = 1; i < pts.length; i++) {
      total += (pts[i] - pts[i - 1]).distance;
    }
    var target = total * f;
    for (var i = 1; i < pts.length; i++) {
      final seg = (pts[i] - pts[i - 1]).distance;
      if (target <= seg && seg > 0) return Offset.lerp(pts[i - 1], pts[i], target / seg)!;
      target -= seg;
    }
    return pts.last;
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) => old.t != t || old.mobile != mobile;
}

/// Gently bobbing icon chips (EV, AI, security, V2X...) along both sides of the hero.
class _FloatingIcons extends StatelessWidget {
  const _FloatingIcons({required this.size, required this.t});
  final Size size;
  final double t;

  static const _chips = [
    (Icons.directions_car_filled_outlined, 0.07, 0.25, AppColors.primary),
    (Icons.ev_station_outlined, 0.14, 0.42, AppColors.green),
    (Icons.memory_outlined, 0.05, 0.58, AppColors.red),
    (Icons.smart_toy_outlined, 0.16, 0.70, AppColors.primaryLight),
    (Icons.security_outlined, 0.93, 0.25, AppColors.red),
    (Icons.wifi_tethering, 0.86, 0.42, AppColors.sky),
    (Icons.precision_manufacturing_outlined, 0.95, 0.58, AppColors.primary),
    (Icons.flight_outlined, 0.84, 0.70, AppColors.peachDeep),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      for (var i = 0; i < _chips.length; i++)
        Positioned(
          left: size.width * _chips[i].$2 - 26,
          top: size.height * _chips[i].$3 - 26 + 10 * math.sin(2 * math.pi * (t * 3 + i * 0.13)),
          child: Transform.rotate(
            angle: 0.08 * math.sin(2 * math.pi * (t * 2 + i * 0.21)),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: fade(Colors.white, 0.9),
                shape: BoxShape.circle,
                border: Border.all(color: fade(_chips[i].$4, 0.35)),
                boxShadow: [BoxShadow(color: fade(AppColors.primary, 0.10), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Icon(_chips[i].$1, size: 24, color: fade(_chips[i].$4, 0.85)),
            ),
          ),
        ),
    ]);
  }
}
