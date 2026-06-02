import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_scaffold.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  static final _emailRegex = RegExp(r'^\S+@\S+\.\S+$');

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_name.text.trim().isEmpty) return 'Informe seu nome completo.';
    if (!_emailRegex.hasMatch(_email.text.trim())) {
      return 'Informe um e-mail válido.';
    }
    if (_password.text.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres.';
    }
    if (_password.text != _confirm.text) {
      return 'As senhas não coincidem.';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_loading) return;
    final validation = _validate();
    if (validation != null) {
      setState(() => _error = validation);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).register(
            fullName: _name.text,
            email: _email.text,
            password: _password.text,
          );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Algo deu errado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Criar conta',
      subtitle: 'Preencha seus dados e comece a transformar vidas.',
      children: [
        if (_error != null) ...[
          AuthErrorBanner(message: _error!),
          const SizedBox(height: 16),
        ],
        AuthTextField(
          label: 'Nome completo',
          hint: 'Seu nome',
          controller: _name,
          icon: Icons.person_outline,
          keyboardType: TextInputType.name,
          autofocus: true,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'E-mail',
          hint: 'seu@email.com',
          controller: _email,
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Senha',
          hint: 'Mínimo 8 caracteres',
          controller: _password,
          icon: Icons.lock_outline,
          obscure: true,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Confirmar senha',
          hint: 'Repita sua senha',
          controller: _confirm,
          icon: Icons.lock_outline,
          obscure: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 24),
        AuthButton(
          label: 'Criar conta',
          loading: _loading,
          onPressed: _submit,
        ),
        const SizedBox(height: 20),
        Center(
          child: Text.rich(
            TextSpan(
              text: 'Já tem uma conta? ',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textColor,
              ),
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: () => context.pushReplacement('/entrar'),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orangeCapiba,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
