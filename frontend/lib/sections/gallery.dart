import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';

/// Photo slideshow from the previous AUTOwn. Images live in assets/images/gallery/
/// and are listed under "gallery" in assets/content.json.
class GallerySection extends StatefulWidget {
  const GallerySection({super.key, required this.gallery});
  final Json gallery;

  @override
  State<GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<GallerySection> {
  final _page = PageController();
  Timer? _timer;
  int _index = 0;
  bool _paused = false;

  List<Json> get _images => listOf(widget.gallery['images']);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_paused && _images.length > 1 && _page.hasClients) _go(_index + 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  void _go(int i) {
    final n = _images.length;
    if (n == 0) return;
    final target = (i % n + n) % n;
    _page.animateToPage(target, duration: const Duration(milliseconds: 650), curve: Curves.easeInOutCubic);
  }

  String _path(Json img) => 'assets/images/gallery/${img['file']}';

  @override
  Widget build(BuildContext context) {
    final images = _images;
    if (images.isEmpty) return const SizedBox.shrink();
    final mobile = isMobile(context);

    final stage = MouseRegion(
      onEnter: (_) => _paused = true,
      onExit: (_) => _paused = false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: mobile ? 4 / 3 : 16 / 8,
          child: Stack(fit: StackFit.expand, children: [
            PageView.builder(
              controller: _page,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => Image.asset(
                _path(images[i]),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _MissingPhoto(),
              ),
            ),
            // caption
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 40, 20, mobile ? 14 : 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [fade(AppColors.primary, 0), fade(AppColors.primary, 0.85)],
                    ),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(images[_index]['caption'] ?? '',
                          style: bodyStyle(mobile ? 14 : 16.5, color: Colors.white, weight: FontWeight.w600)),
                    ),
                    Text('${_index + 1} / ${images.length}',
                        style: bodyStyle(13, color: AppColors.peach, weight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
            // arrows
            if (images.length > 1) ...[
              Positioned(left: 12, top: 0, bottom: 0, child: Center(child: _Arrow(Icons.chevron_left, () => _go(_index - 1)))),
              Positioned(right: 12, top: 0, bottom: 0, child: Center(child: _Arrow(Icons.chevron_right, () => _go(_index + 1)))),
            ],
          ]),
        ),
      ),
    );

    return Section(
      dark: true,
      eyebrow: 'Gallery',
      title: widget.gallery['title'] ?? 'Gallery',
      child: Column(children: [
        stage,
        const SizedBox(height: 16),
        // dots
        Wrap(alignment: WrapAlignment.center, spacing: 6, runSpacing: 6, children: [
          for (var i = 0; i < images.length; i++)
            GestureDetector(
              onTap: () => _go(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: i == _index ? 26 : 9,
                height: 9,
                decoration: BoxDecoration(
                  color: i == _index ? AppColors.peach : fade(Colors.white, 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ]),
        // thumbnails (wide screens)
        if (!mobile) ...[
          const SizedBox(height: 18),
          SizedBox(
            height: 74,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _go(i),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 118,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: i == _index ? AppColors.peach : Colors.transparent, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Opacity(
                        opacity: i == _index ? 1 : 0.6,
                        child: Image.asset(
                          _path(images[i]),
                          fit: BoxFit.cover,
                          cacheWidth: 240,
                          errorBuilder: (_, __, ___) => const _MissingPhoto(small: true),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow(this.icon, this.onTap);
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fade(Colors.white, 0.85),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
      ),
    );
  }
}

/// Shown until the photo file is added to assets/images/gallery/.
class _MissingPhoto extends StatelessWidget {
  const _MissingPhoto({this.small = false});
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: small
          ? const Icon(Icons.photo_outlined, color: Colors.white54)
          : Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.photo_library_outlined, color: Colors.white70, size: 48),
              const SizedBox(height: 8),
              Text('Photo coming soon', style: bodyStyle(14, color: Colors.white70)),
            ]),
    );
  }
}
