import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    'lightbulb': Icons.lightbulb_outline,
    'forum': Icons.forum_outlined,
    'groups': Icons.groups_outlined,
    'build': Icons.build_outlined,
    'construction': Icons.construction_outlined,
    'emoji_events': Icons.emoji_events_outlined,
    'directions_car': Icons.directions_car_filled_outlined,
    'smart_toy': Icons.smart_toy_outlined,
    'security': Icons.security_outlined,
    'ev_station': Icons.ev_station_outlined,
    'memory': Icons.memory_outlined,
    'cell_tower': Icons.cell_tower_outlined,
    'precision_manufacturing': Icons.precision_manufacturing_outlined,
    'article': Icons.article_outlined,
    'co_present': Icons.co_present_outlined,
    'sports_motorsports': Icons.sports_motorsports_outlined,
    'flag': Icons.flag_outlined,
    'view_in_ar': Icons.view_in_ar_outlined,
    'flight': Icons.flight_outlined,
    'shield': Icons.shield_outlined,
    'developer_board': Icons.developer_board_outlined,
    'badge': Icons.badge_outlined,
  };
  return icons[name] ?? Icons.auto_awesome_outlined;
}

/// The brochure's yellow / sky-blue / red accent stripe.
class BrandStripe extends StatelessWidget {
  const BrandStripe({super.key, this.width = 120, this.height = 4});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final w = width / 3;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: w, height: height, color: AppColors.yellow),
      Container(width: w, height: height, color: AppColors.sky),
      Container(width: w, height: height, color: AppColors.stripeRed),
    ]);
  }
}

/// A page section with an eyebrow label, title, optional subtitle and centred content.
/// [dark] gives the indigo panel look used in the brochure.
class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    required this.child,
    this.background,
    this.dark = false,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget child;
  final Color? background;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    return Container(
      width: double.infinity,
      color: dark ? AppColors.primary : background,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 40, vertical: mobile ? 64 : 96),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(width: 4, height: 18, color: dark ? AppColors.peach : AppColors.peachDeep),
                const SizedBox(width: 10),
                Text(eyebrow.toUpperCase(),
                    style: bodyStyle(13, color: dark ? AppColors.peach : AppColors.red, weight: FontWeight.w700)
                        .copyWith(letterSpacing: 2.5)),
              ]),
              const SizedBox(height: 12),
              Text(title, style: displayStyle(mobile ? 28 : 38, color: dark ? AppColors.onDark : AppColors.primary)),
              const SizedBox(height: 14),
              const BrandStripe(),
              if (subtitle != null) ...[
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Text(subtitle!,
                      style: bodyStyle(mobile ? 15 : 16.5, color: dark ? AppColors.onDarkMuted : AppColors.muted)),
                ),
              ],
              SizedBox(height: mobile ? 32 : 44),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Lays children out in equal-width columns that collapse on small screens.
/// Cards in the same row get the same height (the tallest card's real height),
/// so their edges and bottom buttons line up.
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
      final rows = <Widget>[];
      for (var i = 0; i < children.length; i += cols) {
        rows.add(_EqualHeightRow(
          itemWidth: itemWidth,
          spacing: spacing,
          children: children.sublist(i, math.min(i + cols, children.length)),
        ));
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) SizedBox(height: spacing),
          rows[r],
        ],
      ]);
    });
  }
}

/// Lays each child out at its natural height first, then again at the
/// tallest child's height, so every card in the row is the same height.
class _EqualHeightRow extends MultiChildRenderObjectWidget {
  const _EqualHeightRow({required super.children, required this.itemWidth, required this.spacing});

  final double itemWidth;
  final double spacing;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderEqualHeightRow(itemWidth, spacing);

  @override
  void updateRenderObject(BuildContext context, _RenderEqualHeightRow renderObject) {
    renderObject
      ..itemWidth = itemWidth
      ..spacing = spacing;
  }
}

class _EqualHeightParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderEqualHeightRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _EqualHeightParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _EqualHeightParentData> {
  _RenderEqualHeightRow(this._itemWidth, this._spacing);

  double _itemWidth;
  double _spacing;

  set itemWidth(double v) {
    if (v == _itemWidth) return;
    _itemWidth = v;
    markNeedsLayout();
  }

  set spacing(double v) {
    if (v == _spacing) return;
    _spacing = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _EqualHeightParentData) child.parentData = _EqualHeightParentData();
  }

  @override
  void performLayout() {
    // Pass 1: natural height of every card.
    var maxHeight = 0.0;
    var child = firstChild;
    while (child != null) {
      child.layout(BoxConstraints(minWidth: _itemWidth, maxWidth: _itemWidth), parentUsesSize: true);
      maxHeight = math.max(maxHeight, child.size.height);
      child = childAfter(child);
    }
    // Pass 2: every card at least as tall as the tallest one.
    // The height is a minimum (not a fixed size) on purpose: with a fixed size
    // Flutter would not re-measure the row when the web font finishes loading
    // and text re-wraps, which caused the "overflowed" stripes.
    var x = 0.0;
    var rowHeight = 0.0;
    child = firstChild;
    while (child != null) {
      child.layout(BoxConstraints(minWidth: _itemWidth, maxWidth: _itemWidth, minHeight: maxHeight),
          parentUsesSize: true);
      (child.parentData! as _EqualHeightParentData).offset = Offset(x, 0);
      rowHeight = math.max(rowHeight, child.size.height);
      x += _itemWidth + _spacing;
      child = childAfter(child);
    }
    final width = constraints.hasBoundedWidth ? constraints.maxWidth : math.max(0.0, x - _spacing);
    size = constraints.constrain(Size(width, rowHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// Card that lifts and gets a coloured edge on hover.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    this.accent = AppColors.primary,
    this.padding = 24,
    this.height,
    this.dark = false,
  });

  final Widget child;
  final Color accent;
  final double padding;
  final double? height;
  final bool dark;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final baseBorder = widget.dark ? fade(Colors.white, 0.14) : AppColors.border;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: widget.height,
        transform: Matrix4.translationValues(0, _hover ? -5 : 0, 0),
        padding: EdgeInsets.all(widget.padding),
        decoration: BoxDecoration(
          color: widget.dark ? fade(Colors.white, _hover ? 0.10 : 0.06) : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _hover ? widget.accent : baseBorder, width: _hover ? 1.5 : 1),
          boxShadow: [
            if (!widget.dark)
              BoxShadow(
                color: fade(AppColors.primary, _hover ? 0.12 : 0.05),
                blurRadius: _hover ? 26 : 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// Rounded square holding an icon with a soft tinted background.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.color = AppColors.primary, this.size = 50});

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
        borderRadius: BorderRadius.circular(12),
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
  const Pill(this.text, {super.key, this.color = AppColors.primary, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fade(color, 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: fade(color, 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 6)],
        Flexible(child: Text(text, style: bodyStyle(12.5, color: color, weight: FontWeight.w600))),
      ]),
    );
  }
}

/// BITS Pilani WILP logo. [white] uses the version made for indigo backgrounds.
/// Clicking it opens the WILP website.
class WilpLogo extends StatelessWidget {
  const WilpLogo({super.key, this.height = 40, this.white = false});

  final double height;
  final bool white;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => openUrl('https://bits-pilani-wilp.ac.in/'),
        child: SizedBox(
          height: height,
          child: Image.asset(
            white ? 'assets/images/wilp_logo_white.png' : 'assets/images/wilp_logo.png',
            fit: BoxFit.contain,
            semanticLabel: 'BITS Pilani Work Integrated Learning Programmes',
            errorBuilder: (_, __, ___) => Center(
              child: Text('BITS Pilani WILP',
                  style: bodyStyle(height * 0.32, color: white ? Colors.white : AppColors.primary, weight: FontWeight.w800)),
            ),
          ),
        ),
      ),
    );
  }
}

/// AUTOwn'26 event logo. [tagline] adds the theme line under it; [white] is for indigo backgrounds.
class AutownLogo extends StatelessWidget {
  const AutownLogo({super.key, this.height = 40, this.white = false, this.tagline = false});

  final double height;
  final bool white;
  final bool tagline;

  @override
  Widget build(BuildContext context) {
    final file = white
        ? 'assets/images/autown_logo_white.png'
        : tagline
            ? 'assets/images/autown_logo_tagline.png'
            : 'assets/images/autown_logo.png';
    return SizedBox(
      height: height,
      child: Image.asset(
        file,
        fit: BoxFit.contain,
        semanticLabel: "AUTOwn'26",
        errorBuilder: (_, __, ___) => FittedBox(
          child: Text("AUTOwn'26",
              style: displayStyle(48, color: white ? Colors.white : AppColors.primary, weight: FontWeight.w800)),
        ),
      ),
    );
  }
}
