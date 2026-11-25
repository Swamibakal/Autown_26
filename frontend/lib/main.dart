import 'package:flutter/material.dart';

import 'content.dart';
import 'sections/contact.dart';
import 'sections/events.dart';
import 'sections/hero.dart';
import 'sections/info_sections.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/register_dialog.dart';

void main() => runApp(const AutownApp());

class AutownApp extends StatelessWidget {
  const AutownApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "AUTOwn'26 | BITS Pilani WILP",
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomePage(),
    );
  }
}

const navItems = ['Home', 'About', 'Tracks', 'Events', 'Schedule', 'Speakers', 'Sponsors', 'Contact', 'FAQ'];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Json> _site = loadSiteContent();
  final _scaffold = GlobalKey<ScaffoldState>();
  final _scroll = ScrollController();
  final Map<String, GlobalKey> _keys = {for (final n in navItems) n: GlobalKey()};
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final s = _scroll.offset > 40;
      if (s != _scrolled) setState(() => _scrolled = s);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _goTo(String id) {
    final ctx = _keys[id]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Json>(
      future: _site,
      builder: (context, snap) {
        if (snap.hasError) return _errorView(snap.error.toString());
        if (!snap.hasData) return _loadingView();
        return _page(snap.data!);
      },
    );
  }

  Widget _page(Json site) {
    final event = site['event'] as Json;
    final events = listOf(site['events']);
    final registration = (site['registration'] ?? <String, dynamic>{}) as Json;
    void register([String? id]) => showRegisterDialog(context, registration: registration, optionId: id);

    Widget anchor(String id, Widget child) => KeyedSubtree(key: _keys[id], child: child);

    return Scaffold(
      key: _scaffold,
      endDrawer: _drawer(register),
      body: Stack(children: [
        SingleChildScrollView(
          controller: _scroll,
          child: Column(children: [
            anchor('Home', HeroSection(event: event, onRegister: register, onExplore: () => _goTo('Events'))),
            anchor('About', AboutSection(about: site['about'] ?? <String, dynamic>{}, event: event, trackCount: listOf(site['tracks']).length)),
            VisionSection(vision: site['vision']),
            anchor('Tracks', TracksSection(tracks: listOf(site['tracks']))),
            anchor('Events', EventsSection(
              events: events,
              fees: listOf(site['fees']),
              prizePool: event['prize_pool'] ?? '',
              onRegister: register,
            )),
            anchor('Schedule', ScheduleSection(days: listOf(site['schedule']))),
            anchor('Speakers', SpeakersSection(speakers: listOf(site['speakers']))),
            anchor('Sponsors', SponsorshipSection(data: site['sponsorship'], onContact: () => _goTo('Contact'))),
            anchor('Contact', ContactSection(
              coordinators: listOf(site['coordinators']),
              venue: site['venue'],
              event: event,
              afterNote: (registration['after_note'] ?? '').toString(),
            )),
            anchor('FAQ', FaqSection(faqs: listOf(site['faqs']))),
            Footer(event: event, onNav: _goTo, navItems: navItems),
          ]),
        ),
        Positioned(top: 0, left: 0, right: 0, child: _navBar(register)),
      ]),
    );
  }

  Widget _navBar(void Function([String?]) register) {
    final mobile = MediaQuery.sizeOf(context).width < 1100;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 36, vertical: _scrolled ? 10 : 18),
      decoration: BoxDecoration(
        color: _scrolled ? fade(AppColors.bg, 0.96) : Colors.transparent,
        border: Border(bottom: BorderSide(color: _scrolled ? AppColors.border : Colors.transparent)),
        boxShadow: [if (_scrolled) BoxShadow(color: fade(AppColors.primary, 0.08), blurRadius: 16)],
      ),
      child: Row(children: [
        WilpLogo(height: mobile ? 36 : 46),
        Container(width: 1, height: 30, margin: const EdgeInsets.symmetric(horizontal: 14), color: AppColors.border),
        InkWell(
          onTap: () => _goTo('Home'),
          child: AutownLogo(height: mobile ? 30 : 38),
        ),
        const Spacer(),
        if (!mobile)
          for (final n in navItems.skip(1))
            TextButton(
              onPressed: () => _goTo(n),
              child: Text(n, style: bodyStyle(14.5, color: AppColors.primary, weight: FontWeight.w600)),
            ),
        const SizedBox(width: 12),
        if (!mobile)
          FilledButton(
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
            onPressed: register,
            child: const Text('Register'),
          )
        else
          IconButton(
            onPressed: () => _scaffold.currentState?.openEndDrawer(),
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
          ),
      ]),
    );
  }

  Widget _drawer(void Function([String?]) register) => Drawer(
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            const Align(alignment: Alignment.centerLeft, child: WilpLogo(height: 44)),
            const SizedBox(height: 14),
            const Align(alignment: Alignment.centerLeft, child: AutownLogo(height: 40)),
            const SizedBox(height: 10),
            const BrandStripe(),
            const SizedBox(height: 12),
            for (final n in navItems)
              ListTile(
                title: Text(n, style: bodyStyle(16, color: AppColors.primary, weight: FontWeight.w600)),
                onTap: () {
                  _scaffold.currentState?.closeEndDrawer();
                  Future.delayed(const Duration(milliseconds: 250), () => _goTo(n));
                },
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                _scaffold.currentState?.closeEndDrawer();
                register();
              },
              child: const Text('Register Now'),
            ),
          ]),
        ),
      );

  Widget _loadingView() => Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const AutownLogo(height: 80),
            const SizedBox(height: 24),
            const SizedBox(width: 160, child: LinearProgressIndicator(color: AppColors.red, backgroundColor: AppColors.border)),
          ]),
        ),
      );

  Widget _errorView(String msg) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 56, color: AppColors.red),
              const SizedBox(height: 16),
              Text("Could not load the AUTOwn'26 page", style: bodyStyle(18, color: AppColors.text, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Please refresh the page. If you edited assets/content.json, check it is valid JSON.\n$msg',
                  textAlign: TextAlign.center, style: bodyStyle(14)),
              const SizedBox(height: 20),
              FilledButton(onPressed: () => setState(() {
                  _site = loadSiteContent();
                }), child: const Text('Retry')),
            ]),
          ),
        ),
      );
}
