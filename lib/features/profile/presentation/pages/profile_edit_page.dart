import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/snackbars.dart';
import '../../../../core/widgets/app_form_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Edição do próprio perfil (nome e telefone). A regra de self-update das
/// Security Rules permite alterar esses campos, mas nunca role/companyId.
class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _name = TextEditingController(text: user?.name ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final error = await ref.read(authControllerProvider.notifier).updateProfile(
          name: _name.text,
          phone: _phone.text,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      showErrorSnack(context, error);
      return;
    }
    showSuccessSnack(context, 'Perfil atualizado.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormScaffold(
      title: 'Editar perfil',
      formKey: _formKey,
      submitting: _saving,
      onSubmit: _save,
      children: [
        AppTextFormField(
          label: 'Nome',
          controller: _name,
          required: true,
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        AppTextFormField(
          label: 'Telefone',
          controller: _phone,
          hint: '(00) 00000-0000',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
        ),
      ],
    );
  }
}
