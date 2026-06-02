import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_theme.dart';

class TopHeader extends StatelessWidget {
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onNotificationsTap;
  final int notificationCount;
  final String searchPlaceholder;

  const TopHeader({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onNotificationsTap,
    this.notificationCount = 0,
    this.searchPlaceholder = 'Buscar...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SearchBar(
              controller: searchController,
              placeholder: searchPlaceholder,
              onChanged: onSearchChanged,
              onSubmitted: onSearchSubmitted,
            ),
          ),
          const SizedBox(width: 12),
          _NotificationButton(
            count: notificationCount,
            onTap: onNotificationsTap,
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const _SearchBar({
    required this.controller,
    required this.placeholder,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.search, size: 20, color: AppColors.textColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 15, color: AppColors.foreground),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _NotificationButton({required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(LucideIcons.bell, size: 22, color: AppColors.foreground),
            if (count > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(minWidth: 16),
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.orangeCapiba,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.background, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
