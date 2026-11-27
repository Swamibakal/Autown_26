import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import 'common.dart';

/// Opens the registration dialog. [registration] is the "registration" block of
/// assets/content.json. [optionId] preselects an event (e.g. from an event card).
Future<void> showRegisterDialog(BuildContext context, {required Json registration, String? optionId}) {
  return showDialog(
    context: context,
    barrierColor: fade(Colors.black, 0.6),
    builder: (_) => RegisterDialog(registration: registration, optionId: optionId),
  );
}

/// Registration itself happens on Zoho Backstage (link set in content.json). This dialog only helps people pick
/// the right ticket: Competitions / Workshop / Attendee → event → (track),
/// then opens the matching Zoho Backstage link in a new tab.
class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key, required this.registration, this.optionId});

  final Json registration;
  final String? optionId;

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  late final List<Json> _tabs = listOf(widget.registration['tabs']);
  int _tab = 0;
  String? _optionId;
  String? _sub;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Preselect the tab + option that was clicked on an event card.
    if (widget.optionId != null) {
      for (var i = 0; i < _tabs.length; i++) {
        if (listOf(_tabs[i]['options']).any((o) => o['id'] == widget.optionId)) {
          _tab = i;
          _optionId = widget.optionId;
        }
      }
    }
  }

  List<Json> get _options => _tabs.isEmpty ? <Json>[] : listOf(_tabs[_tab]['options']);

  Json? get _option {
    for (final o in _options) {
      if (o['id'] == _optionId) return o;
    }
    return null;
  }

  Json? get _subBlock => _option?['sub'] as Json?;

  bool get _ready => _option != null && (_subBlock == null || _sub != null);

  String get _zohoUrl {
    final own = (_option?['zoho_url'] ?? '').toString().trim();
    if (own.isNotEmpty) return own;
    return (widget.registration['zoho_event_url'] ?? '').toString().trim();
  }

  /// Payment link for the chosen option (its own "payment_url", else the
  /// default "payment_url" in the registration block). Empty = no payment step.
  String get _paymentUrl {
    final own = (_option?['payment_url'] ?? '').toString().trim();
    if (own.isNotEmpty) return own;
    return (widget.registration['payment_url'] ?? '').toString().trim();
  }

  bool get _isFree => (_option?['fee'] ?? '').toString().toLowerCase().startsWith('free');

  /// Paid options with a payment link use two steps: 1. Pay, 2. Register.
  bool get _twoStep => _option != null && !_isFree && _paymentUrl.isNotEmpty;

  bool _payOpened = false; // "Pay now" was clicked
  bool _registered = false;

  /// "register_first" (default) or "pay_first", from content.json.
  bool get _registerFirst => (widget.registration['payment_order'] ?? 'register_first') != 'pay_first';

  void _selectTab(int i) => setState(() {
        _tab = i;
        _optionId = null;
        _sub = null;
        _error = null;
        _payOpened = false;
        _registered = false;
      });

  Future<void> _pay() async {
    final ok = await launchUrl(Uri.parse(_paymentUrl), webOnlyWindowName: '_blank');
    if (!mounted) return;
    if (ok) {
      setState(() {
        _payOpened = true;
        _error = null;
      });
    } else {
      setState(() => _error = 'Could not open the payment page. Please allow pop-ups and try again.');
    }
  }

  Future<void> _continue() async {
    final url = _zohoUrl;
    if (url.isEmpty) {
      setState(() => _error = 'Online registration will open soon. Please check back shortly.');
      return;
    }
    final ok = await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
    if (!ok && mounted) setState(() => _error = 'Could not open the registration page. Please allow pop-ups and try again.');
  }

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    return Dialog(
      backgroundColor: AppColors.bg,
      insetPadding: EdgeInsets.all(mobile ? 12 : 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
            _header(mobile),
            Padding(
              padding: EdgeInsets.fromLTRB(mobile ? 18 : 28, 20, mobile ? 18 : 28, 26),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _tabBar(mobile),
                const SizedBox(height: 22),
                if (_tabs.isNotEmpty) ..._dropdowns(),
                if (_option != null) ...[
                  const SizedBox(height: 18),
                  _summary(),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(_error!, style: bodyStyle(13.5, color: AppColors.red, weight: FontWeight.w600)),
                ],
                const SizedBox(height: 22),
                if (_twoStep) ..._twoStepActions() else ...[
                  FilledButton.icon(
                    onPressed: _ready ? _continue : null,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Continue'),
                  ),
                  const SizedBox(height: 12),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.lock_outline, size: 15, color: AppColors.muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'You will complete your registration on the next page. '
                        '${widget.registration['after_note'] ?? ''}',
                        style: bodyStyle(12.5),
                      ),
                    ),
                  ]),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  /// Step 1: pay with the event's payment link. Step 2: register.
  List<Widget> _twoStepActions() {
    final payNote = (widget.registration['payment_note'] ??
            'Keep your transaction / reference number. You will enter it in the registration form.')
        .toString();
    Widget step(int n, String title, String note, Widget button, {bool done = false}) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: done ? AppColors.green : AppColors.border),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: done ? AppColors.green : AppColors.primary,
              child: done
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text('$n', style: bodyStyle(13, color: Colors.white, weight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(title, style: bodyStyle(15, color: AppColors.primary, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(note, style: bodyStyle(12.5)),
                const SizedBox(height: 10),
                button,
              ]),
            ),
          ]),
        );

    final payButton = OutlinedButton.icon(
      onPressed: _ready ? _pay : null,
      icon: const Icon(Icons.payments_outlined),
      label: const Text('Pay now'),
    );

    if (_registerFirst) {
      // 1. Register on Zoho Backstage  →  2. Pay with the event payment link
      final payNoteAfter = (widget.registration['payment_note_after'] ??
              'Use the same name and email as your registration, and mention your registration ID in the payment remarks.')
          .toString();
      return [
        step(
          1,
          'Complete your registration',
          'Fill in your details on the registration page. ${widget.registration['after_note'] ?? ''}',
          FilledButton.icon(
            onPressed: _ready
                ? () async {
                    await _continue();
                    if (mounted && _error == null) setState(() => _registered = true);
                  }
                : null,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Continue'),
          ),
          done: _registered,
        ),
        const SizedBox(height: 12),
        step(
          2,
          'Pay the registration fee (${_option!['fee']})',
          payNoteAfter,
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            CheckboxListTile(
              value: _registered,
              onChanged: (v) => setState(() => _registered = v ?? false),
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
              title: Text('I have completed the registration', style: bodyStyle(13.5, color: AppColors.text)),
            ),
            OutlinedButton.icon(
              onPressed: _ready && _registered ? _pay : null,
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Pay now'),
            ),
          ]),
        ),
      ];
    }

    // 1. Pay with the event payment link  →  2. Register on Zoho Backstage.
    // Payment is verified by the organisers in Zoho (registration approval),
    // so the website only guides the order of steps.
    final verifyNote = (widget.registration['verification_note'] ??
            'Your registration will be confirmed by email once the organisers verify your payment.')
        .toString();
    return [
      step(1, 'Pay the registration fee (${_option!['fee']})', payNote, payButton, done: _payOpened),
      const SizedBox(height: 12),
      step(
        2,
        'Complete your registration',
        'Fill in your details and enter your PayU payment reference number. ${widget.registration['after_note'] ?? ''}',
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (!_payOpened)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Click "Pay now" first.', style: bodyStyle(12, color: AppColors.red)),
            ),
          FilledButton.icon(
            onPressed: _ready && _payOpened ? _continue : null,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Continue'),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fade(AppColors.sky, 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(verifyNote, style: bodyStyle(12.5, color: AppColors.text))),
        ]),
      ),
    ];
  }

  Widget _header(bool mobile) => Container(
        color: AppColors.primary,
        padding: EdgeInsets.fromLTRB(mobile ? 18 : 28, 18, 10, 16),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Register for AUTOwn'26", style: displayStyle(mobile ? 19 : 22, color: Colors.white)),
              const SizedBox(height: 2),
              Text('13–14 February 2027 • Pre-event workshops on 12 February',
                  style: bodyStyle(12.5, color: AppColors.peach)),
            ]),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Close',
          ),
        ]),
      );

  /// The three tabs: Competitions / Workshop / Attendee.
  Widget _tabBar(bool mobile) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        for (var i = 0; i < _tabs.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => _selectTab(i),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: mobile ? 10 : 12),
                  decoration: BoxDecoration(
                    color: _tab == i ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(iconFor(_tabs[i]['icon']), size: 20, color: _tab == i ? AppColors.peach : AppColors.primary),
                    const SizedBox(height: 4),
                    Text(_tabs[i]['label'] ?? '',
                        textAlign: TextAlign.center,
                        style: bodyStyle(mobile ? 12.5 : 14,
                            color: _tab == i ? Colors.white : AppColors.primary, weight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
          ),
      ]),
    );
  }

  List<Widget> _dropdowns() {
    final sub = _subBlock;
    return [
      DropdownButtonFormField<String>(
        key: ValueKey('opt-$_tab'),
        value: _optionId,
        isExpanded: true,
        dropdownColor: AppColors.bg,
        decoration: InputDecoration(
          labelText: _tabs[_tab]['prompt'] ?? 'Choose',
          prefixIcon: const Icon(Icons.list_alt_outlined),
        ),
        items: [
          for (final o in _options)
            DropdownMenuItem<String>(
              value: o['id'] as String,
              child: Text(o['label'] ?? '', overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (v) => setState(() {
          _optionId = v;
          _sub = null;
          _error = null;
          _payOpened = false;
          _registered = false;
        }),
      ),
      if (sub != null) ...[
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          key: ValueKey('sub-$_optionId'),
          value: _sub,
          isExpanded: true,
          dropdownColor: AppColors.bg,
          decoration: InputDecoration(
            labelText: sub['label'] ?? 'Choose',
            prefixIcon: const Icon(Icons.alt_route_outlined),
          ),
          items: [
            for (final s in (sub['options'] as List? ?? []))
              DropdownMenuItem<String>(value: s.toString(), child: Text(s.toString(), overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (v) => setState(() => _sub = v),
        ),
      ],
    ];
  }

  Widget _summary() {
    final o = _option!;
    final sub = _subBlock;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fade(AppColors.peach, 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.peach),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(o['label'] ?? '', style: bodyStyle(15.5, color: AppColors.primary, weight: FontWeight.w700)),
        if (sub != null && _sub != null)
          Text('${sub['label']}: $_sub', style: bodyStyle(13.5, color: AppColors.primary)),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.payments_outlined, size: 16, color: AppColors.red),
          const SizedBox(width: 6),
          Expanded(child: Text('Fee: ${o['fee'] ?? 'Shown during registration'}',
              style: bodyStyle(13.5, color: AppColors.text, weight: FontWeight.w600))),
        ]),
        if (sub != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('On the next page, choose the "${o['label']}" ticket and enter your ${sub['label'].toString().toLowerCase()}.',
                style: bodyStyle(12.5)),
          ),
      ]),
    );
  }
}
