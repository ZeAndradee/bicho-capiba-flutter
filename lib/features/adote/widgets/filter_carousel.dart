import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';

class _FilterCard {
  final String title;
  final String especie;
  final String imageAsset;
  const _FilterCard(this.title, this.especie, this.imageAsset);
}

const _filters = <_FilterCard>[
  _FilterCard('Gatos', 'cat', 'assets/images/CatFilter.png'),
  _FilterCard('Cachorros', 'dog', 'assets/images/DogFilter.png'),
  _FilterCard('Coelhos', 'rabbit', 'assets/images/RabbitFilter.png'),
  _FilterCard('Roedores', 'rat', 'assets/images/RatFilter.png'),
];

class FilterCarousel extends StatelessWidget {
  final String selectedEspecie;
  final ValueChanged<String> onSelect;

  const FilterCarousel({
    super.key,
    required this.selectedEspecie,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          if (i == 0) return _allCard();
          return _card(_filters[i - 1]);
        },
      ),
    );
  }

  Widget _allCard() {
    final isActive = selectedEspecie.isEmpty;
    return _pill(
      isActive: isActive,
      onTap: () => onSelect(''),
      title: 'Todos',
      leading: Icon(
        LucideIcons.dog,
        size: 38,
        color: isActive ? AppColors.orangeCapiba : AppColors.textColor,
      ),
    );
  }

  Widget _card(_FilterCard filter) {
    final isActive = selectedEspecie == filter.especie;
    return _pill(
      isActive: isActive,
      onTap: () => onSelect(isActive ? '' : filter.especie),
      title: filter.title,
      leading: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.asset(filter.imageAsset, fit: BoxFit.contain),
      ),
    );
  }

  Widget _pill({
    required bool isActive,
    required VoidCallback onTap,
    required String title,
    required Widget leading,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? AppColors.orangeCapiba : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(child: leading),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.orangeCapiba : AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
