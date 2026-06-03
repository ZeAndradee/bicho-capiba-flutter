import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

const _announcements = <String>[
  'assets/images/anouncements/vaccineBanner1.png',
  'assets/images/anouncements/vaccineBanner2.png',
];

class AnnouncementCarousel extends StatefulWidget {
  const AnnouncementCarousel({super.key});

  @override
  State<AnnouncementCarousel> createState() => _AnnouncementCarouselState();
}

class _AnnouncementCarouselState extends State<AnnouncementCarousel> {
  static const _viewport = 1.0;
  static const _gap = 6.0;
  static const _topMargin = 6.0;
  static const _dotsArea = 24.0;
  static const _aspect = 2032 / 603;

  final _controller = PageController(viewportFraction: _viewport);
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bannerWidth = constraints.maxWidth * _viewport - _gap * 2;
        final bannerHeight = bannerWidth / _aspect;
        final totalHeight = _topMargin + bannerHeight + _dotsArea;

        return SizedBox(
          height: totalHeight,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _topMargin + bannerHeight * 0.8,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.orangeCapiba, AppColors.background],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _topMargin,
                left: 0,
                right: 0,
                height: bannerHeight,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _announcements.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _gap),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(_announcements[i], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_announcements.length, (i) {
                    final isActive = i == _current;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.orangeCapiba
                            : AppColors.orangeCapiba.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
