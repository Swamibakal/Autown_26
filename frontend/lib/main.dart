import 'package:flutter/material.dart';

import 'api.dart';
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

const navItems = ['Home', 'About', 'Tracks', 'Events', 'Speakers', 'Schedule', 'Sponsors', 'FAQ', 'Contact'];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Json> _site = Api.fetchSite();
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
    void register([String? id]) => showRegisterDialog(context, events: events, initialEventId: id);

    Widget anchor(String id, Widget child) => KeyedSubtree(key: _keys[id], child: child);

    return Scaffold(
      key: _scaffold,
      endDrawer: _drawer(register),
      body: Stack(children: [
        SingleChildScrollView(
          controller: _scroll,
          child: Column(children: [
            anchor('Home', HeroSection(event: event, onRegister: register, onExplore: () => _goTo('Events'))),
            anchor('About', VisionSection(vision: site['vision'], event: event, trackCount: listOf(site['tracks']).length)),
            anchor('Tracks', TracksSection(tracks: listOf(site['tracks']))),
            anchor('Events', EventsSection(events: events, prizePool: event['prize_pool'] ?? '', onRegister: register)),
            anchor('Speakers', SpeakersSection(speakers: listOf(site['speakers']))),
            anchor('Schedule', ScheduleSection(days: listOf(site['schedule']))),
            anchor('Sponsors', SponsorshipSection(data: site['sponsorship'], onContact: () => _goTo('Contact'))),
            anchor('FAQ', FaqSection(faqs: listOf(site['faqs']))),
            anchor('Contact', ContactSection(coordinators: listOf(site['coordinators']), venue: site['venue'], event: event)),
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
        color: _scrolled ? fade(AppColors.bg, 0.92) : Colors.transparent,
        border: Border(bottom: BorderSide(color: _scrolled ? AppColors.border : Colors.transparent)),
      ),
      child: Row(children: [
               WilpLogo(height: mobile ? 40 : 52),
        Container(width: 1, height: 28, margin: const EdgeInsets.symmetric(horizontal: 14), color: AppColors.border),
        InkWell(
          onTap: () => _goTo('Home'),
          child: GradientText("AUTOwn'26", style: displayStyle(20)),
        ),
        const Spacer(),
        if (!mobile)
          for (final n in navItems.skip(1))
            TextButton(
              onPressed: () => _goTo(n),
              child: Text(n, style: bodyStyle(14.5, color: AppColors.text, weight: FontWeight.w500)),
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
            icon: const Icon(Icons.menu_rounded, color: AppColors.text),
          ),
      ]),
    );
  }

  Widget _drawer(void Function([String?]) register) => Drawer(
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            GradientText("AUTOwn'26", style: displayStyle(22)),
            const SizedBox(height: 20),
            for (final n in navItems)
              ListTile(
                title: Text(n, style: bodyStyle(16, color: AppColors.text, weight: FontWeight.w500)),
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
            GradientText("AUTOwn'26", style: displayStyle(40)),
            const SizedBox(height: 24),
            const SizedBox(width: 160, child: LinearProgressIndicator(color: AppColors.cyan, backgroundColor: AppColors.border)),
          ]),
        ),
      );

  Widget _errorView(String msg) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.cloud_off_outlined, size: 56, color: AppColors.pink),
              const SizedBox(height: 16),
              Text('Could not reach the AUTOwn\'26 server', style: bodyStyle(18, color: AppColors.text, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Make sure the Python backend is running (uvicorn main:app --port 8000).\n$msg',
                  textAlign: TextAlign.center, style: bodyStyle(14)),
              const SizedBox(height: 20),
              FilledButton(onPressed: () => setState(() {
                  _site = Api.fetchSite();
                }), child: const Text('Retry')),
            ]),
          ),
        ),
      );
}
