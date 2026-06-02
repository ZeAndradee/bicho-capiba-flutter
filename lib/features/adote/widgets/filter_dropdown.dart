import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';

class FilterOption {
  final String value;
  final String label;
  final IconData? icon;

  const FilterOption({required this.value, required this.label, this.icon});
}

class FilterDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final List<FilterOption> options;
  final String placeholder;

  const FilterDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.options,
    this.placeholder = 'Selecione...',
  });

  @override
  Widget build(BuildContext context) {
    FilterOption? selected;
    for (final o in options) {
      if (o.value == value) {
        selected = o;
        break;
      }
    }
    final displayText = selected?.label ?? placeholder;

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 52),
      constraints: const BoxConstraints(minWidth: 200),
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      onSelected: onChanged,
      itemBuilder: (context) => [
        _item('', placeholder, null),
        ...options.map((o) => _item(o.value, o.label, o.icon)),
      ],
      child: Container(
        constraints: const BoxConstraints(minWidth: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected?.icon != null) ...[
              Icon(selected!.icon, size: 20, color: AppColors.orangeCapiba),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                displayText,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronDown,
                size: 22, color: AppColors.textColor),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _item(String val, String label, IconData? icon) {
    final isSelected = val == value;
    return PopupMenuItem<String>(
      value: val,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.orangeCapiba),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                color: isSelected ? AppColors.orangeCapiba : AppColors.textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (isSelected)
            const Icon(LucideIcons.check, size: 18, color: AppColors.orangeCapiba),
        ],
      ),
    );
  }
}
