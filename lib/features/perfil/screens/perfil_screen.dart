import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_controller.dart';
import '../widgets/address_info_sheet.dart';
import '../widgets/adoption_info_sheet.dart';
import '../widgets/personal_info_sheet.dart';
import '../widgets/settings_sheet.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  bool _loading = false;
  bool _failed = false;
  bool _attempted = false;

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      await ref.read(authControllerProvider.notifier).refreshUser();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(BuildContext context, WidgetBuilder builder) async {
    final saved = await showSettingsSheet(context: context, builder: builder);
    if (saved == true && context.mounted) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informações atualizadas com sucesso.'),
          backgroundColor: AppColors.greenCapiba,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    if (user == null) {
      final busy = _loading || authState.status == AuthStatus.loading;
      if (!busy &&
          !_attempted &&
          authState.status == AuthStatus.unauthenticated) {
        _attempted = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _load());
      }
      if (busy) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.greenCapiba),
        );
      }
      return _SignedOutView(
        failed: _failed,
        onRetry: _load,
        onLogin: () => context.go('/entrar'),
      );
    }

    return RefreshIndicator(
      color: AppColors.greenCapiba,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
        children: [
          _ProfileHeader(name: user.displayName, email: user.email),
          const SizedBox(height: 28),
          const Text(
            'Configurações',
            style: TextStyle(
              fontFamily: AppFonts.title,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mantenha suas informações sempre atualizadas.',
            style: TextStyle(fontSize: 14, color: AppColors.textColor),
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: LucideIcons.user,
            color: AppColors.greenCapiba,
            title: 'Informações pessoais',
            subtitle: 'Nome, nascimento e contato',
            onTap: () => _open(context, (_) => PersonalInfoSheet(user: user)),
          ),
          const SizedBox(height: 4),
          _SettingsTile(
            icon: LucideIcons.mapPin,
            color: AppColors.orangeCapiba,
            title: 'Endereço',
            subtitle: 'Onde você mora',
            onTap: () => _open(context, (_) => AddressInfoSheet(user: user)),
          ),
          const SizedBox(height: 4),
          _SettingsTile(
            icon: LucideIcons.heart,
            color: AppColors.yellowCapiba,
            title: 'Informações de adoção',
            subtitle: 'Seu perfil de adotante',
            onTap: () => _open(context, (_) => AdoptionInfoSheet(user: user)),
          ),
          const SizedBox(height: 28),
          _LogoutButton(
            onTap: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/welcome');
            },
          ),
        ],
      ),
    );
  }
}

class _SignedOutView extends StatelessWidget {
  final bool failed;
  final VoidCallback onRetry;
  final VoidCallback onLogin;

  const _SignedOutView({
    required this.failed,
    required this.onRetry,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              failed ? LucideIcons.cloudOff : LucideIcons.userCircle2,
              size: 56,
              color: AppColors.orangeCapiba.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              failed ? 'Não foi possível carregar' : 'Você não está conectado',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.title,
                fontSize: 20,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              failed
                  ? 'Verifique sua conexão e tente novamente.'
                  : 'Entre na sua conta para gerenciar seu perfil.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textColor),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: FilledButton(
                onPressed: onLogin,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.greenCapiba,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Tentar novamente',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greenCapiba,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.greenCapiba.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            LucideIcons.userCircle2,
            size: 34,
            color: AppColors.greenCapiba,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppFonts.title,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.textColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            'Sair da conta',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.orangeCapiba,
            ),
          ),
        ),
      ),
    );
  }
}
