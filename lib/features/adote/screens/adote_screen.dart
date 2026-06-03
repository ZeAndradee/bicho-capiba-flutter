import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/announcement_carousel.dart';
import '../widgets/close_animals_feed.dart';
import '../widgets/filter_carousel.dart';

final adoteEspecieProvider = StateProvider<String>((ref) => '');

class AdoteScreen extends ConsumerStatefulWidget {
  const AdoteScreen({super.key});

  @override
  ConsumerState<AdoteScreen> createState() => _AdoteScreenState();
}

class _AdoteScreenState extends ConsumerState<AdoteScreen> {
  final _scrollController = ScrollController();
  final _feedKey = GlobalKey<CloseAnimalsFeedState>();

  void _setEspecie(String v) =>
      ref.read(adoteEspecieProvider.notifier).state = v;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final especie = ref.watch(adoteEspecieProvider);
    return RefreshIndicator(
      color: AppColors.greenCapiba,
      onRefresh: () async => _feedKey.currentState?.reload(),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AnnouncementCarousel(),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderColor),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 20, 0, 8),
              child: FilterCarousel(
                selectedEspecie: especie,
                onSelect: _setEspecie,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
              child: CloseAnimalsFeed(
                key: _feedKey,
                especie: especie,
                onEspecieChange: _setEspecie,
                scrollController: _scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
