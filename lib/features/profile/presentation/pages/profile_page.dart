import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/theme_mode_provider.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/credentials.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: user == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Center(
                  child: Column(
                    children: [
                      AppAvatar(
                        initials: user.initials,
                        imageUrl: user.photoUrl,
                        radius: 44,
                      ),
                      AppSpacing.gapMd,
                      Text(user.name, style: AppTypography.headline),
                      const SizedBox(height: 2),
                      Text(
                        user.jobTitle ?? user.role.label,
                        style: AppTypography.bodyMuted,
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapXl,
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Perfil',
                        value: user.role.label,
                      ),
                      if (user.cpf != null) ...[
                        const Divider(height: 1),
                        _InfoRow(
                          icon: Icons.fingerprint,
                          label: 'CPF',
                          value: Credentials.formatCpf(user.cpf!),
                        ),
                      ],
                      if (user.email != null && user.email!.isNotEmpty) ...[
                        const Divider(height: 1),
                        _InfoRow(
                          icon: Icons.mail_outline,
                          label: 'E-mail',
                          value: user.email!,
                        ),
                      ],
                      if (user.phone != null) ...[
                        const Divider(height: 1),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Telefone',
                          value: Credentials.formatPhone(user.phone!),
                        ),
                      ],
                    ],
                  ),
                ),
                AppSpacing.gapXl,
                Text('Aparência', style: AppTypography.subtitle),
                AppSpacing.gapSm,
                _ThemeSelector(
                  mode: ref.watch(themeModeProvider),
                  onChanged: (m) =>
                      ref.read(themeModeProvider.notifier).setMode(m),
                ),
                AppSpacing.gapXl,
                AppButton(
                  label: 'Editar perfil',
                  icon: Icons.edit_outlined,
                  onPressed: () => context.push(
                    user.isEmployee
                        ? RoutePaths.employeeProfileEdit
                        : RoutePaths.supervisorProfileEdit,
                  ),
                ),
                AppSpacing.gapMd,
                AppButton(
                  label: 'Sair da conta',
                  icon: Icons.logout,
                  variant: AppButtonVariant.outline,
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                ),
              ],
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.c.textMuted),
          const SizedBox(width: 14),
          SizedBox(
            width: 92,
            child: Text(label, style: AppTypography.bodyMuted),
          ),
          Expanded(
            child: Text(value, style: AppTypography.subtitle),
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
        ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
        ButtonSegment(value: ThemeMode.dark, label: Text('Escuro')),
      ],
      selected: {mode},
      showSelectedIcon: false,
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
