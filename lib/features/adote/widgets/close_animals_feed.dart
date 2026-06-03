import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/animal.dart';
import '../../../services/animal_service.dart';
import 'animal_card.dart';

class CloseAnimalsFeed extends ConsumerStatefulWidget {
  final String especie;
  final ValueChanged<String> onEspecieChange;
  final ScrollController scrollController;

  const CloseAnimalsFeed({
    super.key,
    required this.especie,
    required this.onEspecieChange,
    required this.scrollController,
  });

  @override
  ConsumerState<CloseAnimalsFeed> createState() => CloseAnimalsFeedState();
}

class CloseAnimalsFeedState extends ConsumerState<CloseAnimalsFeed> {
  final List<Animal> _animals = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;

  String _idade = '';
  String _sexo = '';
  String _distance = '';

  bool get _hasActiveFilters =>
      _idade.isNotEmpty ||
      _sexo.isNotEmpty ||
      _distance.isNotEmpty ||
      widget.especie.isNotEmpty;

  List<Animal> get _filtered => _animals.where((a) {
        if (_idade.isNotEmpty && a.idade != _idade.replaceAll(' anos', '')) {
          return false;
        }
        if (_sexo.isNotEmpty && a.sexo != _sexo) return false;
        if (_distance.isNotEmpty) return false;
        if (widget.especie.isNotEmpty && a.especie != widget.especie) {
          return false;
        }
        return true;
      }).toList();

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    _loadAnimals(page: 1, reset: true);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final c = widget.scrollController;
    if (!c.hasClients) return;
    if (c.position.pixels >= c.position.maxScrollExtent - 400) {
      if (!_loadingMore && !_loading && _hasMoreData) {
        _loadAnimals(page: _currentPage + 1, reset: false);
      }
    }
  }

  Future<void> _loadAnimals({required int page, required bool reset}) async {
    setState(() {
      if (page == 1) {
        _loading = true;
      } else {
        _loadingMore = true;
      }
    });

    try {
      final result =
          await ref.read(animalServiceProvider).fetchAnimals(page: page);
      if (!mounted) return;
      setState(() {
        if (reset) {
          _animals
            ..clear()
            ..addAll(result.animals);
        } else {
          _animals.addAll(result.animals);
        }
        _currentPage = page;
        _hasMoreData = result.hasMore;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _hasMoreData = false);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _idade = '';
      _sexo = '';
      _distance = '';
      _currentPage = 1;
    });
    widget.onEspecieChange('');
    _loadAnimals(page: 1, reset: true);
  }

  Future<void> _toggleFavorite(Animal animal) async {
    final service = ref.read(animalServiceProvider);
    final liked = animal.isLiked;
    setState(() {
      final i = _animals.indexWhere((a) => a.id == animal.id);
      if (i != -1) _animals[i] = _animals[i].copyWith(isLiked: !liked);
    });
    try {
      if (liked) {
        await service.unlikeAnimal(animal.id);
      } else {
        await service.likeAnimal(animal.id);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final i = _animals.indexWhere((a) => a.id == animal.id);
        if (i != -1) _animals[i] = _animals[i].copyWith(isLiked: liked);
      });
    }
  }

  Future<void> reload() => _loadAnimals(page: 1, reset: true);

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          _resultsRow(filtered.length),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            _noResults()
          else
            _grid(filtered),
          if (_loadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ],
    );
  }

  Widget _resultsRow(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            '$count ${count == 1 ? 'animal encontrado' : 'animais encontrados'}'
            '${_hasActiveFilters ? ' com esses filtros' : ''}',
            style: const TextStyle(fontSize: 15, color: AppColors.textColor),
          ),
        ),
        if (_hasActiveFilters) _resetButton(),
      ],
    );
  }

  Widget _resetButton() {
    return TextButton(
      onPressed: _reset,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.orangeCapiba,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      child: const Text('Limpar filtros'),
    );
  }

  Widget _grid(List<Animal> animals) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minWidth = 280.0;
        const spacing = 40.0;
        final cols =
            (constraints.maxWidth / (minWidth + spacing)).floor().clamp(1, 4);
        final cardWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final a in animals)
              SizedBox(
                width: cardWidth,
                child: AnimalCard(
                  animal: a,
                  onFavoriteToggle: () => _toggleFavorite(a),
                  onTap: () => context.push('/animal/${a.id}'),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _noResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(LucideIcons.dog,
              size: 64, color: AppColors.orangeCapiba.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Nenhum animal encontrado',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: AppFonts.title,
                  color: AppColors.textColor,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Não foram encontrados animais com os filtros selecionados.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textColor),
          ),
          const SizedBox(height: 16),
          _resetButton(),
        ],
      ),
    );
  }
}
