import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../models/auth_user.dart';
import '../../../services/user_service.dart';
import 'settings_sheet.dart';

class PersonalInfoSheet extends ConsumerStatefulWidget {
  final AuthUser user;

  const PersonalInfoSheet({super.key, required this.user});

  @override
  ConsumerState<PersonalInfoSheet> createState() => _PersonalInfoSheetState();
}

class _PersonalInfoSheetState extends ConsumerState<PersonalInfoSheet> {
  late final TextEditingController _nome;
  late final TextEditingController _telefone;
  late final TextEditingController _email;
  DateTime? _nascimento;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: widget.user.fullName ?? '');
    _telefone = TextEditingController(
      text: widget.user.telefone == null
          ? ''
          : formatPhone(widget.user.telefone!),
    );
    _email = TextEditingController(text: widget.user.email);
    _nascimento = parseIsoDate(widget.user.dataNascimento);
  }

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final payload = Map<String, dynamic>.from(widget.user.raw)
        ..addAll({
          'fullName': _nome.text.trim(),
          'telefone': _telefone.text.trim().isEmpty ? null : _telefone.text.trim(),
          'dataNascimento':
              _nascimento == null ? null : toIsoDate(_nascimento!),
        });
      await ref.read(userServiceProvider).updateProfile(payload);
      if (mounted) Navigator.of(context).pop(true);
    } on UserUpdateException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Algo deu errado. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSheet(
      title: 'Informações pessoais',
      saving: _saving,
      error: _error,
      onSave: _save,
      children: [
        FormTextField(
          label: 'Nome completo',
          hint: 'Seu nome completo',
          controller: _nome,
          keyboardType: TextInputType.name,
        ),
        FormTextField(
          label: 'E-mail',
          hint: 'seu@email.com',
          controller: _email,
          enabled: false,
          helperText: 'O e-mail não pode ser alterado',
        ),
        FormDateField(
          label: 'Data de nascimento',
          hint: 'Selecione a data',
          value: _nascimento,
          onChanged: (d) => setState(() => _nascimento = d),
        ),
        FormTextField(
          label: 'Celular',
          hint: '(11) 99999-9999',
          controller: _telefone,
          keyboardType: TextInputType.phone,
          inputFormatters: [PhoneInputFormatter()],
        ),
      ],
    );
  }
}
