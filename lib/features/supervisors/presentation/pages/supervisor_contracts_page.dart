import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/repository_providers.dart';
import '../../../../app/providers/company_catalog.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../employees/presentation/providers/employees_providers.dart';

/// Vínculo (feito pelo gestor) dos contratos que um supervisor atende.
class SupervisorContractsPage extends ConsumerStatefulWidget {
  const SupervisorContractsPage({super.key, required this.supervisor});

  final AppUser supervisor;

  @override
  ConsumerState<SupervisorContractsPage> createState() =>
      _SupervisorContractsPageState();
}

class _SupervisorContractsPageState
    extends ConsumerState<SupervisorContractsPage> {
  late final Set<String> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.supervisor.contractIds.toSet();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final catalog = await ref.read(companyCatalogProvider.future);
      // Deriva os clientes a partir dos contratos selecionados (denormalizado
      // no doc do supervisor para permitir o filtro de clientes).
      final clientIds = <String>{
        for (final id in _selected)
          if (catalog.contractsById[id] != null)
            catalog.contractsById[id]!.clientId,
      };
      await ref.read(userRepositoryProvider).setContracts(
            userId: widget.supervisor.id,
            contractIds: _selected.toList(),
            clientIds: clientIds.toList(),
          );
      ref.invalidate(companySupervisorsProvider);
      if (!mounted) return;
      showSuccessSnack(
        context,
        'Contratos de ${widget.supervisor.firstName} atualizados.',
      );
      context.pop();
    } on AppException catch (e) {
      if (mounted) showErrorSnack(context, e.message);
    } catch (_) {
      if (mounted) showErrorSnack(context, 'Não foi possível salvar os vínculos.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(companyCatalogProvider);
    return Scaffold(
      appBar: AppBar(title: Text(widget.supervisor.name)),
      body: catalogAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorState(
          onRetry: () => ref.invalidate(companyCatalogProvider),
        ),
        data: (catalog) {
          final contracts = catalog.contractsById.values.toList()
            ..sort((a, b) => a.name.compareTo(b.name));
          if (contracts.isEmpty) {
            return const AppEmptyState(
              message: 'Nenhum contrato cadastrado na empresa.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                'Marque os contratos que ${widget.supervisor.firstName} atende. '
                'Ele verá apenas os dados desses contratos, e os funcionários que '
                'cadastrar herdam um deles.',
                style: AppTypography.bodyMuted,
              ),
              AppSpacing.gapMd,
              for (final c in contracts)
                CheckboxListTile(
                  value: _selected.contains(c.id),
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selected.add(c.id);
                    } else {
                      _selected.remove(c.id);
                    }
                  }),
                  title: Text(c.name),
                  subtitle:
                      Text(catalog.clientsById[c.clientId]?.name ?? 'Cliente'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: AppButton(
          label: 'Salvar vínculos',
          icon: Icons.check,
          loading: _saving,
          onPressed: _save,
        ),
      ),
    );
  }
}
