import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/auth_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/images/BichoCapibaLogo.png',
                    height: 44,
                    alignment: Alignment.centerLeft,
                  ),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/3StepSignup.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Text(
                    'Bem-vindo ao Bicho Capiba',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.title,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Adote, doe e transforme a vida de um animal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textColor),
                  ),
                  const SizedBox(height: 28),
                  AuthButton(
                    label: 'Criar conta',
                    onPressed: () => context.push('/cadastro'),
                  ),
                  const SizedBox(height: 12),
                  AuthButton(
                    label: 'Entrar',
                    filled: false,
                    onPressed: () => context.push('/entrar'),
                  ),
                  const SizedBox(height: 20),
                  const _TermsText(),
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

class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'Ao continuar, você concorda com os ',
        children: [
          TextSpan(
            text: 'Termos de Uso',
            style: const TextStyle(
              color: AppColors.orangeCapiba,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: ' e a '),
          TextSpan(
            text: 'Política de Privacidade',
            style: const TextStyle(
              color: AppColors.orangeCapiba,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13, color: AppColors.textColor),
    );
  }
}
