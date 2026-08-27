import 'package:flutter/material.dart';

/// Tipos de serviço terceirizado.
///
/// Torna o produto genérico (não apenas limpeza), conforme a visão de
/// plataforma descrita no briefing.
enum ServiceType {
  limpeza,
  jardinagem,
  portaria,
  recepcao,
  higienizacao,
  apoioAdministrativo,
  movimentacaoCarga;

  String get label => switch (this) {
        ServiceType.limpeza => 'Limpeza',
        ServiceType.jardinagem => 'Jardinagem',
        ServiceType.portaria => 'Portaria',
        ServiceType.recepcao => 'Recepção',
        ServiceType.higienizacao => 'Higienização',
        ServiceType.apoioAdministrativo => 'Apoio Administrativo',
        ServiceType.movimentacaoCarga => 'Movimentação de Carga',
      };

  IconData get icon => switch (this) {
        ServiceType.limpeza => Icons.cleaning_services_outlined,
        ServiceType.jardinagem => Icons.grass_outlined,
        ServiceType.portaria => Icons.meeting_room_outlined,
        ServiceType.recepcao => Icons.support_agent_outlined,
        ServiceType.higienizacao => Icons.sanitizer_outlined,
        ServiceType.apoioAdministrativo => Icons.assignment_outlined,
        ServiceType.movimentacaoCarga => Icons.local_shipping_outlined,
      };

  static ServiceType fromName(String? value) => ServiceType.values.firstWhere(
        (type) => type.name == value,
        orElse: () => ServiceType.limpeza,
      );
}
