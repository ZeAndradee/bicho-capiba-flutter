import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/animal.dart';
import '../models/adoption_process.dart';

const _speciesLabels = <String, String>{
  'dog': 'Cachorro',
  'cat': 'Gato',
  'horse': 'Cavalo',
  'bird': 'Pássaro',
  'rabbit': 'Coelho',
  'rat': 'Roedor',
  'snake': 'Cobra',
};

const _months = [
  'jan',
  'fev',
  'mar',
  'abr',
  'mai',
  'jun',
  'jul',
  'ago',
  'set',
  'out',
  'nov',
  'dez',
];

String formatAdoptionDate(DateTime? date) {
  if (date == null) return '—';
  return '${date.day.toString().padLeft(2, '0')} ${_months[date.month - 1]} ${date.year}';
}

class AdoptionAnimalImage extends StatelessWidget {
  final String? url;

  const AdoptionAnimalImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return Image.network(
        url!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    width: double.infinity,
    height: double.infinity,
    color: AppColors.backgroundSecondary,
    child: const Center(
      child: Icon(LucideIcons.dog, size: 40, color: AppColors.skeletonBase),
    ),
  );
}

Widget adoptionMetaRow(Animal animal) {
  final isMale = animal.sexo == 'M';
  final species = _speciesLabels[animal.especie] ?? animal.especie;
  return Row(
    children: [
      Flexible(
        child: Text(
          '$species · ${animal.raca}',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.foreground,
          ),
        ),
      ),
      const SizedBox(width: 4),
      Icon(
        isMale ? Icons.male : Icons.female,
        size: 17,
        color: AppColors.orangeCapiba,
      ),
    ],
  );
}

class StatusChip extends StatelessWidget {
  final AdoptionProcess process;

  const StatusChip({super.key, required this.process});

  @override
  Widget build(BuildContext context) {
    final color = process.statusColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            process.statusLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
