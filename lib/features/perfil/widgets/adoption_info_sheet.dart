import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../models/auth_user.dart';
import '../../../services/user_service.dart';
import 'settings_sheet.dart';

class AdoptionInfoSheet extends ConsumerStatefulWidget {
  final AuthUser user;

  const AdoptionInfoSheet({super.key, required this.user});

  @override
  ConsumerState<AdoptionInfoSheet> createState() => _AdoptionInfoSheetState();
}

class _AdoptionInfoSheetState extends ConsumerState<AdoptionInfoSheet> {
  late final TextEditingController _moradores;
  late final TextEditingController _qtdAnimais;
  late final TextEditingController _idade;
  late final TextEditingController _comportamento;
  late final TextEditingController _qtdCriancas;
  late final TextEditingController _tipoNecCriancas;
  late final TextEditingController _tipoNecFamiliar;
  late final TextEditingController _composicao;

  String _tipoResidencia = '';
  bool? _areaExterna;
  bool? _telaProtetora;
  bool? _possuiAnimais;
  String _sexoAnimais = '';
  String _experiencia = '';
  String _conhecimento = '';
  bool? _possuiCriancas;
  String _faixaEtaria = '';
  bool? _criancaNecEsp;
  bool? _familiarNecEsp;
  String _tempo = '';

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final r = widget.user.raw;
    _moradores = TextEditingController(text: _str(r['quantidadeMoradores']));
    _qtdAnimais = TextEditingController(text: _str(r['quantidadeAnimais']));
    _idade = TextEditingController(text: _str(r['idadeAnimais']));
    _comportamento = TextEditingController(text: _str(r['comportamentoAnimais']));
    _qtdCriancas = TextEditingController(text: _str(r['quantidadeCriancas']));
    _tipoNecCriancas = TextEditingController(text: _str(r['tipoNecessidadeCriancas']));
    _tipoNecFamiliar =
        TextEditingController(text: _str(r['tipoNecessidadeEspecialFamiliar']));
    _composicao = TextEditingController(text: _str(r['composicaoFamiliar']));

    _tipoResidencia = _str(r['tipoResidencia']);
    _areaExterna = _bool(r['areaExterna']);
    _telaProtetora = _bool(r['telaProtetora']);
    _possuiAnimais = _bool(r['possuiAnimais']);
    _sexoAnimais = _str(r['sexoAnimais']);
    _experiencia = _scale(r['experienciaComAnimais']);
    _conhecimento = _scale(r['conhecimentoDespesasAnimais']);
    _possuiCriancas = _bool(r['possuiCriancas']);
    _faixaEtaria = _str(r['faixaEtariaCriancas']);
    _criancaNecEsp = _bool(r['criancaNecessidadeEspecial']);
    _familiarNecEsp = _bool(r['familiarNecessidadeEspecial']);
    _tempo = _str(r['tempoDisponivel']);
  }

  @override
  void dispose() {
    _moradores.dispose();
    _qtdAnimais.dispose();
    _idade.dispose();
    _comportamento.dispose();
    _qtdCriancas.dispose();
    _tipoNecCriancas.dispose();
    _tipoNecFamiliar.dispose();
    _composicao.dispose();
    super.dispose();
  }

  static String _str(dynamic v) => v?.toString() ?? '';

  static String _scale(dynamic v) => v == null ? '' : v.toString();

  static bool? _bool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      if (v == '1' || v.toLowerCase() == 'true') return true;
      if (v == '0' || v.toLowerCase() == 'false') return false;
    }
    return null;
  }

  int? _toInt(bool? v) => v == null ? null : (v ? 1 : 0);

  String? _orNull(String v) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final hasAnimais = _possuiAnimais == true;
      final hasCriancas = _possuiCriancas == true;
      final payload = Map<String, dynamic>.from(widget.user.raw)
        ..addAll({
          'tipoResidencia': _orNull(_tipoResidencia),
          'quantidadeMoradores': int.tryParse(_moradores.text),
          'areaExterna': _toInt(_areaExterna),
          'telaProtetora': _toInt(_telaProtetora),
          'possuiAnimais': _toInt(_possuiAnimais),
          'quantidadeAnimais':
              hasAnimais ? int.tryParse(_qtdAnimais.text) : null,
          'sexoAnimais': hasAnimais ? _orNull(_sexoAnimais) : null,
          'idadeAnimais': hasAnimais ? _orNull(_idade.text) : null,
          'comportamentoAnimais':
              hasAnimais ? _orNull(_comportamento.text) : null,
          'experienciaComAnimais':
              _experiencia.isEmpty ? null : int.tryParse(_experiencia),
          'conhecimentoDespesasAnimais':
              _conhecimento.isEmpty ? null : int.tryParse(_conhecimento),
          'possuiCriancas': _toInt(_possuiCriancas),
          'quantidadeCriancas':
              hasCriancas ? int.tryParse(_qtdCriancas.text) : null,
          'faixaEtariaCriancas': hasCriancas ? _orNull(_faixaEtaria) : null,
          'criancaNecessidadeEspecial':
              hasCriancas ? _toInt(_criancaNecEsp) : null,
          'tipoNecessidadeCriancas':
              (hasCriancas && _criancaNecEsp == true)
                  ? _orNull(_tipoNecCriancas.text)
                  : null,
          'familiarNecessidadeEspecial': _toInt(_familiarNecEsp),
          'tipoNecessidadeEspecialFamiliar':
              _familiarNecEsp == true ? _orNull(_tipoNecFamiliar.text) : null,
          'tempoDisponivel': _orNull(_tempo),
          'composicaoFamiliar': _orNull(_composicao.text),
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

  Widget _labeled(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [FieldLabel(label), child],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSheet(
      title: 'Informações de adoção',
      saving: _saving,
      error: _error,
      onSave: _save,
      children: [
        const _SectionTitle(
          icon: LucideIcons.home,
          title: 'Informações da residência',
        ),
        _labeled(
          'Tipo de residência',
          FormChoiceList(
            options: const [
              ('Casa', 'casa'),
              ('Apartamento', 'apartamento'),
              ('Sítio/Chácara', 'sitio'),
              ('Outros', 'outros'),
            ],
            value: _tipoResidencia,
            onChanged: (v) => setState(() => _tipoResidencia = v),
          ),
        ),
        FormCounterField(
          label: 'Quantidade de moradores',
          controller: _moradores,
        ),
        FormBoolQuestion(
          label: 'Possui área externa (quintal, varanda)?',
          value: _areaExterna,
          onChanged: (v) => setState(() => _areaExterna = v),
        ),
        FormBoolQuestion(
          label: 'Possui tela protetora?',
          value: _telaProtetora,
          onChanged: (v) => setState(() => _telaProtetora = v),
        ),
        const _SectionTitle(
          icon: LucideIcons.dog,
          title: 'Experiência com animais',
        ),
        FormBoolQuestion(
          label: 'Já possui outros animais?',
          value: _possuiAnimais,
          onChanged: (v) => setState(() => _possuiAnimais = v),
        ),
        if (_possuiAnimais == true) ...[
          FormCounterField(label: 'Quantos animais?', controller: _qtdAnimais),
          _labeled(
            'Sexo dos animais',
            FormChoiceList(
              options: const [
                ('Apenas machos', 'machos'),
                ('Apenas fêmeas', 'femeas'),
                ('Ambos', 'ambos'),
              ],
              value: _sexoAnimais,
              onChanged: (v) => setState(() => _sexoAnimais = v),
            ),
          ),
          FormTextField(
            label: 'Idade dos animais',
            hint: 'Ex: 2 anos, 6 meses...',
            controller: _idade,
          ),
          FormMultilineField(
            label: 'Comportamento dos animais',
            hint: 'Descreva o comportamento dos seus animais...',
            controller: _comportamento,
          ),
        ],
        _labeled(
          'Experiência com animais',
          FormChoiceList(
            options: const [
              ('Nenhuma experiência', '0'),
              ('Pouca experiência', '1'),
              ('Experiência moderada', '2'),
              ('Muita experiência', '3'),
            ],
            value: _experiencia,
            onChanged: (v) => setState(() => _experiencia = v),
          ),
        ),
        _labeled(
          'Conhecimento sobre despesas com animais',
          FormChoiceList(
            options: const [
              ('Nenhum conhecimento', '0'),
              ('Conhecimento básico', '1'),
              ('Conhecimento moderado', '2'),
              ('Conhecimento avançado', '3'),
            ],
            value: _conhecimento,
            onChanged: (v) => setState(() => _conhecimento = v),
          ),
        ),
        const _SectionTitle(
          icon: LucideIcons.users,
          title: 'Família e disponibilidade',
        ),
        FormBoolQuestion(
          label: 'Possui crianças em casa?',
          value: _possuiCriancas,
          onChanged: (v) => setState(() => _possuiCriancas = v),
        ),
        if (_possuiCriancas == true) ...[
          FormCounterField(
            label: 'Quantidade de crianças',
            controller: _qtdCriancas,
          ),
          _labeled(
            'Faixa etária das crianças',
            FormChoiceList(
              options: const [
                ('0-2 anos', '0-2'),
                ('3-5 anos', '3-5'),
                ('6-10 anos', '6-10'),
                ('11-15 anos', '11-15'),
                ('16+ anos', '16+'),
                ('Idades variadas', 'variadas'),
              ],
              value: _faixaEtaria,
              onChanged: (v) => setState(() => _faixaEtaria = v),
            ),
          ),
          FormBoolQuestion(
            label: 'Alguma criança possui necessidade especial?',
            value: _criancaNecEsp,
            onChanged: (v) => setState(() => _criancaNecEsp = v),
          ),
          if (_criancaNecEsp == true)
            FormTextField(
              label: 'Tipo de necessidade especial',
              hint: 'Ex: Autismo, TDAH',
              controller: _tipoNecCriancas,
            ),
        ],
        FormBoolQuestion(
          label: 'Algum familiar possui necessidade especial?',
          value: _familiarNecEsp,
          onChanged: (v) => setState(() => _familiarNecEsp = v),
        ),
        if (_familiarNecEsp == true)
          FormTextField(
            label: 'Tipo de necessidade especial do familiar',
            hint: 'Ex: Mobilidade reduzida',
            controller: _tipoNecFamiliar,
          ),
        _labeled(
          'Tempo disponível para o animal',
          FormChoiceList(
            options: const [
              ('Poucas horas por dia', 'poucas-horas'),
              ('Meio período', 'meio-periodo'),
              ('Período integral', 'periodo-integral'),
              ('Apenas fins de semana', 'fins-de-semana'),
            ],
            value: _tempo,
            onChanged: (v) => setState(() => _tempo = v),
          ),
        ),
        FormMultilineField(
          label: 'Composição familiar',
          hint: 'Quem mora na casa (idades, parentesco, etc.)',
          controller: _composicao,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

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
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.foreground,
          ),
        ),
      ],
    );
  }
}
