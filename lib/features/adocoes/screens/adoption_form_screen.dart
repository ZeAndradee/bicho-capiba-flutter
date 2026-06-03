import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/animal.dart';
import '../../../services/adoption_service.dart';
import '../models/adoption_form.dart';

class AdoptionFormScreen extends ConsumerStatefulWidget {
  final Animal animal;

  const AdoptionFormScreen({super.key, required this.animal});

  @override
  ConsumerState<AdoptionFormScreen> createState() => _AdoptionFormScreenState();
}

class _AdoptionFormScreenState extends ConsumerState<AdoptionFormScreen> {
  final _form = AdoptionForm();

  final _moradores = TextEditingController();
  final _qtdAnimais = TextEditingController();
  final _idadeAnimais = TextEditingController();
  final _comportamento = TextEditingController();
  final _qtdCriancas = TextEditingController();
  final _tipoNecCriancas = TextEditingController();
  final _composicao = TextEditingController();
  final _tipoNecFamiliar = TextEditingController();

  int _step = 0;
  bool _forward = true;
  bool _sending = false;
  String? _error;

  static const _lastStep = 6;
  static const _successStep = 7;

  Animal get animal => widget.animal;
  String get _artigo => animal.sexo == 'M' ? 'o' : 'a';

  @override
  void initState() {
    super.initState();
    _moradores.addListener(() => _sync(() => _form.quantidadeMoradores = _moradores.text));
    _qtdAnimais.addListener(() => _sync(() => _form.quantidadeAnimais = _qtdAnimais.text));
    _idadeAnimais.addListener(() => _sync(() => _form.idadeAnimais = _idadeAnimais.text));
    _comportamento.addListener(() => _sync(() => _form.comportamentoAnimais = _comportamento.text));
    _qtdCriancas.addListener(() => _sync(() => _form.quantidadeCriancas = _qtdCriancas.text));
    _tipoNecCriancas.addListener(() => _sync(() => _form.tipoNecessidadeCriancas = _tipoNecCriancas.text));
    _composicao.addListener(() => _sync(() => _form.composicaoFamiliar = _composicao.text));
    _tipoNecFamiliar.addListener(() => _sync(() => _form.tipoNecessidadeEspecialFamiliar = _tipoNecFamiliar.text));
  }

  @override
  void dispose() {
    _moradores.dispose();
    _qtdAnimais.dispose();
    _idadeAnimais.dispose();
    _comportamento.dispose();
    _qtdCriancas.dispose();
    _tipoNecCriancas.dispose();
    _composicao.dispose();
    _tipoNecFamiliar.dispose();
    super.dispose();
  }

  void _sync(VoidCallback update) => setState(update);

  bool get _canContinue {
    switch (_step) {
      case 0:
        return true;
      case 1:
        return _form.tipoResidencia.isNotEmpty &&
            _form.quantidadeMoradores.trim().isNotEmpty;
      case 2:
        return _form.areaExterna != null && _form.telaProtetora != null;
      case 3:
        if (_form.possuiAnimais == null) return false;
        if (_form.possuiAnimais == true) {
          return _form.quantidadeAnimais.trim().isNotEmpty &&
              _form.idadeAnimais.trim().isNotEmpty &&
              _form.sexoAnimais.isNotEmpty &&
              _form.comportamentoAnimais.trim().isNotEmpty;
        }
        return true;
      case 4:
        if (_form.possuiCriancas == null) return false;
        if (_form.possuiCriancas == true) {
          if (_form.quantidadeCriancas.trim().isEmpty ||
              _form.faixaEtariaCriancas.isEmpty ||
              _form.criancaNecessidadeEspecial == null) {
            return false;
          }
          if (_form.criancaNecessidadeEspecial == true &&
              _form.tipoNecessidadeCriancas.trim().isEmpty) {
            return false;
          }
        }
        return true;
      case 5:
        if (_form.composicaoFamiliar.trim().isEmpty) return false;
        if (_form.familiarNecessidadeEspecial == null) return false;
        if (_form.familiarNecessidadeEspecial == true &&
            _form.tipoNecessidadeEspecialFamiliar.trim().isEmpty) {
          return false;
        }
        return true;
      case 6:
        return _form.experienciaComAnimais != null &&
            _form.conhecimentoDespesasAnimais != null &&
            _form.tempoDisponivel.isNotEmpty;
      default:
        return false;
    }
  }

  void _next() {
    if (!_canContinue) return;
    FocusScope.of(context).unfocus();
    if (_step == _lastStep) {
      _submit();
      return;
    }
    setState(() {
      _forward = true;
      _step++;
    });
  }

  void _back() {
    if (_step == 0) {
      context.pop();
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _forward = false;
      _step--;
    });
  }

  Future<void> _submit() async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(adoptionServiceProvider).submitAdoption(
            animalId: animal.id,
            form: _form,
          );
      if (mounted) {
        setState(() {
          _forward = true;
          _step = _successStep;
        });
      }
    } on AdoptionException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Algo deu errado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _successStep) {
      return _SuccessView(animal: animal);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                _Header(step: _step, total: _lastStep + 1, onBack: _back),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      final offset = _forward
                          ? const Offset(0.18, 0)
                          : const Offset(-0.18, 0);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: offset,
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: SingleChildScrollView(
                      key: ValueKey(_step),
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: _stepContent(),
                    ),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                    child: _ErrorBanner(message: _error!),
                  ),
                _Footer(
                  label: _step == 0
                      ? 'Continuar'
                      : _step == _lastStep
                          ? 'Enviar solicitação'
                          : 'Continuar',
                  enabled: _canContinue,
                  loading: _sending,
                  onPressed: _next,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepContent() {
    switch (_step) {
      case 0:
        return _ExplanationStep(animalName: animal.nome);
      case 1:
        return _StepShell(
          title: 'Sua residência',
          subtitle: 'Onde $_artigo ${animal.nome} vai morar com você?',
          children: [
            const _FieldLabel('Tipo de residência'),
            _MappedChoice(
              options: const [
                ('Casa', 'casa'),
                ('Apartamento', 'apartamento'),
                ('Chácara', 'chacara'),
                ('Sítio', 'sitio'),
              ],
              value: _form.tipoResidencia,
              onChanged: (v) => setState(() => _form.tipoResidencia = v),
            ),
            const SizedBox(height: 24),
            _CounterField(
              label: 'Quantidade de moradores na casa',
              controller: _moradores,
            ),
          ],
        );
      case 2:
        return _StepShell(
          title: 'Segurança do lar',
          subtitle: 'Ambientes protegidos evitam fugas e acidentes.',
          children: [
            _BoolQuestion(
              label: 'Possui área externa (quintal, varanda)?',
              value: _form.areaExterna,
              onChanged: (v) => setState(() => _form.areaExterna = v),
            ),
            const SizedBox(height: 24),
            _BoolQuestion(
              label: 'Possui tela protetora em janelas e varandas?',
              value: _form.telaProtetora,
              onChanged: (v) => setState(() => _form.telaProtetora = v),
            ),
          ],
        );
      case 3:
        return _StepShell(
          title: 'Outros animais',
          subtitle: 'Saber da convivência ajuda a ONG a avaliar.',
          children: [
            _BoolQuestion(
              label: 'Já possui outros animais?',
              value: _form.possuiAnimais,
              onChanged: (v) => setState(() => _form.possuiAnimais = v),
            ),
            if (_form.possuiAnimais == true) ...[
              const SizedBox(height: 24),
              _CounterField(
                label: 'Quantos animais?',
                controller: _qtdAnimais,
              ),
              const SizedBox(height: 20),
              _TextField(
                label: 'Idade dos animais',
                hint: 'Ex: 2 anos, 6 meses...',
                controller: _idadeAnimais,
              ),
              const SizedBox(height: 24),
              const _FieldLabel('Sexo dos animais'),
              _MappedChoice(
                options: const [
                  ('Machos', 'machos'),
                  ('Fêmeas', 'femeas'),
                  ('Ambos', 'ambos'),
                ],
                value: _form.sexoAnimais,
                onChanged: (v) => setState(() => _form.sexoAnimais = v),
              ),
              const SizedBox(height: 24),
              _MultilineField(
                label: 'Comportamento dos animais',
                hint: 'Descreva o comportamento dos seus animais...',
                controller: _comportamento,
              ),
            ],
          ],
        );
      case 4:
        return _StepShell(
          title: 'Crianças na família',
          subtitle: 'Compatibilidade com crianças é importante.',
          children: [
            _BoolQuestion(
              label: 'Possui crianças em casa?',
              value: _form.possuiCriancas,
              onChanged: (v) => setState(() => _form.possuiCriancas = v),
            ),
            if (_form.possuiCriancas == true) ...[
              const SizedBox(height: 24),
              _CounterField(
                label: 'Quantidade de crianças',
                controller: _qtdCriancas,
              ),
              const SizedBox(height: 24),
              const _FieldLabel('Faixa etária das crianças'),
              _MappedChoice(
                options: const [
                  ('0-2 anos', '0-2'),
                  ('3-5 anos', '3-5'),
                  ('6-10 anos', '6-10'),
                  ('11-15 anos', '11-15'),
                  ('16+ anos', '16+'),
                  ('Idades variadas', 'variadas'),
                ],
                value: _form.faixaEtariaCriancas,
                onChanged: (v) => setState(() => _form.faixaEtariaCriancas = v),
              ),
              const SizedBox(height: 24),
              _BoolQuestion(
                label: 'Alguma criança possui necessidade especial?',
                value: _form.criancaNecessidadeEspecial,
                onChanged: (v) =>
                    setState(() => _form.criancaNecessidadeEspecial = v),
              ),
              if (_form.criancaNecessidadeEspecial == true) ...[
                const SizedBox(height: 20),
                _TextField(
                  label: 'Tipo de necessidade especial',
                  hint: 'Descreva a necessidade especial...',
                  controller: _tipoNecCriancas,
                ),
              ],
            ],
          ],
        );
      case 5:
        return _StepShell(
          title: 'Sua família',
          subtitle: 'Conte quem faz parte do lar.',
          children: [
            _MultilineField(
              label: 'Composição familiar',
              hint: 'Quem mora na casa (idades, parentesco, etc.)',
              controller: _composicao,
            ),
            const SizedBox(height: 24),
            _BoolQuestion(
              label: 'Algum familiar possui necessidade especial?',
              value: _form.familiarNecessidadeEspecial,
              onChanged: (v) =>
                  setState(() => _form.familiarNecessidadeEspecial = v),
            ),
            if (_form.familiarNecessidadeEspecial == true) ...[
              const SizedBox(height: 20),
              _TextField(
                label: 'Tipo de necessidade especial',
                hint: 'Descreva a necessidade especial...',
                controller: _tipoNecFamiliar,
              ),
            ],
          ],
        );
      case 6:
        return _StepShell(
          title: 'Experiência e rotina',
          subtitle: 'Quase lá! Últimas perguntas.',
          children: [
            _BoolQuestion(
              label: 'Possui experiência com animais?',
              value: _form.experienciaComAnimais,
              onChanged: (v) =>
                  setState(() => _form.experienciaComAnimais = v),
            ),
            const SizedBox(height: 24),
            _BoolQuestion(
              label: 'Tem conhecimento sobre as despesas (ração, vet, vacinas)?',
              value: _form.conhecimentoDespesasAnimais,
              onChanged: (v) =>
                  setState(() => _form.conhecimentoDespesasAnimais = v),
            ),
            const SizedBox(height: 24),
            const _FieldLabel('Tempo disponível para o animal'),
            _MappedChoice(
              options: const [
                ('Poucas horas por dia', 'poucas-horas'),
                ('Meio período', 'meio-periodo'),
                ('Período integral', 'periodo-integral'),
                ('Apenas fins de semana', 'fins-de-semana'),
              ],
              value: _form.tempoDisponivel,
              onChanged: (v) => setState(() => _form.tempoDisponivel = v),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ExplanationStep extends StatelessWidget {
  final String animalName;

  const _ExplanationStep({required this.animalName});

  @override
  Widget build(BuildContext context) {
    Widget bullet(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  LucideIcons.badgeCheck,
                  size: 18,
                  color: AppColors.greenCapiba,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Como funciona?',
          style: TextStyle(
            fontFamily: AppFonts.title,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 1.1,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Para garantir a segurança e o bem-estar de todos, o Bicho Capiba segue um processo criterioso de adoção.',
          style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.textColor),
        ),
        const SizedBox(height: 14),
        const Text(
          'Você vai preencher um formulário sobre sua família, residência e experiência. Isso ajuda a ONG a:',
          style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.textColor),
        ),
        const SizedBox(height: 16),
        bullet('Garantir que $animalName terá um lar seguro e adequado'),
        bullet('Assegurar a compatibilidade com sua família'),
        bullet('Proteger tanto o animal quanto você'),
        bullet('Cumprir as diretrizes de adoção responsável'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: const Text(
            'Todas as informações são confidenciais e usadas apenas para o processo de adoção.',
            style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.textColor),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final int step;
  final int total;
  final VoidCallback onBack;

  const _Header({required this.step, required this.total, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 24, 8),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(22),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                LucideIcons.arrowLeft,
                size: 24,
                color: AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (step + 1) / total,
                minHeight: 6,
                backgroundColor: AppColors.borderColor,
                valueColor: const AlwaysStoppedAnimation(AppColors.greenCapiba),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  const _Footer({
    required this.label,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: SizedBox(
        height: 54,
        width: double.infinity,
        child: FilledButton(
          onPressed: enabled && !loading ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.greenCapiba,
            disabledBackgroundColor: AppColors.skeletonBase,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(label, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class _StepShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _StepShell({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.title,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 1.1,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            height: 1.4,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 28),
        ...children,
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _TextField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 15, color: AppColors.foreground),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 15,
                color: AppColors.textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CounterField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  static const min = 1;
  static const max = 99;

  const _CounterField({
    required this.label,
    required this.controller,
  });

  int get _value => int.tryParse(controller.text) ?? 0;

  void _set(int value) {
    final clamped = value.clamp(min, max);
    controller.text = clamped.toString();
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  void _increment() => _set(_value < min ? min : _value + 1);

  void _decrement() {
    if (_value > min) _set(_value - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            children: [
              _StepButton(
                icon: LucideIcons.minus,
                enabled: _value > min,
                onTap: _decrement,
              ),
              const _StepDivider(),
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ),
              const _StepDivider(),
              _StepButton(
                icon: LucideIcons.plus,
                enabled: _value < max,
                onTap: _increment,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 52,
        height: 52,
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: enabled ? AppColors.greenCapiba : AppColors.skeletonBase,
          ),
        ),
      ),
    );
  }
}

class _StepDivider extends StatelessWidget {
  const _StepDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 52, color: AppColors.borderColor);
  }
}

class _MultilineField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _MultilineField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 400,
            style: const TextStyle(fontSize: 15, color: AppColors.foreground),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 15,
                color: AppColors.textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MappedChoice extends StatelessWidget {
  final List<(String, String)> options;
  final String value;
  final ValueChanged<String> onChanged;

  const _MappedChoice({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _ListTileChoice(
            label: options[i].$1,
            selected: value == options[i].$2,
            onTap: () => onChanged(options[i].$2),
          ),
        ],
      ],
    );
  }
}

class _ListTileChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ListTileChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.greenCapiba.withValues(alpha: 0.08)
              : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.greenCapiba : AppColors.borderColor,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.foreground
                      : AppColors.textColor,
                ),
              ),
            ),
            Icon(
              selected ? LucideIcons.checkCircle2 : LucideIcons.circle,
              size: 22,
              color: selected ? AppColors.greenCapiba : AppColors.borderColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _BoolQuestion extends StatelessWidget {
  final String label;
  final bool? value;
  final ValueChanged<bool> onChanged;

  const _BoolQuestion({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        Row(
          children: [
            Expanded(
              child: _Pill(
                label: 'Sim',
                selected: value == true,
                onTap: () => onChanged(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Pill(
                label: 'Não',
                selected: value == false,
                onTap: () => onChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.greenCapiba.withValues(alpha: 0.08)
              : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.greenCapiba : AppColors.borderColor,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.foreground : AppColors.textColor,
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.orangeCapiba.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.orangeCapiba.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 20, color: AppColors.orangeCapiba),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14, color: AppColors.foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final Animal animal;

  const _SuccessView({required this.animal});

  @override
  Widget build(BuildContext context) {
    final artigo = animal.sexo == 'M' ? 'o' : 'a';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.greenCapiba.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.badgeCheck,
                        size: 44,
                        color: AppColors.greenCapiba,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Solicitação enviada!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.title,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sua solicitação para adotar $artigo ${animal.nome} foi enviada. A ONG responsável vai analisar e entrar em contato pelo e-mail cadastrado.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const _ProcessTracker(),
                  const SizedBox(height: 36),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: () => context.go('/adocoes'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.greenCapiba,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Ver status da adoção',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () => context.go('/adote'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Ver outros animais',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProcessTracker extends StatelessWidget {
  const _ProcessTracker();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _ProcessNode(
          icon: LucideIcons.check,
          label: 'Solicitação\nenviada',
          state: _NodeState.completed,
        ),
        _ProcessLine(active: true),
        _ProcessNode(
          icon: LucideIcons.clock,
          label: 'Em\nanálise',
          state: _NodeState.current,
        ),
        _ProcessLine(active: false),
        _ProcessNode(
          icon: LucideIcons.check,
          label: 'Aprovado',
          state: _NodeState.pending,
        ),
      ],
    );
  }
}

enum _NodeState { completed, current, pending }

class _ProcessNode extends StatelessWidget {
  final IconData icon;
  final String label;
  final _NodeState state;

  const _ProcessNode({
    required this.icon,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (state) {
      case _NodeState.completed:
        bg = AppColors.greenCapiba;
        fg = Colors.white;
        break;
      case _NodeState.current:
        bg = AppColors.yellowCapiba;
        fg = Colors.white;
        break;
      case _NodeState.pending:
        bg = AppColors.backgroundSecondary;
        fg = AppColors.skeletonBase;
        break;
    }
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: state == _NodeState.pending
                ? Border.all(color: AppColors.borderColor)
                : null,
          ),
          child: Icon(icon, size: 20, color: fg),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 78,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w500,
              color: state == _NodeState.pending
                  ? AppColors.textColor
                  : AppColors.foreground,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProcessLine extends StatelessWidget {
  final bool active;

  const _ProcessLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 21),
        height: 2,
        color: active ? AppColors.greenCapiba : AppColors.borderColor,
      ),
    );
  }
}
