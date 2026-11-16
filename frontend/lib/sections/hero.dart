import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key, required this.event, required this.onRegister, required this.onExplore});

  final Json event;
  final VoidCallback onRegister;
  final VoidCallback onExplore;

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with SingleTickerProviderStateMixin {
  late final AnimationController _road =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

  @override
  void dispose() {
    _road.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final mobile = isMobile(context);
    final height = math.max(MediaQuery.sizeOf(context).height, mobile ? 780.0 : 760.0);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(children: [
        // Background gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF071226), AppColors.bg, Color(0xFF04121C)],
              ),
            ),
          ),
        ),
        // Animated perspective "road" grid
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _road,
              builder: (_, __) => CustomPaint(painter: _RoadPainter(_road.value)),
            ),
          ),
        ),
        // Content
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, mobile ? 90 : 110, 20, 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                                    WilpLogo(height: mobile ? 60 : 80),
                  const SizedBox(height: 12),
                  Text('PRESENTS', style: bodyStyle(12, color: AppColors.cyan, weight: FontWeight.w700).copyWith(letterSpacing: 4)),
                  const SizedBox(height: 22),
                  GradientText(
                    e['name'] ?? "AUTOwn'26",
                    textAlign: TextAlign.center,
                    style: displayStyle(mobile ? 52 : 96, weight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Text(e['theme'] ?? '', textAlign: TextAlign.center, style: themeLineStyle(mobile ? 20 : 30)),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 22,
                    runSpacing: 10,
                    children: [
                      _info(Icons.event_outlined, 'Main Event: ${e['date_label'] ?? ''}'),
                      _info(Icons.location_on_outlined, e['venue_short'] ?? ''),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(e['tagline'] ?? '', textAlign: TextAlign.center, style: bodyStyle(mobile ? 13.5 : 15)),
                  const SizedBox(height: 30),
                  if (e['start_date'] != null) Countdown(target: DateTime.parse(e['start_date'])),
                  const SizedBox(height: 28),
                  _PrizeBadge(amount: e['prize_pool'] ?? ''),
                  const SizedBox(height: 30),
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
                    const SizedBox(height: 26),
                    Pill(e['registration_notice'], color: AppColors.amber, icon: Icons.campaign_outlined),
                  ],
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _info(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: AppColors.cyan),
        const SizedBox(width: 8),
        Text(text, style: bodyStyle(15, color: AppColors.text, weight: FontWeight.w600)),
      ]);
}

class _PrizeBadge extends StatelessWidget {
  const _PrizeBadge({required this.amount});
  final String amount;

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: mobile ? 18 : 28, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [fade(AppColors.amber, 0.16), fade(AppColors.amber, 0.04)]),
        border: Border.all(color: fade(AppColors.amber, 0.5)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.emoji_events_outlined, color: AppColors.amber, size: 30),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('TOTAL PRIZE POOL', style: bodyStyle(11.5, color: AppColors.amber, weight: FontWeight.w700).copyWith(letterSpacing: 2)),
          Text(amount, style: displayStyle(mobile ? 24 : 30, color: AppColors.amber)),
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
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final d = widget.target.difference(DateTime.now());
    setState(() => _left = d.isNegative ? Duration.zero : d);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_left == Duration.zero) {
      return const Pill('The event is live / concluded — thank you for being part of AUTOwn\'26!', icon: Icons.bolt);
    }
    final mobile = isMobile(context);
    final parts = [
      ('DAYS', _left.inDays),
      ('HOURS', _left.inHours % 24),
      ('MINS', _left.inMinutes % 60),
      ('SECS', _left.inSeconds % 60),
    ];
    return Wrap(
      spacing: mobile ? 8 : 14,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final p in parts)
          Container(
            width: mobile ? 72 : 96,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: fade(AppColors.card, 0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: [
              Text(p.$2.toString().padLeft(2, '0'), style: displayStyle(mobile ? 24 : 32, color: AppColors.cyan)),
              const SizedBox(height: 4),
              Text(p.$1, style: bodyStyle(11, weight: FontWeight.w600).copyWith(letterSpacing: 2)),
            ]),
          ),
      ],
    );
  }
}

/// Synthwave-style perspective road that scrolls towards the viewer.
class _RoadPainter extends CustomPainter {
  _RoadPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final horizon = size.height * 0.66;
    final vp = Offset(size.width / 2, horizon);

    // Horizon glow
    final glow = Paint()
      ..shader = RadialGradient(colors: [fade(AppColors.blue, 0.30), fade(AppColors.blue, 0)])
          .createShader(Rect.fromCircle(center: vp, radius: size.width * 0.45));
    canvas.drawCircle(vp, size.width * 0.45, glow);

    final line = Paint()..strokeWidth = 1;

    // Converging lanes
    for (int i = -14; i <= 14; i++) {
      final x = size.width / 2 + i * size.width / 9;
      line.color = fade(AppColors.cyan, i == 0 ? 0.0 : 0.13);
      canvas.drawLine(vp, Offset(x, size.height), line);
    }

    // Moving cross lines (perspective spacing)
    const n = 12;
    for (int i = 0; i < n; i++) {
      final f = (i + t) / n;
      final y = horizon + (size.height - horizon) * f * f;
      line.color = fade(AppColors.cyan, 0.04 + 0.22 * f);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }

    // Centre dashed lane marking
    final dash = Paint()
      ..color = fade(AppColors.amber, 0.45)
      ..strokeWidth = 2;
    for (int i = 0; i < 8; i++) {
      final f1 = (i + t) / 8;
      final f2 = (i + t + 0.45) / 8;
      final y1 = horizon + (size.height - horizon) * f1 * f1;
      final y2 = horizon + (size.height - horizon) * math.min(1.0, f2 * f2);
      canvas.drawLine(Offset(size.width / 2, y1), Offset(size.width / 2, y2), dash..strokeWidth = 1 + 4 * f1);
    }

    // Fade the top of the grid into the background
    final fadeTop = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.bg, fade(AppColors.bg, 0)],
      ).createShader(Rect.fromLTWH(0, horizon - 2, size.width, 90));
    canvas.drawRect(Rect.fromLTWH(0, horizon - 2, size.width, 90), fadeTop);
  }

  @override
  bool shouldRepaint(covariant _RoadPainter old) => old.t != t;
}
