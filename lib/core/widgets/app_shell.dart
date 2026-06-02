import 'package:flutter/material.dart';

import 'top_header.dart';

class AppShell extends StatefulWidget {
  static const maxWidth = 1200.0;

  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppShell.maxWidth),
                child: TopHeader(
                  searchController: _searchController,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: AppShell.maxWidth),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
