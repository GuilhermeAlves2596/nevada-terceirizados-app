import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Cabeçalho comum aos dashboards: saudação, subtítulo e menu do usuário.
class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({
    super.key,
    required this.subtitle,
    required this.profilePath,
    this.actions = const [],
  });

  final String subtitle;
  final String profilePath;

  /// Ações opcionais exibidas antes do avatar (ex.: atalho para o histórico).
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Olá, ${user.firstName}!', style: AppTypography.headline),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.bodyMuted),
            ],
          ),
        ),
        ...actions,
        PopupMenuButton<String>(
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                context.push(profilePath);
              case 'logout':
                ref.read(authControllerProvider.notifier).signOut();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: _menuRow(Icons.person_outline, 'Meu perfil'),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: _menuRow(Icons.logout, 'Sair', color: AppColors.danger),
            ),
          ],
          child: AppAvatar(initials: user.initials, imageUrl: user.photoUrl),
        ),
      ],
    );
  }

  Widget _menuRow(IconData icon, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.textPrimary),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTypography.body.copyWith(color: color),
        ),
      ],
    );
  }
}

/// Atalho para os caminhos de perfil de cada perfil de acesso.
class ProfilePaths {
  const ProfilePaths._();
  static const employee = RoutePaths.employeeProfile;
  static const supervisor = RoutePaths.supervisorProfile;
}
