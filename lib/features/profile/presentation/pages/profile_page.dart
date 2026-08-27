import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
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
                      const Divider(height: 1),
                      _InfoRow(
                        icon: Icons.mail_outline,
                        label: 'E-mail',
                        value: user.email,
                      ),
                      if (user.phone != null) ...[
                        const Divider(height: 1),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Telefone',
                          value: user.phone!,
                        ),
                      ],
                    ],
                  ),
                ),
                AppSpacing.gapXl,
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
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 14),
          Text(label, style: AppTypography.bodyMuted),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: AppTypography.subtitle,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
