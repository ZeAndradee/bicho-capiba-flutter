import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/animal.dart';

enum AdoptionStatus { pendente, aprovado, rejeitado, desconhecido }

class AdoptionProcess {
  final String uuid;
  final AdoptionStatus status;
  final String rawStatus;
  final String? motivo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Animal animal;

  const AdoptionProcess({
    required this.uuid,
    required this.status,
    required this.rawStatus,
    required this.animal,
    this.motivo,
    this.createdAt,
    this.updatedAt,
  });

  factory AdoptionProcess.fromJson(Map<String, dynamic> json) {
    return AdoptionProcess(
      uuid: json['uuid'] as String? ?? '',
      rawStatus: json['status'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      motivo: json['motivo'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      animal: Animal.fromJson(json['animal'] as Map<String, dynamic>),
    );
  }

  static AdoptionStatus _parseStatus(String? value) {
    switch (value) {
      case 'pendente':
        return AdoptionStatus.pendente;
      case 'aprovado':
        return AdoptionStatus.aprovado;
      case 'rejeitado':
        return AdoptionStatus.rejeitado;
      default:
        return AdoptionStatus.desconhecido;
    }
  }

  bool get isActive =>
      status == AdoptionStatus.pendente || status == AdoptionStatus.aprovado;

  bool get isPast => !isActive;

  double get completion {
    switch (status) {
      case AdoptionStatus.pendente:
        return 2 / 3;
      case AdoptionStatus.aprovado:
        return 1;
      case AdoptionStatus.rejeitado:
        return 1;
      case AdoptionStatus.desconhecido:
        return 1 / 3;
    }
  }

  String get statusLabel {
    switch (status) {
      case AdoptionStatus.pendente:
        return 'Em Análise';
      case AdoptionStatus.aprovado:
        return 'Aprovado';
      case AdoptionStatus.rejeitado:
        return 'Não Aprovado';
      case AdoptionStatus.desconhecido:
        return 'Status Desconhecido';
    }
  }

  Color get statusColor {
    switch (status) {
      case AdoptionStatus.pendente:
        return AppColors.yellowCapiba;
      case AdoptionStatus.aprovado:
        return AppColors.greenCapiba;
      case AdoptionStatus.rejeitado:
        return AppColors.orangeCapiba;
      case AdoptionStatus.desconhecido:
        return AppColors.textColor;
    }
  }
}
