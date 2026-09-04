import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/checklist.dart';

/// Checklists são **templates reutilizáveis da empresa** (não pertencem a um
/// contrato específico), então não são filtrados por escopo — todo supervisor
/// vê todos os checklists da empresa.
final checklistsProvider =
    FutureProvider.autoDispose<List<Checklist>>((ref) async {
  final companyId = ref.watch(currentUserProvider)?.companyId;
  if (companyId == null) return const [];
  return ref.watch(checklistRepositoryProvider).getAll(companyId: companyId);
});
