import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/animal.dart';
import '../models/adoption_process.dart';
import 'adoption_card_shared.dart';

Future<void> showAdoptionStatusSheet(
  BuildContext context,
  AdoptionProcess process,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AdoptionStatusSheet(process: process),
  );
}

class _AdoptionStatusSheet extends StatelessWidget {
  final AdoptionProcess process;

  const _AdoptionStatusSheet({required this.process});

  @override
  Widget build(BuildContext context) {
    final color = process.statusColor;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) => Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Adoção · ${process.animal.nome}',
                    style: const TextStyle(
                      fontFamily: AppFonts.title,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x),
                  color: AppColors.textColor,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderColor),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progresso da Adoção',
                      style: TextStyle(
                        fontFamily: AppFonts.title,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                    StatusChip(process: process),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Solicitado em ${formatAdoptionDate(process.createdAt)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textColor,
                  ),
                ),
                Text(
                  'Última atualização ${formatAdoptionDate(process.updatedAt)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 24),
                _ProcessSteps(process: process),
                const SizedBox(height: 24),
                if (process.status == AdoptionStatus.rejeitado &&
                    process.motivo != null &&
                    process.motivo!.isNotEmpty)
                  _RejectionSection(motivo: process.motivo!),
                _NextSteps(status: process.status, color: color),
                if (process.status == AdoptionStatus.aprovado)
                  _OngContact(animal: process.animal),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessSteps extends StatelessWidget {
  final AdoptionProcess process;

  const _ProcessSteps({required this.process});

  @override
  Widget build(BuildContext context) {
    final color = process.statusColor;
    final pending = AppColors.borderColor;
    final isRejected = process.status == AdoptionStatus.rejeitado;
    final isApproved = process.status == AdoptionStatus.aprovado;
    final isPending = process.status == AdoptionStatus.pendente;

    final List<_Step> steps;
    if (isRejected) {
      steps = [
        _Step('Solicitação Enviada', LucideIcons.check, color),
        _Step('Não Aprovado', LucideIcons.x, color),
        _Step('Aprovado', LucideIcons.check, pending),
      ];
    } else {
      steps = [
        _Step('Solicitação Enviada', LucideIcons.check, color),
        _Step(
          'Em Análise',
          isPending ? LucideIcons.clock : LucideIcons.check,
          color,
        ),
        _Step('Aprovado', LucideIcons.check, isApproved ? color : pending),
      ];
    }

    final connectorAfterFirst = color;
    final connectorAfterSecond = isApproved ? color : pending;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepColumn(steps[0]),
        _connector(connectorAfterFirst),
        _stepColumn(steps[1]),
        _connector(connectorAfterSecond),
        _stepColumn(steps[2]),
      ],
    );
  }

  Widget _stepColumn(_Step step) {
    final isPending = step.color == AppColors.borderColor;
    return SizedBox(
      width: 78,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPending
                  ? AppColors.backgroundSecondary
                  : step.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: step.color, width: 2),
            ),
            child: Icon(
              step.icon,
              size: 18,
              color: isPending ? AppColors.skeletonBase : step.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _connector(Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 19),
        height: 3,
        decoration: BoxDecoration(
          color: color == AppColors.borderColor ? AppColors.borderColor : color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Step {
  final String label;
  final IconData icon;
  final Color color;

  const _Step(this.label, this.icon, this.color);
}

class _RejectionSection extends StatelessWidget {
  final String motivo;

  const _RejectionSection({required this.motivo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.orangeCapiba.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.orangeCapiba.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Motivo da Não Aprovação',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.orangeCapiba,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            motivo,
            style: const TextStyle(fontSize: 14, color: AppColors.textColor),
          ),
        ],
      ),
    );
  }
}

class _NextSteps extends StatelessWidget {
  final AdoptionStatus status;
  final Color color;

  const _NextSteps({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    final (title, items, estimate) = _content(status);
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.title,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 8),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (estimate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(LucideIcons.clock, size: 15, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    estimate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  (String, List<String>, String?) _content(AdoptionStatus status) {
    switch (status) {
      case AdoptionStatus.pendente:
        return (
          'Próximos Passos',
          [
            'A ONG está analisando sua solicitação de adoção',
            'Verifique o seu email durante o prazo para acompanhar o status',
            'Mantenha seus dados de contato atualizados',
          ],
          'Tempo estimado: 3 a 7 dias úteis',
        );
      case AdoptionStatus.aprovado:
        return (
          'Próximos Passos',
          [
            'Prepare os documentos solicitados pela ONG',
            'Aguarde o contato para agendar uma visita',
            'Prepare sua casa para receber o novo amigo',
            'Tenha em mãos os itens básicos (ração, bebedouro, caminha)',
          ],
          null,
        );
      case AdoptionStatus.rejeitado:
        return (
          'O que fazer agora',
          [
            'Não desista! Existem muitos outros animais esperando por um lar',
            'Considere entrar em contato com outras ONGs',
            'Revise os critérios de adoção e tente novamente no futuro',
            'Continue acompanhando os animais disponíveis',
          ],
          null,
        );
      case AdoptionStatus.desconhecido:
        return ('', <String>[], null);
    }
  }
}

class _OngContact extends StatelessWidget {
  final Animal animal;

  const _OngContact({required this.animal});

  @override
  Widget build(BuildContext context) {
    final email = animal.ongEmail;
    final phone = animal.ongTelefone;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contato da ONG${animal.ongNome != null ? ' · ${animal.ongNome}' : ''}',
            style: const TextStyle(
              fontFamily: AppFonts.title,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          if (email != null && email.isNotEmpty) _row(LucideIcons.mail, email),
          if (phone != null && phone.isNotEmpty) ...[
            const SizedBox(height: 8),
            _row(LucideIcons.phone, phone),
          ],
          if ((email == null || email.isEmpty) &&
              (phone == null || phone.isEmpty))
            const Text(
              'A ONG entrará em contato pelo email cadastrado.',
              style: TextStyle(fontSize: 13.5, color: AppColors.textColor),
            ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.greenCapiba),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppColors.foreground),
          ),
        ),
      ],
    );
  }
}
