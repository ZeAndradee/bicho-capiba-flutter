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

class FavoriteCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const FavoriteCard({
    super.key,
    required this.animal,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final species = _speciesLabels[animal.especie] ?? animal.especie;
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _image(),
                    Positioned(left: 8, bottom: 8, child: _heartButton()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.nome,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.title,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$species · ${animal.raca}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Widget _heartButton() {
    return GestureDetector(
      onTap: onRemove,
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(Icons.favorite, size: 32, color: AppColors.orangeCapiba),
      ),
    );
  }
}
