import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/animal.dart';
import '../../../services/animal_service.dart';
import '../../../services/user_service.dart';
import '../widgets/favorite_card.dart';
import '../widgets/remove_favorite_sheet.dart';

class FavoritosScreen extends ConsumerWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return RefreshIndicator(
      color: AppColors.greenCapiba,
      onRefresh: () async {
        ref.invalidate(favoritesProvider);
        await ref.read(favoritesProvider.future);
      },
      child: favorites.when(
        loading: () => const _Loading(),
        error: (_, _) =>
            _ErrorState(onRetry: () => ref.invalidate(favoritesProvider)),
        data: (list) => _FavoritesView(initial: list),
      ),
    );
  }
}

class _FavoritesView extends ConsumerStatefulWidget {
  final List<Animal> initial;

  const _FavoritesView({required this.initial});

  @override
  ConsumerState<_FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends ConsumerState<_FavoritesView> {
  late final List<Animal> _animals = List.of(widget.initial);

  Future<void> _remove(Animal animal) async {
    final removed = await showRemoveFavoriteSheet(
      context: context,
      animal: animal,
      onConfirm: () => ref.read(animalServiceProvider).unlikeAnimal(animal.id),
    );
    if (removed == true && mounted) {
      setState(() => _animals.removeWhere((a) => a.id == animal.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
          sliver: SliverToBoxAdapter(child: _Header()),
        ),
        if (_animals.isEmpty)
          const SliverFillRemaining(hasScrollBody: false, child: _EmptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate((context, i) {
                final a = _animals[i];
                return FavoriteCard(
                  animal: a,
                  onRemove: () => _remove(a),
                  onTap: () => context.push('/animal/${a.id}'),
                );
              }, childCount: _animals.length),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Seus animais preferidos estão aqui.',
        style: TextStyle(fontSize: 14, color: AppColors.textColor),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Center(child: CircularProgressIndicator(color: AppColors.greenCapiba)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.heart,
            size: 64,
            color: AppColors.orangeCapiba.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum animal favoritado ainda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.title,
              fontSize: 20,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quando encontrar um amigo especial, toque no coração para salvá-lo aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textColor),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        const SizedBox(height: 100),
        Icon(
          LucideIcons.cloudOff,
          size: 56,
          color: AppColors.orangeCapiba.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 16),
        const Text(
          'Não foi possível carregar',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.title,
            fontSize: 20,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Verifique sua conexão e tente novamente.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textColor),
        ),
        const SizedBox(height: 20),
        Center(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            label: const Text('Tentar novamente'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.orangeCapiba,
              side: const BorderSide(color: AppColors.orangeCapiba),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
