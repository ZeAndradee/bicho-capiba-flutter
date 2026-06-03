import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/animal.dart';

const _speciesLabels = <String, String>{
  'dog': 'Cachorro',
  'cat': 'Gato',
  'horse': 'Cavalo',
  'bird': 'Pássaro',
  'rabbit': 'Coelho',
  'rat': 'Roedor',
};

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onTap;

  const AnimalCard({
    super.key,
    required this.animal,
    required this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _imageBlock(),
            const SizedBox(height: 10),
            _nameRow(),
            const SizedBox(height: 5),
            _metaRow(),
            const SizedBox(height: 4),
            _ongRow(),
          ],
        ),
      ),
    );
  }

  Widget _imageBlock() {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(aspectRatio: 16 / 8, child: _image()),
      ),
    );
  }

  Widget _image() {
    if (animal.imageAsset != null) {
      return Image.asset(animal.imageAsset!, fit: BoxFit.cover);
    }
    if (animal.imageUrl != null) {
      return Image.network(
        animal.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    color: AppColors.backgroundSecondary,
    child: const Icon(LucideIcons.dog, size: 48, color: AppColors.skeletonBase),
  );

  Widget _nameRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    animal.nome,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppFonts.title,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    animal.idade,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _favoriteButton(),
      ],
    );
  }

  Widget _favoriteButton() {
    return GestureDetector(
      onTap: onFavoriteToggle,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        animal.isLiked ? Icons.favorite : Icons.favorite_border,
        size: 26,
        color: animal.isLiked ? AppColors.orangeCapiba : AppColors.textColor,
      ),
    );
  }

  Widget _metaRow() {
    final isMale = animal.sexo == 'M';
    final species = _speciesLabels[animal.especie] ?? animal.especie;
    return Row(
      children: [
        Flexible(
          child: Text(
            '$species · ${animal.raca}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          isMale ? Icons.male : Icons.female,
          size: 18,
          color: AppColors.orangeCapiba,
        ),
      ],
    );
  }

  Widget _ongRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            animal.ongNome ?? 'ONG não informada',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, color: AppColors.textColor),
          ),
        ),
        const SizedBox(width: 8),
        Icon(LucideIcons.mapPin, size: 14, color: AppColors.orangeCapiba),
        const SizedBox(width: 3),
        Text(
          animal.distancia,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }
}
