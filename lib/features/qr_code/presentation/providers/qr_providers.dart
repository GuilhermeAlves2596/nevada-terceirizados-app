import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/repository_providers.dart';
import '../../domain/qr_resolver.dart';

final qrResolverProvider = Provider<QrResolver>((ref) {
  return QrResolver(
    ref.watch(locationRepositoryProvider),
    ref.watch(taskRepositoryProvider),
  );
});
