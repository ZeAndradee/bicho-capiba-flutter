import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../models/adoption_process.dart';
import 'adoption_card_shared.dart';

class PastAdoptionCard extends StatelessWidget {
  final AdoptionProcess process;
  final VoidCallback onDetails;

  const PastAdoptionCard({
    super.key,
    required this.process,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final animal = process.animal;
    return GestureDetector(
      onTap: onDetails,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 84,
              height: 84,
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
                child: AdoptionAnimalImage(url: animal.imageUrl),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        animal.nome,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFonts.title,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                    if (process.status == AdoptionStatus.rejeitado) ...[
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.xCircle,
                        size: 22,
                        color: process.statusColor,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                adoptionMetaRow(animal),
                const SizedBox(height: 8),
                Text(
                  formatAdoptionDate(process.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
