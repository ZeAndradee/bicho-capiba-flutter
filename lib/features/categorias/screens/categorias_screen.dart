import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../adote/screens/adote_screen.dart';

class _Category {
  final String title;
  final String especie;
  final String image;
  final List<Color> gradient;
  final double imageSize;
  final double imageBottom;

  const _Category(
    this.title,
    this.especie,
    this.image,
    this.gradient, {
    this.imageSize = 140,
    this.imageBottom = -8,
  });
}

const _categories = <_Category>[
  _Category('Cachorros', 'dog', 'assets/images/DogFilter.png', [
    Color(0xFFFFEADD),
    Color(0xFFFFD3BC),
  ], imageSize: 160),
  _Category('Gatos', 'cat', 'assets/images/CatFilter.png', [
    Color(0xFFE5F0E8),
    Color(0xFFC7E0D1),
  ], imageSize: 160),
  _Category(
    'Coelhos',
    'rabbit',
    'assets/images/RabbitFilter.png',
    [Color(0xFFFBE5EC), Color(0xFFF5CCDC)],
    imageSize: 190,
    imageBottom: -30,
  ),
  _Category('Roedores', 'rat', 'assets/images/RatFilter.png', [
    Color(0xFFEDEAF5),
    Color(0xFFD8D1EA),
  ]),
  _Category(
    'Cavalos',
    'horse',
    'assets/images/HorseFilter.png',
    [Color(0xFFFCEFD8), Color(0xFFF5DBAE)],
    imageSize: 190,
    imageBottom: -18,
  ),
  _Category(
    'Cobras',
    'snake',
    'assets/images/SnakeFilter.png',
    [Color(0xFFDFF1EE), Color(0xFFBCE2DC)],
    imageSize: 176,
    imageBottom: -18,
  ),
];

class CategoriasScreen extends StatelessWidget {
  const CategoriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, i) => _CategoryCard(category: _categories[i]),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  final _Category category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        ref.read(adoteEspecieProvider.notifier).state = category.especie;
        context.go('/adote');
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: category.gradient,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              bottom: category.imageBottom,
              child: Image.asset(
                category.image,
                width: category.imageSize,
                height: category.imageSize,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                category.title,
                style: const TextStyle(
                  fontFamily: AppFonts.title,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
