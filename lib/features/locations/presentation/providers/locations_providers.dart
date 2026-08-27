import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/location.dart';

final locationsProvider =
    FutureProvider.autoDispose<List<Location>>((ref) async {
  final companyId = ref.watch(currentUserProvider)?.companyId;
  if (companyId == null) return const [];
  return ref.watch(locationRepositoryProvider).getAll(companyId: companyId);
});
