import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

class EventsSection extends StatefulWidget {
  const EventsSection({super.key, required this.events, required this.prizePool, required this.onRegister});

  final List<Json> events;
  final String prizePool;
  final void Function(String eventId) onRegister;

  @override
  State<EventsSection> createState() => _EventsSectionState();
}

class _EventsSectionState extends State<EventsSection> {
  String _filter = 'All';

  static const _catColor = {
    'Presentation': AppColors.blue,
    'Competition': AppColors.pink,
    'Workshop': AppColors.green,
    'Attendee': AppColors.amber,
  };

  @override
  Widget build(BuildContext context) {
    final cats = ['All', ...{for (final e in widget.events) e['category'].toString()}];
    final shown = _filter == 'All' ? widget.events : widget.events.where((e) => e['category'] == _filter).toList();

    return Section(
      eyebrow: 'Events',
      title: 'Present. Compete. Learn.',
      subtitle: 'Choose your challenge — paper and project presentations, autonomous racing competitions '
          'and hands-on technical workshops. Prizes worth ${widget.prizePool} up for grabs!',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (final c in cats)
            FilterChip(
              selected: _filter == c,
              onSelected: (_) => setState(() => _filter = c),
              showCheckmark: false,
              selectedColor: fade(AppColors.cyan, 0.2),
              backgroundColor: AppColors.card,
              side: BorderSide(color: _filter == c ? AppColors.cyan : AppColors.border),
              label: Text(c, style: bodyStyle(14, color: _filter == c ? AppColors.cyan : AppColors.text, weight: FontWeight.w600)),
            ),
        ]),
        const SizedBox(height: 28),
        ResponsiveGrid(
          minItemWidth: 320,
          children: [for (final e in shown) _EventCard(event: e, color: _catColor[e['category']] ?? AppColors.cyan, onRegister: widget.onRegister)],
        ),
      ]),
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
    return HoverCard(
      accent: color,
      height: 340,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconBadge(iconFor(event['icon']), color: color),
          const Spacer(),
          Pill(event['category'] ?? '', color: color),
        ]),
        const SizedBox(height: 18),
        Text(event['title'] ?? '', style: bodyStyle(19, color: AppColors.text, weight: FontWeight.w700)),
        const SizedBox(height: 8),
        Expanded(
          child: Text(event['text'] ?? '', style: bodyStyle(14.5), overflow: TextOverflow.fade),
        ),
        const SizedBox(height: 10),
        _meta(Icons.groups_outlined, event['team'] ?? ''),
        const SizedBox(height: 4),
        _meta(Icons.payments_outlined, 'Fee: ${event['fee'] ?? 'TBA'}'),
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
    );
  }

  Widget _meta(IconData icon, String text) => Row(children: [
        Icon(icon, size: 16, color: AppColors.muted),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: bodyStyle(13, color: AppColors.text))),
      ]);
}
