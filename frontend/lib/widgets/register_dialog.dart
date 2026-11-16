import 'package:flutter/material.dart';

import '../api.dart';
import '../sections/contact.dart' show validateEmail;
import '../theme.dart';
import 'common.dart';

Future<void> showRegisterDialog(BuildContext context, {required List<Json> events, String? initialEventId}) {
  return showDialog(
    context: context,
    barrierColor: fade(Colors.black, 0.7),
    builder: (_) => RegisterDialog(events: events.where((e) => e['open'] != false).toList(), initialEventId: initialEventId),
  );
}

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key, required this.events, this.initialEventId});

  final List<Json> events;
  final String? initialEventId;

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _org = TextEditingController();
  final _team = TextEditingController();
  final _msg = TextEditingController();
  late String? _eventId = widget.initialEventId ?? (widget.events.isNotEmpty ? widget.events.first['id'] : null);
  int _teamSize = 2;
  bool _busy = false;
  String? _error;
  Json? _success;

  Json? get _event => widget.events.where((e) => e['id'] == _eventId).firstOrNull;
  bool get _isTeam => (_event?['team'] ?? 'Individual') != 'Individual';

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _org, _team, _msg]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final res = await Api.register({
        'event_id': _eventId,
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'organisation': _org.text.trim().isEmpty ? null : _org.text.trim(),
        'team_name': _isTeam && _team.text.trim().isNotEmpty ? _team.text.trim() : null,
        'team_size': _isTeam ? _teamSize : 1,
        'message': _msg.text.trim().isEmpty ? null : _msg.text.trim(),
      });
      setState(() => _success = res);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile(context);
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: EdgeInsets.all(mobile ? 12 : 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(mobile ? 20 : 32),
          child: _success != null ? _successView() : _formView(),
        ),
      ),
    );
  }

  Widget _successView() => Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.verified_outlined, color: AppColors.green, size: 72),
        const SizedBox(height: 16),
        Text("You're on the grid!", style: displayStyle(24)),
        const SizedBox(height: 10),
        Text(_success!['message'] ?? '', textAlign: TextAlign.center, style: bodyStyle(15)),
        const SizedBox(height: 18),
        Pill('Registration ID: ${_success!['ticket']}', color: AppColors.cyan, icon: Icons.confirmation_number_outlined),
        const SizedBox(height: 24),
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
      ]);

  Widget _formView() => Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: Text('Register', style: displayStyle(24))),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
          Text("AUTOwn'26 • 13–14 Feb 2027", style: bodyStyle(13.5, color: AppColors.cyan)),
          const SizedBox(height: 22),
          DropdownButtonFormField<String>(
            value: _eventId,
            isExpanded: true,
            dropdownColor: AppColors.card,
            decoration: const InputDecoration(labelText: 'Event', prefixIcon: Icon(Icons.flag_outlined)),
            items: [
              for (final e in widget.events)
                DropdownMenuItem(value: e['id'] as String, child: Text(e['title'] ?? '', overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (v) => setState(() => _eventId = v),
            validator: (v) => v == null ? 'Select an event' : null,
          ),
          if (_event != null) ...[
            const SizedBox(height: 8),
            Text('Team: ${_event!['team']}  •  Fee: ${_event!['fee']}', style: bodyStyle(12.5)),
          ],
          const SizedBox(height: 14),
          TextFormField(
            controller: _name,
            decoration: InputDecoration(
                labelText: _isTeam ? 'Team lead name' : 'Full name', prefixIcon: const Icon(Icons.person_outline)),
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
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
            validator: (v) => (v ?? '').replaceAll(RegExp(r'\D'), '').length < 7 ? 'Enter a valid phone number' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _org,
            decoration: const InputDecoration(
                labelText: 'College / Organisation (optional)', prefixIcon: Icon(Icons.apartment_outlined)),
          ),
          if (_isTeam) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _team,
              decoration: const InputDecoration(labelText: 'Team name', prefixIcon: Icon(Icons.groups_outlined)),
              validator: (v) => _isTeam && (v ?? '').trim().isEmpty ? 'Enter a team name' : null,
            ),
            const SizedBox(height: 14),
            Row(children: [
              Text('Team size', style: bodyStyle(14, color: AppColors.text)),
              const Spacer(),
              IconButton(
                onPressed: _teamSize > 1 ? () => setState(() => _teamSize--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$_teamSize', style: displayStyle(18, color: AppColors.cyan)),
              IconButton(
                onPressed: _teamSize < 10 ? () => setState(() => _teamSize++) : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ]),
          ],
          const SizedBox(height: 14),
          TextFormField(
            controller: _msg,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Paper / project title or notes (optional)', alignLabelWithHint: true),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: bodyStyle(13.5, color: AppColors.pink, weight: FontWeight.w600)),
          ],
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit Registration'),
          ),
        ]),
      );
}
