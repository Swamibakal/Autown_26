import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

// ───────────────────────── About / Vision ─────────────────────────
class VisionSection extends StatelessWidget {
  const VisionSection({super.key, required this.vision, required this.event, required this.trackCount});

  final Json vision;
  final Json event;
  final int trackCount;

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final text = Text(vision['text'] ?? '', style: bodyStyle(mobile ? 15.5 : 17.5, color: AppColors.text));
    final facts = _QuickFacts(event: event, trackCount: trackCount);

    return Section(
      eyebrow: 'About AUTOwn\'26',
      title: 'Where industry innovation\nmeets intelligent mobility',
      child: Column(children: [
        mobile
            ? Column(children: [text, const SizedBox(height: 28), facts])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 6, child: text),
                const SizedBox(width: 48),
                Expanded(flex: 4, child: facts),
              ]),
        const SizedBox(height: 44),
        ResponsiveGrid(
          minItemWidth: 300,
          children: [
            for (final o in listOf(vision['objectives']))
              HoverCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  IconBadge(iconFor(o['icon'])),
                  const SizedBox(height: 18),
                  Text(o['title'] ?? '', style: bodyStyle(18, color: AppColors.text, weight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(o['text'] ?? '', style: bodyStyle(14.5)),
                ]),
              ),
          ],
        ),
      ]),
    );
  }
}

class _QuickFacts extends StatelessWidget {
  const _QuickFacts({required this.event, required this.trackCount});
  final Json event;
  final int trackCount;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.calendar_month_outlined, 'Dates', event['date_label'] ?? 'TBA'),
      (Icons.place_outlined, 'Venue', event['venue_short'] ?? 'TBA'),
      (Icons.emoji_events_outlined, 'Prize Pool', event['prize_pool'] ?? 'TBA'),
      (Icons.alt_route_outlined, 'Tracks', '$trackCount technical tracks'),
      (Icons.account_balance_outlined, 'Organised by', event['organiser'] ?? ''),
    ];
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [fade(AppColors.cyan, 0.10), fade(AppColors.blue, 0.04)]),
        border: Border.all(color: fade(AppColors.cyan, 0.35)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('QUICK FACTS', style: bodyStyle(12, color: AppColors.cyan, weight: FontWeight.w800).copyWith(letterSpacing: 3)),
        const SizedBox(height: 16),
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(r.$1, size: 20, color: AppColors.cyan),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.$2, style: bodyStyle(12.5)),
                  Text(r.$3.toString(), style: bodyStyle(15, color: AppColors.text, weight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
      ]),
    );
  }
}

// ───────────────────────── Tracks ─────────────────────────
class TracksSection extends StatelessWidget {
  const TracksSection({super.key, required this.tracks});
  final List<Json> tracks;

  static const _accents = [AppColors.cyan, AppColors.blue, AppColors.pink, AppColors.green, AppColors.amber, AppColors.teal];

  @override
  Widget build(BuildContext context) {
    return Section(
      eyebrow: 'Technical Tracks',
      title: 'Six lanes to the future',
      subtitle: 'Submit papers and projects, or join workshops and competitions across these focus areas.',
      background: AppColors.surface,
      child: ResponsiveGrid(
        minItemWidth: 320,
        children: [
          for (var i = 0; i < tracks.length; i++)
            HoverCard(
              accent: _accents[i % _accents.length],
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                IconBadge(iconFor(tracks[i]['icon']), color: _accents[i % _accents.length]),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tracks[i]['title'] ?? '', style: bodyStyle(17, color: AppColors.text, weight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(tracks[i]['text'] ?? '', style: bodyStyle(14)),
                  ]),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── Speakers ─────────────────────────
class SpeakersSection extends StatelessWidget {
  const SpeakersSection({super.key, required this.speakers});
  final List<Json> speakers;

  String _initials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty && p[0].toUpperCase() == p[0]).take(2);
    final s = parts.map((p) => p[0]).join();
    return s.isEmpty ? '?' : s;
  }

  @override
  Widget build(BuildContext context) {
    return Section(
      eyebrow: 'Speakers',
      title: 'Voices driving the industry',
      subtitle: 'Keynotes and talks from industry leaders and researchers. More speakers will be announced soon.',
      background: AppColors.surface,
      child: ResponsiveGrid(
        minItemWidth: 240,
        children: [
          for (final s in speakers)
            HoverCard(
              child: Column(children: [
                Container(
                  width: 110,
                  height: 110,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(shape: BoxShape.circle, gradient: brandGradient),
                  child: CircleAvatar(
                    backgroundColor: AppColors.card,
                    backgroundImage: (s['photo'] ?? '').toString().isNotEmpty ? NetworkImage(s['photo']) : null,
                    child: (s['photo'] ?? '').toString().isEmpty
                        ? Text(_initials(s['name'] ?? ''), style: displayStyle(26, color: AppColors.cyan))
                        : null,
                  ),
                ),
                const SizedBox(height: 18),
                Text(s['name'] ?? '', textAlign: TextAlign.center,
                    style: bodyStyle(16.5, color: AppColors.text, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(s['role'] ?? '', textAlign: TextAlign.center, style: bodyStyle(13.5, color: AppColors.cyan)),
                Text(s['org'] ?? '', textAlign: TextAlign.center, style: bodyStyle(13.5)),
                if ((s['link'] ?? '').toString().isNotEmpty)
                  TextButton.icon(
                    onPressed: () => openUrl(s['link']),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Profile'),
                  ),
              ]),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── Schedule ─────────────────────────
class ScheduleSection extends StatefulWidget {
  const ScheduleSection({super.key, required this.days});
  final List<Json> days;

  @override
  State<ScheduleSection> createState() => _ScheduleSectionState();
}

class _ScheduleSectionState extends State<ScheduleSection> {
  int _day = 0;

  static const _typeColor = {
    'ceremony': AppColors.amber,
    'talk': AppColors.cyan,
    'workshop': AppColors.green,
    'presentation': AppColors.blue,
    'competition': AppColors.pink,
    'break': AppColors.muted,
  };

  @override
  Widget build(BuildContext context) {
    final days = widget.days;
    if (days.isEmpty) return const SizedBox.shrink();
    final items = listOf(days[_day]['items']);
    final mobile = isMobile(context);

    return Section(
      eyebrow: 'Schedule',
      title: 'Two days. Full throttle.',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 12, runSpacing: 12, children: [
          for (var i = 0; i < days.length; i++)
            ChoiceChip(
              selected: _day == i,
              onSelected: (_) => setState(() => _day = i),
              showCheckmark: false,
              selectedColor: AppColors.cyan,
              backgroundColor: AppColors.card,
              side: BorderSide(color: _day == i ? AppColors.cyan : AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              label: Text('${days[i]['day']}  •  ${days[i]['date']}',
                  style: bodyStyle(14.5, color: _day == i ? AppColors.bg : AppColors.text, weight: FontWeight.w700)),
            ),
        ]),
        const SizedBox(height: 30),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Column(
            key: ValueKey(_day),
            children: [
              for (var i = 0; i < items.length; i++)
                IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    SizedBox(
                      width: mobile ? 92 : 150,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(items[i]['time'] ?? '',
                            style: bodyStyle(mobile ? 12.5 : 14.5, color: AppColors.text, weight: FontWeight.w600)),
                      ),
                    ),
                    // timeline rail
                    SizedBox(
                      width: 30,
                      child: Column(children: [
                        Container(width: 2, height: 22, color: i == 0 ? Colors.transparent : AppColors.border),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _typeColor[items[i]['type']] ?? AppColors.cyan,
                            boxShadow: [
                              BoxShadow(color: fade(_typeColor[items[i]['type']] ?? AppColors.cyan, 0.5), blurRadius: 10),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(width: 2, color: i == items.length - 1 ? Colors.transparent : AppColors.border),
                        ),
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14, top: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: items[i]['type'] == 'break' ? Colors.transparent : AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(items[i]['title'] ?? '',
                              style: bodyStyle(15.5,
                                  color: items[i]['type'] == 'break' ? AppColors.muted : AppColors.text,
                                  weight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ]),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ───────────────────────── Sponsorship ─────────────────────────
class SponsorshipSection extends StatelessWidget {
  const SponsorshipSection({super.key, required this.data, required this.onContact});
  final Json data;
  final VoidCallback onContact;

  Color _hex(String? h) {
    if (h == null || h.length != 7) return AppColors.cyan;
    return Color(int.parse('FF${h.substring(1)}', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Section(
      eyebrow: 'Sponsorship',
      title: 'Partner with AUTOwn\'26',
      subtitle: data['tagline'],
      background: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ResponsiveGrid(
          minItemWidth: 250,
          children: [
            for (final t in listOf(data['tiers']))
              HoverCard(
                accent: _hex(t['color']),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(height: 4, width: 48, color: _hex(t['color'])),
                  const SizedBox(height: 18),
                  Text((t['name'] ?? '').toString().toUpperCase(),
                      style: displayStyle(16, color: _hex(t['color']), weight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(t['price'] ?? '', style: displayStyle(28)),
                  const SizedBox(height: 18),
                  for (final p in (t['perks'] as List? ?? []))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.check_circle_outline, size: 18, color: _hex(t['color'])),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p.toString(), style: bodyStyle(14, color: AppColors.text))),
                      ]),
                    ),
                ]),
              ),
          ],
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: onContact,
          icon: const Icon(Icons.handshake_outlined),
          label: const Text('Become a sponsor'),
        ),
      ]),
    );
  }
}

// ───────────────────────── FAQ ─────────────────────────
class FaqSection extends StatelessWidget {
  const FaqSection({super.key, required this.faqs});
  final List<Json> faqs;

  @override
  Widget build(BuildContext context) {
    return Section(
      eyebrow: 'FAQ',
      title: 'Questions, answered',
      child: Column(children: [
        for (final f in faqs)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: AppColors.cyan,
                collapsedIconColor: AppColors.muted,
                tilePadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                childrenPadding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                expandedAlignment: Alignment.centerLeft,
                title: Text(f['q'] ?? '', style: bodyStyle(16, color: AppColors.text, weight: FontWeight.w600)),
                children: [Text(f['a'] ?? '', style: bodyStyle(15))],
              ),
            ),
          ),
      ]),
    );
  }
}
