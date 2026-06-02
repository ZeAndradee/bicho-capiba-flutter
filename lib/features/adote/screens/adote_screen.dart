import 'package:flutter/material.dart';

import '../widgets/close_animals_feed.dart';
import '../widgets/filter_carousel.dart';

class AdoteScreen extends StatefulWidget {
  const AdoteScreen({super.key});

  @override
  State<AdoteScreen> createState() => _AdoteScreenState();
}

class _AdoteScreenState extends State<AdoteScreen> {
  final _scrollController = ScrollController();
  String _especie = '';

  void _setEspecie(String v) => setState(() => _especie = v);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 0, 8),
            child: FilterCarousel(
              selectedEspecie: _especie,
              onSelect: _setEspecie,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
            child: CloseAnimalsFeed(
              especie: _especie,
              onEspecieChange: _setEspecie,
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }
}
