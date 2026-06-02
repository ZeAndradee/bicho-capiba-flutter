import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';

class PhotoGallery extends StatefulWidget {
  final List<String> photos;

  const PhotoGallery({super.key, required this.photos});

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photos.isEmpty)
            _placeholder()
          else
            PageView.builder(
              controller: _controller,
              itemCount: photos.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => Image.network(
                photos[i],
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _loading(),
              ),
            ),
          if (photos.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < photos.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _index ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.backgroundSecondary,
        child: const Icon(LucideIcons.dog, size: 72, color: AppColors.skeletonBase),
      );

  Widget _loading() => Container(
        color: AppColors.backgroundSecondary,
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
}
