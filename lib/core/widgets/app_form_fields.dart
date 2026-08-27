import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Dropdown com rótulo, padronizado para formulários.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
    this.validator,
    this.enabled = true,
    this.hint,
    this.required = false,
    this.fieldKey,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? icon;
  final String? Function(T?)? validator;
  final bool enabled;
  final String? hint;
  final bool required;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, required: required),
        AppSpacing.gapXs,
        DropdownButtonFormField<T>(
          key: fieldKey,
          initialValue: value,
          isExpanded: true,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator ??
              (required ? (v) => v == null ? 'Selecione uma opção' : null : null),
          decoration: InputDecoration(
            prefixIcon:
                icon == null ? null : Icon(icon, color: AppColors.textMuted, size: 20),
            hintText: enabled ? (hint ?? 'Selecione') : (hint ?? 'Indisponível'),
          ),
        ),
      ],
    );
  }
}

/// Campo de data (abre um date picker ao tocar).
class AppDatePickerField extends StatelessWidget {
  const AppDatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.icon = Icons.event_outlined,
    this.placeholder = 'Selecionar',
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final IconData icon;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, required: false),
        AppSpacing.gapXs,
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            ),
            child: Text(
              hasValue ? value! : placeholder,
              style: hasValue ? AppTypography.body : AppTypography.bodyMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.required});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: AppTypography.subtitle,
        children: required
            ? const [
                TextSpan(text: ' *', style: TextStyle(color: AppColors.danger)),
              ]
            : null,
      ),
    );
  }
}
