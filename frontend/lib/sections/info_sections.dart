import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

// ───────────────────────── About ─────────────────────────
class AboutSection extends StatelessWidget {
  const AboutSection({super.key, required this.about, required this.event, required this.trackCount});

  final Json about;
  final Json event;
  final int trackCount;

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(about['text'] ?? '', style: bodyStyle(mobile ? 15.5 : 17, color: AppColors.text)),
      const SizedBox(height: 24),
      Row(children: [
        const Icon(Icons.person_search_outlined, color: AppColors.red, size: 22),
        const SizedBox(width: 8),
        Text('Who Should Attend?', style: displayStyle(19)),
      ]),
      const SizedBox(height: 8),
      Text(about['who_should_attend'] ?? '', style: bodyStyle(15)),
    ]);
    final facts = _QuickFacts(event: event, trackCount: trackCount);

    return Section(
      eyebrow: "About AUTOwn'26",
      title: 'Exploring the technologies shaping next-generation vehicles',
      child: Column(children: [
        mobile
            ? Column(children: [text, const SizedBox(height: 28), facts])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 6, child: text),
                const SizedBox(width: 48),
                Expanded(flex: 4, child: facts),
              ]),
        const SizedBox(height: 44),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Event Highlights', style: displayStyle(mobile ? 22 : 26)),
        ),
        const SizedBox(height: 20),
        ResponsiveGrid(
          minItemWidth: 250,
          children: [
            for (final h in listOf(about['highlights']))
              HoverCard(
                accent: AppColors.red,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  IconBadge(iconFor(h['icon']), color: AppColors.red),
                  const SizedBox(height: 16),
                  Text(h['text'] ?? '', style: bodyStyle(14.5, color: AppColors.text)),
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
      (Icons.calendar_month_outlined, 'Main Event', event['date_label'] ?? 'TBA'),
      (Icons.event_note_outlined, 'Pre-Event Workshops', 'Friday, 12 February 2027'),
      (Icons.place_outlined, 'Venue', event['venue_short'] ?? 'TBA'),
      (Icons.emoji_events_outlined, 'Prize Pool', event['prize_pool'] ?? 'TBA'),
      (Icons.alt_route_outlined, 'Tracks', '$trackCount presentation tracks'),
    ];
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('QUICK FACTS',
            style: bodyStyle(12, color: AppColors.yellow, weight: FontWeight.w800).copyWith(letterSpacing: 3)),
        const SizedBox(height: 8),
        const BrandStripe(width: 72, height: 3),
        const SizedBox(height: 10),
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(r.$1, size: 20, color: AppColors.sky),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.$2, style: bodyStyle(12.5, color: AppColors.onDarkMuted)),
                  Text(r.$3.toString(), style: bodyStyle(15, color: Colors.white, weight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
      ]),
    );
  }
}

// ───────────────────────── Vision & Objectives ─────────────────────────
class VisionSection extends StatelessWidget {
  const VisionSection({super.key, required this.vision});

  final Json vision;

  static const _accents = [AppColors.primary, AppColors.red, AppColors.sky, AppColors.yellow];

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final objectives = listOf(vision['objectives']);
    return Section(
      eyebrow: 'Vision and Objectives',
      title: 'Our Vision',
      background: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: EdgeInsets.all(mobile ? 20 : 28),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(14),
            border: const Border(left: BorderSide(color: AppColors.red, width: 5)),
          ),
          child: Text(vision['text'] ?? '',
              style: bodyStyle(mobile ? 16 : 18.5, color: AppColors.primary, weight: FontWeight.w500)),
        ),
        const SizedBox(height: 36),
        Text('Objectives', style: displayStyle(mobile ? 22 : 26)),
        const SizedBox(height: 20),
        ResponsiveGrid(
          minItemWidth: 250,
          children: [
            for (var i = 0; i < objectives.length; i++)
              HoverCard(
                accent: _accents[i % _accents.length],
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  IconBadge(iconFor(objectives[i]['icon']), color: _accents[i % _accents.length]),
                  const SizedBox(height: 16),
                  Text(objectives[i]['title'] ?? '',
                      style: bodyStyle(17, color: AppColors.primary, weight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(objectives[i]['text'] ?? '', style: bodyStyle(14.5)),
                ]),
              ),
          ],
        ),
      ]),
    );
  }
}

// ───────────────────────── Tracks (indigo panel, as in the brochure) ─────────────────────────
class TracksSection extends StatelessWidget {
  const TracksSection({super.key, required this.tracks});
  final List<Json> tracks;

  static const _accents = [AppColors.sky, AppColors.yellow, AppColors.red];

  @override
  Widget build(BuildContext context) {
    return Section(
      dark: true,
      eyebrow: 'Project and Poster Presentation Tracks',
      title: 'Eight tracks to present your work',
      subtitle: 'Participants may submit projects or papers under the following tracks. '
          'Detailed submission guidelines will be issued separately.',
      child: ResponsiveGrid(
        minItemWidth: 340,
        children: [
          for (var i = 0; i < tracks.length; i++)
            HoverCard(
              dark: true,
              accent: _accents[i % _accents.length],
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(iconFor(tracks[i]['icon']), color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tracks[i]['title'] ?? '',
                        style: bodyStyle(16.5, color: _accents[i % _accents.length], weight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(tracks[i]['text'] ?? '', style: bodyStyle(14, color: AppColors.onDarkMuted)),
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
      title: 'Panel discussions & expert talks',
      subtitle: 'Insights from industry experts through engaging panel discussions and technical sessions. '
          'Speakers will be announced soon.',
      child: ResponsiveGrid(
        minItemWidth: 240,
        children: [
          for (final s in speakers)
            HoverCard(
              child: Column(children: [
                Container(
                  width: 104,
                  height: 104,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(colors: [AppColors.yellow, AppColors.sky, AppColors.stripeRed, AppColors.yellow]),
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    backgroundImage: (s['photo'] ?? '').toString().isNotEmpty ? NetworkImage(s['photo']) : null,
                    child: (s['photo'] ?? '').toString().isEmpty
                        ? Text(_initials(s['name'] ?? ''), style: displayStyle(26, color: Colors.white))
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(s['name'] ?? '', textAlign: TextAlign.center,
                    style: bodyStyle(16, color: AppColors.primary, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(s['role'] ?? '', textAlign: TextAlign.center, style: bodyStyle(13.5, color: AppColors.red)),
                if ((s['org'] ?? '').toString().isNotEmpty)
                  Text(s['org'], textAlign: TextAlign.center, style: bodyStyle(13.5)),
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
  int _day = 1; // open on "Day 1" (index 0 is the pre-event)

  static const _typeColor = {
    'ceremony': AppColors.yellow,
    'talk': AppColors.primary,
    'workshop': AppColors.green,
    'presentation': AppColors.sky,
    'competition': AppColors.red,
    'break': AppColors.muted,
  };

  @override
  Widget build(BuildContext context) {
    final days = widget.days;
    if (days.isEmpty) return const SizedBox.shrink();
    final day = _day < days.length ? _day : 0;
    final items = listOf(days[day]['items']);
    final mobile = isMobile(context);

    return Section(
      eyebrow: 'Proposed Schedule',
      title: 'Pre-event + two days of action',
      subtitle: 'Times are approximate and may change.',
      background: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (var i = 0; i < days.length; i++)
            ChoiceChip(
              selected: day == i,
              onSelected: (_) => setState(() => _day = i),
              showCheckmark: false,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.bg,
              side: BorderSide(color: day == i ? AppColors.primary : AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              label: Text('${days[i]['day']}  •  ${days[i]['date']}',
                  style: bodyStyle(14, color: day == i ? Colors.white : AppColors.primary, weight: FontWeight.w700)),
            ),
        ]),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Container(
            key: ValueKey(day),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Peach day title, as in the brochure
              Container(
                color: AppColors.peach,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text('${days[day]['day']} — ${days[day]['date']}',
                    style: bodyStyle(mobile ? 15 : 17, color: AppColors.primary, weight: FontWeight.w800)),
              ),
              // Header bar like the brochure's schedule tables
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(children: [
                  SizedBox(
                    width: mobile ? 96 : 170,
                    child: Text('Approx. time', style: bodyStyle(13.5, color: Colors.white, weight: FontWeight.w700)),
                  ),
                  Text('Session', style: bodyStyle(13.5, color: Colors.white, weight: FontWeight.w700)),
                ]),
              ),
              for (var i = 0; i < items.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: i.isOdd ? AppColors.surface : AppColors.bg,
                    border: const Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(
                      width: mobile ? 96 : 170,
                      child: Text(items[i]['time'] ?? '',
                          style: bodyStyle(mobile ? 12.5 : 14, color: AppColors.primary, weight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 10),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _typeColor[items[i]['type']] ?? AppColors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(items[i]['title'] ?? '',
                          style: bodyStyle(mobile ? 14 : 15,
                              color: items[i]['type'] == 'break' ? AppColors.muted : AppColors.text,
                              weight: FontWeight.w500)),
                    ),
                  ]),
                ),
            ]),
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
    if (h == null || h.length != 7) return AppColors.primary;
    return Color(int.parse('FF${h.substring(1)}', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Section(
      eyebrow: 'Sponsorship',
      title: "Partner with AUTOwn'26",
      subtitle: data['tagline'],
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ResponsiveGrid(
          minItemWidth: 250,
          children: [
            for (final t in listOf(data['tiers']))
              HoverCard(
                accent: _hex(t['color']),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(height: 5, width: 48, color: _hex(t['color'])),
                  const SizedBox(height: 16),
                  Text((t['name'] ?? '').toString().toUpperCase(),
                      style: bodyStyle(14, color: AppColors.muted, weight: FontWeight.w700).copyWith(letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text(t['price'] ?? '', style: displayStyle(28)),
                  const SizedBox(height: 16),
                  for (final p in (t['perks'] as List? ?? []))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
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
      background: AppColors.surface,
      child: Column(children: [
        for (final f in faqs)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: AppColors.red,
                collapsedIconColor: AppColors.primary,
                tilePadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                expandedAlignment: Alignment.centerLeft,
                title: Text(f['q'] ?? '', style: bodyStyle(16, color: AppColors.primary, weight: FontWeight.w600)),
                children: [Text(f['a'] ?? '', style: bodyStyle(15))],
              ),
            ),
          ),
      ]),
    );
  }
}
