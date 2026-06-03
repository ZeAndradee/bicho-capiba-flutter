import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../services/location_service.dart';
import '../theme/app_theme.dart';
import 'app_nav_bar.dart';
import 'top_header.dart';

class AppShell extends ConsumerStatefulWidget {
  static const maxWidth = 1200.0;

  static const _items = [
    AppNavBarItem(icon: LucideIcons.home, label: 'Home'),
    AppNavBarItem(icon: LucideIcons.layoutGrid, label: 'Categorias'),
    AppNavBarItem(icon: LucideIcons.heartHandshake, label: 'Adoções'),
    AppNavBarItem(icon: LucideIcons.heart, label: 'Favoritos'),
    AppNavBarItem(icon: LucideIcons.userCircle2, label: 'Perfil'),
  ];

  static const _titles = [null, 'Categorias', 'Adoções', 'Favoritos', 'Perfil'];

  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _searchController = TextEditingController();

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  bool _onScroll(UserScrollNotification notification) {
    final direction = notification.direction;
    if (direction == ScrollDirection.idle) return false;
    final visible = direction == ScrollDirection.forward;
    final notifier = ref.read(headerLocationVisibleProvider.notifier);
    if (notifier.state != visible) notifier.state = visible;
    return false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/adote');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(userLocationProvider);

    final title = AppShell._titles[widget.navigationShell.currentIndex];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: AppColors.orangeCapiba,
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: AppShell.maxWidth),
                    child: TopHeader(
                      searchController: title == null ? _searchController : null,
                      title: title,
                      onBack: _onBack,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: NotificationListener<UserScrollNotification>(
                onNotification: _onScroll,
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: AppShell.maxWidth),
                    child: widget.navigationShell,
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppNavBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: _onTap,
          items: AppShell._items,
        ),
      ),
    );
  }
}
