import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

/// Registration fees + filterable list of presentations, competitions and workshops.
class EventsSection extends StatefulWidget {
  const EventsSection({
    super.key,
    required this.events,
    required this.fees,
    required this.prizePool,
    required this.onRegister,
  });

  final List<Json> events;
  final List<Json> fees;
  final String prizePool;
  final void Function(String eventId) onRegister;

  @override
  State<EventsSection> createState() => _EventsSectionState();
}

class _EventsSectionState extends State<EventsSection> {
  String _filter = 'All';

  static const _catColor = {
    'Presentation': AppColors.primary,
    'Competition': AppColors.red,
    'Workshop': AppColors.green,
  };

  static const _catLabel = {
    'Presentation': 'Presentations',
    'Competition': 'Competitions',
    'Workshop': 'Workshops',
  };

  @override
  Widget build(BuildContext context) {
    final cats = ['All', ...{for (final e in widget.events) e['category'].toString()}];
    final shown = _filter == 'All' ? widget.events : widget.events.where((e) => e['category'] == _filter).toList();

    return Section(
      eyebrow: 'Events & Registration',
      title: 'Present. Compete. Learn.',
      subtitle: 'Technical competitions, project and paper presentations and industry-oriented workshops — '
          'with prize money up to ${widget.prizePool}.',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _FeesPanel(fees: widget.fees, prizePool: widget.prizePool),
        const SizedBox(height: 40),
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (final c in cats)
            FilterChip(
              selected: _filter == c,
              onSelected: (_) => setState(() => _filter = c),
              showCheckmark: false,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.bg,
              side: BorderSide(color: _filter == c ? AppColors.primary : AppColors.border),
              label: Text(_catLabel[c] ?? c,
                  style: bodyStyle(14, color: _filter == c ? Colors.white : AppColors.primary, weight: FontWeight.w600)),
            ),
        ]),
        const SizedBox(height: 24),
        ResponsiveGrid(
          minItemWidth: 320,
          children: [
            for (final e in shown)
              _EventCard(event: e, color: _catColor[e['category']] ?? AppColors.primary, onRegister: widget.onRegister),
          ],
        ),
      ]),
    );
  }
}

/// "Registration Details" panel, styled like the brochure: indigo with the prize seal.
class _FeesPanel extends StatelessWidget {
  const _FeesPanel({required this.fees, required this.prizePool});
  final List<Json> fees;
  final String prizePool;

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final feeList = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.receipt_long_outlined, color: AppColors.yellow),
        const SizedBox(width: 10),
        Text('Registration Details', style: displayStyle(mobile ? 20 : 24, color: Colors.white)),
      ]),
      const SizedBox(height: 18),
      for (final f in fees)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Icon(iconFor(f['icon']), color: AppColors.sky, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(f['category'] ?? '', style: bodyStyle(15.5, color: Colors.white, weight: FontWeight.w600))),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(f['fee'] ?? '', style: displayStyle(mobile ? 18 : 20, color: AppColors.yellow)),
              Text(f['unit'] ?? '', style: bodyStyle(12, color: AppColors.onDarkMuted)),
            ]),
          ]),
        ),
    ]);
    final seal = Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLight,
        border: Border.all(color: AppColors.yellow, width: 3),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.star, color: AppColors.yellow, size: 18),
        Text('PRIZE MONEY\nUP TO',
            textAlign: TextAlign.center,
            style: bodyStyle(11, color: Colors.white, weight: FontWeight.w800).copyWith(height: 1.2, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(prizePool, style: displayStyle(20, color: AppColors.yellow, weight: FontWeight.w800)),
      ]),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 22 : 32),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
      child: mobile
          ? Column(children: [feeList, const SizedBox(height: 16), seal])
          : Row(children: [Expanded(child: feeList), const SizedBox(width: 40), seal]),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.color, required this.onRegister});

  final Json event;
  final Color color;
  final void Function(String) onRegister;

  @override
  Widget build(BuildContext context) {
    final open = event['open'] != false;
    final partner = (event['partner'] ?? '').toString();
    return HoverCard(
      accent: color,
      // Top part (details) and bottom part (fee + Register) are pushed apart,
      // so Register buttons line up across a row of equal-height cards.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          IconBadge(iconFor(event['icon']), color: color),
          const Spacer(),
          Pill(event['category'] ?? '', color: color),
        ]),
        const SizedBox(height: 16),
        Text(event['title'] ?? '', style: bodyStyle(18, color: AppColors.primary, weight: FontWeight.w700)),
        if (partner.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(partner, style: bodyStyle(13, color: AppColors.red, weight: FontWeight.w600)),
        ],
        const SizedBox(height: 8),
        Text(event['text'] ?? '', style: bodyStyle(14.5)),
        if (listOf(event['coordinators']).isNotEmpty) ...[
          const SizedBox(height: 14),
          _Coordinators(coordinators: listOf(event['coordinators'])),
        ],
        if (listOf(event['track_coordinators']).isNotEmpty) ...[
          const SizedBox(height: 14),
          _TrackCoordinators(tracks: listOf(event['track_coordinators'])),
        ],
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 14),
        Row(children: [
          const Icon(Icons.payments_outlined, size: 17, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(event['fee'] ?? 'TBA', style: bodyStyle(14, color: AppColors.primary, weight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: open ? () => onRegister(event['id']) : null,
            child: Text(open ? 'Register' : 'Registrations closed'),
          ),
        ),
      ]),
        ],
      ),
    );
  }
}

/// Tap-to-call phone number.
class _Phone extends StatelessWidget {
  const _Phone(this.number);
  final String number;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openUrl('tel:$number'),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.phone_outlined, size: 14, color: AppColors.red),
          const SizedBox(width: 4),
          Text(number, style: bodyStyle(13, color: AppColors.primary, weight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

/// Coordinator names and numbers for a competition or workshop.
class _Coordinators extends StatelessWidget {
  const _Coordinators({required this.coordinators});
  final List<Json> coordinators;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: fade(AppColors.peach, 0.30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('COORDINATORS', style: bodyStyle(11, color: AppColors.red, weight: FontWeight.w800).copyWith(letterSpacing: 2)),
        const SizedBox(height: 6),
        for (final c in coordinators)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 2,
              children: [
                Text(c['names'] ?? '', style: bodyStyle(13.5, color: AppColors.text, weight: FontWeight.w600)),
                for (final ph in (c['phones'] as List? ?? [])) _Phone(ph.toString()),
              ],
            ),
          ),
      ]),
    );
  }
}

/// Expandable list of track coordinators for the presentation cards.
class _TrackCoordinators extends StatelessWidget {
  const _TrackCoordinators({required this.tracks});
  final List<Json> tracks;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: fade(AppColors.peach, 0.30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          dense: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          iconColor: AppColors.red,
          collapsedIconColor: AppColors.primary,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text('TRACK COORDINATORS',
              style: bodyStyle(11, color: AppColors.red, weight: FontWeight.w800).copyWith(letterSpacing: 2)),
          children: [
            for (final t in tracks)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t['track'] ?? '', style: bodyStyle(13.5, color: AppColors.primary, weight: FontWeight.w700)),
                  Text(t['names'] ?? '', style: bodyStyle(13, color: AppColors.text)),
                  Wrap(spacing: 10, children: [
                    for (final ph in (t['phones'] as List? ?? [])) _Phone(ph.toString()),
                  ]),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}
