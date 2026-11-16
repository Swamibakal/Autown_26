import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';

typedef Json = Map<String, dynamic>;

List<Json> listOf(dynamic v) => v == null ? <Json>[] : (v as List).cast<Json>();

bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < 820;

Future<void> openUrl(String url) async {
  if (url.isEmpty) return;
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

/// Maps icon names sent by the backend to Material icons.
IconData iconFor(String? name) {
  const icons = <String, IconData>{
    'hub': Icons.hub_outlined,
    'psychology': Icons.psychology_outlined,
    'build': Icons.build_outlined,
    'directions_car': Icons.directions_car_filled_outlined,
    'smart_toy': Icons.smart_toy_outlined,
    'security': Icons.security_outlined,
    'ev_station': Icons.ev_station_outlined,
    'memory': Icons.memory_outlined,
    'precision_manufacturing': Icons.precision_manufacturing_outlined,
    'article': Icons.article_outlined,
    'co_present': Icons.co_present_outlined,
    'sports_motorsports': Icons.sports_motorsports_outlined,
    'flight': Icons.flight_outlined,
    'shield': Icons.shield_outlined,
    'developer_board': Icons.developer_board_outlined,
    'badge': Icons.badge_outlined,
  };
  return icons[name] ?? Icons.auto_awesome_outlined;
}

/// A page section with an eyebrow label, title, optional subtitle and centred content.
class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    required this.child,
    this.background,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget child;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    return Container(
      width: double.infinity,
      color: background,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 40, vertical: mobile ? 64 : 100),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(width: 28, height: 2, color: AppColors.cyan),
                const SizedBox(width: 10),
                Text(eyebrow.toUpperCase(),
                    style: bodyStyle(13, color: AppColors.cyan, weight: FontWeight.w700)
                        .copyWith(letterSpacing: 3)),
              ]),
              const SizedBox(height: 14),
              Text(title, style: displayStyle(mobile ? 28 : 40)),
              if (subtitle != null) ...[
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Text(subtitle!, style: bodyStyle(mobile ? 15 : 17)),
                ),
              ],
              SizedBox(height: mobile ? 32 : 48),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Lays children out in equal-width columns that collapse on small screens.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key, required this.children, this.minItemWidth = 280, this.spacing = 20});

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = math.max(1, ((c.maxWidth + spacing) / (minItemWidth + spacing)).floor());
      final itemWidth = (c.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [for (final w in children) SizedBox(width: itemWidth, child: w)],
      );
    });
  }
}

/// Card that lifts and glows on hover.
class HoverCard extends StatefulWidget {
  const HoverCard({super.key, required this.child, this.accent = AppColors.cyan, this.padding = 26, this.height});

  final Widget child;
  final Color accent;
  final double padding;
  final double? height;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: widget.height,
        transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
        padding: EdgeInsets.all(widget.padding),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _hover ? fade(widget.accent, 0.7) : AppColors.border),
          boxShadow: [
            if (_hover) BoxShadow(color: fade(widget.accent, 0.18), blurRadius: 30, spreadRadius: 1),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// Rounded square holding an icon with a soft tinted background.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.color = AppColors.cyan, this.size = 52});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fade(color, 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fade(color, 0.35)),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.style, this.gradient = brandGradient, this.textAlign});

  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = AppColors.cyan, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fade(color, 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: fade(color, 0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 6)],
        Text(text, style: bodyStyle(12.5, color: color, weight: FontWeight.w600)),
      ]),
    );
  }
}
