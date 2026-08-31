import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/enums/user_role.dart';
import '../../domain/entities/app_user.dart';

/// Conversão entre o documento Firestore `/users/{uid}` e a entidade [AppUser].
///
/// Mantém a serialização na camada de dados — o domínio permanece puro.
AppUser appUserFromFirestore(String id, Map<String, dynamic> data) {
  DateTime toDate(dynamic v) =>
      v is Timestamp ? v.toDate() : (v is DateTime ? v : DateTime.now());

  return AppUser(
    id: id,
    name: (data['name'] as String?) ?? '',
    email: data['email'] as String?,
    cpf: data['cpf'] as String?,
    role: UserRole.fromName(data['role'] as String?),
    companyId: data['companyId'] as String?,
    contractIds: (data['contractIds'] as List?)?.cast<String>() ?? const [],
    clientIds: (data['clientIds'] as List?)?.cast<String>() ?? const [],
    phone: data['phone'] as String?,
    photoUrl: data['photoUrl'] as String?,
    jobTitle: data['jobTitle'] as String?,
    mustChangePassword: (data['mustChangePassword'] as bool?) ?? false,
    active: (data['active'] as bool?) ?? true,
    createdAt: toDate(data['createdAt']),
    updatedAt: toDate(data['updatedAt']),
  );
}

Map<String, dynamic> appUserToFirestore(AppUser user) => {
      'name': user.name,
      'email': user.email,
      'cpf': user.cpf,
      'role': user.role.name,
      'companyId': user.companyId,
      'contractIds': user.contractIds,
      'clientIds': user.clientIds,
      'phone': user.phone,
      'photoUrl': user.photoUrl,
      'jobTitle': user.jobTitle,
      'mustChangePassword': user.mustChangePassword,
      'active': user.active,
      'createdAt': Timestamp.fromDate(user.createdAt),
      'updatedAt': Timestamp.fromDate(user.updatedAt),
    };
