import 'package:flutter/material.dart';

import '../api.dart';
import '../theme.dart';
import '../widgets/common.dart';

// ───────────────────────── Contact & Venue ─────────────────────────
class ContactSection extends StatelessWidget {
  const ContactSection({super.key, required this.coordinators, required this.venue, required this.event});

  final List<Json> coordinators;
  final Json venue;
  final Json event;

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    final left = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('OVERALL COORDINATORS', style: bodyStyle(12, color: AppColors.cyan, weight: FontWeight.w800).copyWith(letterSpacing: 3)),
      const SizedBox(height: 14),
      for (final c in coordinators)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: HoverCard(
            padding: 18,
            child: Row(children: [
              const IconBadge(Icons.person_outline, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c['name'] ?? '', style: bodyStyle(16, color: AppColors.text, weight: FontWeight.w700)),
                  Text(c['role'] ?? '', style: bodyStyle(13.5)),
                ]),
              ),
            ]),
          ),
        ),
      const SizedBox(height: 18),
      Text('VENUE', style: bodyStyle(12, color: AppColors.cyan, weight: FontWeight.w800).copyWith(letterSpacing: 3)),
      const SizedBox(height: 14),
      HoverCard(
        padding: 20,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const IconBadge(Icons.location_city_outlined, size: 44),
            const SizedBox(width: 14),
            Expanded(child: Text(venue['name'] ?? '', style: bodyStyle(16, color: AppColors.text, weight: FontWeight.w700))),
          ]),
          const SizedBox(height: 12),
          Text(venue['address'] ?? '', style: bodyStyle(14)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => openUrl(venue['map_url'] ?? ''),
            icon: const Icon(Icons.map_outlined),
            label: const Text('View on Google Maps'),
          ),
        ]),
      ),
      if ((event['support_email'] ?? '').toString().isNotEmpty) ...[
        const SizedBox(height: 18),
        TextButton.icon(
          onPressed: () => openUrl('mailto:${event['support_email']}'),
          icon: const Icon(Icons.mail_outline),
          label: Text(event['support_email']),
        ),
      ],
    ]);

    return Section(
      eyebrow: 'Contact',
      title: 'Get in touch',
      subtitle: 'Questions about registrations, sponsorship or submissions? Drop us a message.',
      background: AppColors.surface,
      child: mobile
          ? Column(children: [left, const SizedBox(height: 32), const _ContactForm()])
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 5, child: left),
              const SizedBox(width: 40),
              const Expanded(flex: 6, child: _ContactForm()),
            ]),
    );
  }
}

class _ContactForm extends StatefulWidget {
  const _ContactForm();

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _msg = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _msg.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final res = await Api.contact({'name': _name.text.trim(), 'email': _email.text.trim(), 'message': _msg.text.trim()});
      _form.currentState!.reset();
      _name.clear();
      _email.clear();
      _msg.clear();
      messenger.showSnackBar(SnackBar(content: Text(res['message'] ?? 'Message sent!')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.pink));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Send a message', style: bodyStyle(20, color: AppColors.text, weight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Your name', prefixIcon: Icon(Icons.person_outline)),
            validator: (v) => (v ?? '').trim().length < 2 ? 'Enter your name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
            validator: validateEmail,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _msg,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Message', alignLabelWithHint: true),
            validator: (v) => (v ?? '').trim().length < 5 ? 'Message is too short' : null,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _busy ? null : _submit,
            icon: _busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send_outlined),
            label: const Text('Send'),
          ),
        ]),
      ),
    );
  }
}

String? validateEmail(String? v) {
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim());
  return ok ? null : 'Enter a valid email';
}

// ───────────────────────── Footer ─────────────────────────
class Footer extends StatelessWidget {
  const Footer({super.key, required this.event, required this.onNav, required this.navItems});

  final Json event;
  final void Function(String) onNav;
  final List<String> navItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(children: [
        GradientText(event['name'] ?? "AUTOwn'26", style: displayStyle(28)),
        const SizedBox(height: 8),
        Text(event['theme'] ?? '', textAlign: TextAlign.center, style: themeLineStyle(16)),
        const SizedBox(height: 22),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          children: [
            for (final n in navItems)
              TextButton(onPressed: () => onNav(n), child: Text(n, style: bodyStyle(14, color: AppColors.muted))),
          ],
        ),
        const SizedBox(height: 18),
        const Divider(color: AppColors.border),
        const SizedBox(height: 14),
        Text('© 2027 ${event['name'] ?? "AUTOwn'26"} • ${event['organiser'] ?? ''}',
            textAlign: TextAlign.center, style: bodyStyle(13)),
        const SizedBox(height: 4),
        Text('Designed for the future of smart mobility • Built with Flutter & Python',
            textAlign: TextAlign.center, style: bodyStyle(12.5)),
      ]),
    );
  }
}
