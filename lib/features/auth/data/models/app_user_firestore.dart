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
    email: (data['email'] as String?) ?? '',
    role: UserRole.fromName(data['role'] as String?),
    companyId: data['companyId'] as String?,
    phone: data['phone'] as String?,
    photoUrl: data['photoUrl'] as String?,
    jobTitle: data['jobTitle'] as String?,
    active: (data['active'] as bool?) ?? true,
    createdAt: toDate(data['createdAt']),
    updatedAt: toDate(data['updatedAt']),
  );
}

Map<String, dynamic> appUserToFirestore(AppUser user) => {
      'name': user.name,
      'email': user.email,
      'role': user.role.name,
      'companyId': user.companyId,
      'phone': user.phone,
      'photoUrl': user.photoUrl,
      'jobTitle': user.jobTitle,
      'active': user.active,
      'createdAt': Timestamp.fromDate(user.createdAt),
      'updatedAt': Timestamp.fromDate(user.updatedAt),
    };
