import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

// ───────────────────────── Contact ─────────────────────────
// Detailed track / competition / workshop coordinator lists are not shown on the
// website; they are shared with participants after registration.
class ContactSection extends StatelessWidget {
  const ContactSection({
    super.key,
    required this.coordinators,
    required this.venue,
    required this.event,
    this.afterNote = '',
  });

  final List<Json> coordinators;
  final Json venue;
  final Json event;
  final String afterNote;

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final email = (event['support_email'] ?? '').toString();

    final people = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('COORDINATORS', style: bodyStyle(12, color: AppColors.red, weight: FontWeight.w800).copyWith(letterSpacing: 3)),
      const SizedBox(height: 12),
      for (final c in coordinators)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.peach,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c['name'] ?? '', style: bodyStyle(16, color: Colors.white, weight: FontWeight.w700)),
                  if ((c['phone'] ?? '').toString().isNotEmpty)
                    InkWell(
                      onTap: () => openUrl('tel:${c['phone']}'),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.phone_outlined, size: 14, color: AppColors.peach),
                        const SizedBox(width: 6),
                        Text(c['phone'], style: bodyStyle(14, color: AppColors.peach, weight: FontWeight.w600)),
                      ]),
                    ),
                ]),
              ),
            ]),
          ),
        ),
      if (email.isNotEmpty)
        InkWell(
          onTap: () => openUrl('mailto:$email'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              const CircleAvatar(radius: 22, backgroundColor: AppColors.red, child: Icon(Icons.mail_outline, color: Colors.white)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Email us', style: bodyStyle(13)),
                  Text(email, style: bodyStyle(14.5, color: AppColors.primary, weight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),
        ),
      if (afterNote.isNotEmpty) ...[
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(afterNote, style: bodyStyle(14, color: AppColors.text))),
        ]),
      ],
    ]);

    return Section(
      eyebrow: 'Contact',
      title: 'Get in touch',
      subtitle: 'Questions about registrations, submissions or partnerships? Reach the AUTOwn\'26 team.',
      background: AppColors.surface,
      child: mobile
          ? Column(children: [people, const SizedBox(height: 24), _VenueCard(venue: venue)])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 6, child: people),
              const SizedBox(width: 32),
              Expanded(flex: 5, child: _VenueCard(venue: venue)),
            ]),
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({required this.venue});
  final Json venue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('VENUE', style: bodyStyle(12, color: AppColors.red, weight: FontWeight.w800).copyWith(letterSpacing: 3)),
        const SizedBox(height: 12),
        Row(children: [
          const IconBadge(Icons.location_city_outlined, size: 44),
          const SizedBox(width: 14),
          Expanded(child: Text(venue['name'] ?? '', style: bodyStyle(16, color: AppColors.primary, weight: FontWeight.w700))),
        ]),
        const SizedBox(height: 12),
        Text(venue['address'] ?? '', style: bodyStyle(14)),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => openUrl(venue['map_url'] ?? ''),
          icon: const Icon(Icons.map_outlined),
          label: const Text('View on Google Maps'),
        ),
      ]),
    );
  }
}

// ───────────────────────── Footer (indigo, like the brochure's back cover) ─────────────────────────
class Footer extends StatelessWidget {
  const Footer({super.key, required this.event, required this.onNav, required this.navItems});

  final Json event;
  final void Function(String) onNav;
  final List<String> navItems;

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
      child: Column(children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 32,
          runSpacing: 20,
          children: [
            AutownLogo(height: mobile ? 56 : 72, white: true),
            Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: WilpLogo(height: mobile ? 48 : 58)),
          ],
        ),
        const SizedBox(height: 16),
        Text(event['theme'] ?? '', textAlign: TextAlign.center, style: themeLineStyle(16, color: Colors.white)),
        const SizedBox(height: 14),
        const BrandStripe(width: 150),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: [
            for (final n in navItems)
              TextButton(onPressed: () => onNav(n), child: Text(n, style: bodyStyle(14, color: AppColors.onDarkMuted))),
          ],
        ),
        const SizedBox(height: 10),
        Divider(color: fade(Colors.white, 0.15)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => openUrl(event['website'] ?? 'https://bits-pilani-wilp.ac.in'),
          child: Text('bits-pilani-wilp.ac.in/autown',
              style: bodyStyle(13.5, color: AppColors.sky, weight: FontWeight.w600).copyWith(letterSpacing: 2)),
        ),
        const SizedBox(height: 6),
        Text('© 2027 ${event['name'] ?? "AUTOwn'26"} • ${event['organiser'] ?? ''}',
            textAlign: TextAlign.center, style: bodyStyle(13, color: AppColors.onDarkMuted)),
        const SizedBox(height: 4),
        Text('Designed for the future of smart mobility • Built By Swami & Raj',
            textAlign: TextAlign.center, style: bodyStyle(12.5, color: AppColors.onDarkMuted)),
      ]),
    );
  }
}
