import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/auth_button.dart';

class RegisterSuccessScreen extends StatelessWidget {
  final String? nome;

  const RegisterSuccessScreen({super.key, this.nome});

  @override
  Widget build(BuildContext context) {
    final greeting = (nome != null && nome!.trim().isNotEmpty)
        ? 'Bem-vindo, ${nome!.trim()}!'
        : 'Bem-vindo ao Bicho Capiba!';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _CloseButton(onTap: () => context.go('/adote')),
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/images/DogHug.png',
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    greeting,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppFonts.title,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      color: AppColors.greenCapiba,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sua conta foi criada. Vamos encontrar seu novo melhor amigo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: AppColors.textColor,
                    ),
                  ),
                  const Spacer(),
                  AuthButton(
                    label: 'Começar',
                    color: AppColors.greenCapiba,
                    onPressed: () => context.go('/adote'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.backgroundSecondary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, size: 22, color: AppColors.foreground),
      ),
    );
  }
}
