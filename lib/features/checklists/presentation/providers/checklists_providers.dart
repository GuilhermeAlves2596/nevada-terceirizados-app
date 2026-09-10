import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/company_catalog.dart';
import '../../../../app/providers/data_scope.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/checklist.dart';

/// Checklists visíveis ao usuário:
/// - os que ele **criou/copiou** (`ownerId == uid`);
/// - checklists **PADRÃO** (do gestor) dos **tipos de cliente no escopo dele**,
///   que ele ainda **não copiou** (ao copiar, o padrão some e a cópia aparece).
///
/// Checklists sem dono e não-padrão (legados de antes deste modelo, ou de outro
/// supervisor) **não aparecem**. companyAdmin/platformAdmin (escopo total) veem
/// todos os padrão.
final checklistsProvider =
    FutureProvider.autoDispose<List<Checklist>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final companyId = user?.companyId;
  if (user == null || companyId == null) return const [];
  final uid = user.id;
  final scope = ref.watch(dataScopeProvider);

  final all = await ref
      .watch(checklistRepositoryProvider)
      .getAll(companyId: companyId);
  final catalog = await ref.watch(companyCatalogProvider.future);

  // Tipos de cliente presentes no escopo do usuário (para os padrão).
  final scopedTypeIds = <String>{};
  if (!scope.all) {
    for (final client in catalog.clientsById.values) {
      final t = client.clientTypeId;
      if (t != null && t.isNotEmpty && scope.allowsClient(client.id)) {
        scopedTypeIds.add(t);
      }
    }
  }

  // Padrão que o usuário já copiou — evita mostrar padrão + cópia juntos.
  final copiedSourceIds = <String>{
    for (final c in all)
      if (c.ownerId == uid && c.sourceId != null) c.sourceId!,
  };

  bool visible(Checklist c) {
    if (c.ownerId == uid) return true; // meus + cópias
    if (c.isStandard) {
      final inScope = scope.all ||
          (c.clientTypeId != null && scopedTypeIds.contains(c.clientTypeId));
      return inScope && !copiedSourceIds.contains(c.id);
    }
    // Sem dono e não-padrão (legado/de outro supervisor): não aparece.
    return false;
  }

  return all.where(visible).toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
});
