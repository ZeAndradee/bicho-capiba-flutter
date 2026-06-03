import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../models/auth_user.dart';
import '../../../services/user_service.dart';
import 'settings_sheet.dart';

const _estados = [
  ('AC', 'AC'), ('AL', 'AL'), ('AP', 'AP'), ('AM', 'AM'), ('BA', 'BA'),
  ('CE', 'CE'), ('DF', 'DF'), ('ES', 'ES'), ('GO', 'GO'), ('MA', 'MA'),
  ('MT', 'MT'), ('MS', 'MS'), ('MG', 'MG'), ('PA', 'PA'), ('PB', 'PB'),
  ('PR', 'PR'), ('PE', 'PE'), ('PI', 'PI'), ('RJ', 'RJ'), ('RN', 'RN'),
  ('RS', 'RS'), ('RO', 'RO'), ('RR', 'RR'), ('SC', 'SC'), ('SP', 'SP'),
  ('SE', 'SE'), ('TO', 'TO'),
];

class AddressInfoSheet extends ConsumerStatefulWidget {
  final AuthUser user;

  const AddressInfoSheet({super.key, required this.user});

  @override
  ConsumerState<AddressInfoSheet> createState() => _AddressInfoSheetState();
}

class _AddressInfoSheetState extends ConsumerState<AddressInfoSheet> {
  late final TextEditingController _cep;
  late final TextEditingController _rua;
  late final TextEditingController _numero;
  late final TextEditingController _complemento;
  late final TextEditingController _bairro;
  late final TextEditingController _cidade;
  String? _estado;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _cep = TextEditingController(
      text: u.cep == null ? '' : formatCep(u.cep!),
    );
    _rua = TextEditingController(text: u.rua ?? '');
    _numero = TextEditingController(text: u.numero ?? '');
    _complemento = TextEditingController(text: u.complemento ?? '');
    _bairro = TextEditingController(text: u.bairro ?? '');
    _cidade = TextEditingController(text: u.cidade ?? '');
    _estado = u.estado;
  }

  @override
  void dispose() {
    _cep.dispose();
    _rua.dispose();
    _numero.dispose();
    _complemento.dispose();
    _bairro.dispose();
    _cidade.dispose();
    super.dispose();
  }

  String? _orNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final payload = Map<String, dynamic>.from(widget.user.raw)
        ..addAll({
          'cep': _orNull(_cep.text),
          'rua': _orNull(_rua.text),
          'numero': _orNull(_numero.text),
          'complemento': _orNull(_complemento.text),
          'bairro': _orNull(_bairro.text),
          'cidade': _orNull(_cidade.text),
          'estado': _estado,
        });
      payload['dataNascimento'] = toDateOnly(payload['dataNascimento']);
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
      title: 'Endereço',
      saving: _saving,
      error: _error,
      onSave: _save,
      children: [
        FormTextField(
          label: 'CEP',
          hint: '00000-000',
          controller: _cep,
          keyboardType: TextInputType.number,
          inputFormatters: [CepInputFormatter()],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: FormTextField(
                label: 'Rua',
                hint: 'Nome da rua',
                controller: _rua,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormTextField(
                label: 'Número',
                hint: '123',
                controller: _numero,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        FormTextField(
          label: 'Complemento',
          hint: 'Apto, bloco, etc (opcional)',
          controller: _complemento,
        ),
        FormTextField(
          label: 'Bairro',
          hint: 'Bairro',
          controller: _bairro,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: FormTextField(
                label: 'Cidade',
                hint: 'Cidade',
                controller: _cidade,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormDropdownField(
                label: 'Estado',
                hint: 'UF',
                value: _estado,
                items: _estados,
                onChanged: (v) => setState(() => _estado = v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
