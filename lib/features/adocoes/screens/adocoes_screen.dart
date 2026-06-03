import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/adoption_service.dart';
import '../widgets/active_adoption_card.dart';
import '../widgets/adoption_status_sheet.dart';
import '../widgets/past_adoption_card.dart';

class AdocoesScreen extends ConsumerWidget {
  const AdocoesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adoptions = ref.watch(adoptionsProvider);

    return RefreshIndicator(
      color: AppColors.greenCapiba,
      onRefresh: () async {
        ref.invalidate(adoptionsProvider);
        await ref.read(adoptionsProvider.future);
      },
      child: adoptions.when(
        loading: () => const _Loading(),
        error: (_, _) => _ErrorState(
          onRetry: () => ref.invalidate(adoptionsProvider),
        ),
        data: (list) {
          final active = list.where((a) => a.isActive).toList();
          final past = list.where((a) => a.isPast).toList();
          if (list.isEmpty) return const _EmptyState();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
            children: [
              const Text(
                'Acompanhe suas solicitações de adoção.',
                style: TextStyle(fontSize: 14, color: AppColors.textColor),
              ),
              if (active.isNotEmpty) ...[
                const SizedBox(height: 24),
                const _SectionHeader(
                  icon: LucideIcons.loader,
                  title: 'Em andamento',
                ),
                const SizedBox(height: 12),
                for (final p in active) ...[
                  ActiveAdoptionCard(
                    process: p,
                    onDetails: () => showAdoptionStatusSheet(context, p),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
              if (past.isNotEmpty) ...[
                const SizedBox(height: 16),
                const _SectionHeader(
                  icon: LucideIcons.history,
                  title: 'Histórico',
                ),
                const SizedBox(height: 12),
                for (final p in past) ...[
                  PastAdoptionCard(
                    process: p,
                    onDetails: () => showAdoptionStatusSheet(context, p),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.orangeCapiba),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.title,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.foreground,
          ),
        ),
      ],
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        const SizedBox(height: 100),
        Icon(
          LucideIcons.heartHandshake,
          size: 64,
          color: AppColors.orangeCapiba.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nenhuma adoção ainda',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.title,
            fontSize: 20,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Quando você enviar uma solicitação de adoção, ela aparece aqui.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textColor),
        ),
      ],
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
