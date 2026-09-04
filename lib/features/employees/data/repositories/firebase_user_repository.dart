import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/credentials.dart';
import '../../../auth/data/models/app_user_firestore.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/new_employee_result.dart';
import '../../domain/repositories/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users');

  @override
  Future<AppUser?> getById(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? appUserFromFirestore(doc.id, doc.data()!) : null;
  }

  @override
  Future<List<AppUser>> getAll({required String companyId}) async {
    final snap = await _col.where('companyId', isEqualTo: companyId).get();
    return snap.docs.map((d) => appUserFromFirestore(d.id, d.data())).toList();
  }

  @override
  Future<List<AppUser>> getEmployees({required String companyId}) async {
    final all = await getAll(companyId: companyId);
    return all.where((u) => u.role == UserRole.employee).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<NewEmployeeResult> createEmployee({
    required String companyId,
    required String contractId,
    required String clientId,
    required String name,
    required String cpf,
    String? email,
    String? phone,
    String? jobTitle,
  }) async {
    final digits = Credentials.cpfDigits(cpf);
    if (digits.length != 11) {
      throw const ValidationException('CPF inválido (11 dígitos).');
    }
    final trimmedEmail = email?.trim();

    // Cria a conta Auth + o perfil server-side (Cloud Function / Admin SDK),
    // sem afetar a sessão do supervisor.
    try {
      final result = await _functions.httpsCallable('createEmployee').call({
        'contractId': contractId,
        'clientId': clientId,
        'name': name,
        'cpf': cpf,
        'email': email,
        'phone': phone,
        'jobTitle': jobTitle,
      });
      final data = (result.data as Map).cast<String, dynamic>();
      final uid = data['uid'] as String;
      final tempPassword = data['temporaryPassword'] as String;
      final now = DateTime.now();
      final user = AppUser(
        id: uid,
        companyId: companyId,
        contractIds: [contractId],
        clientIds: [clientId],
        name: name.trim(),
        email: (trimmedEmail == null || trimmedEmail.isEmpty) ? null : trimmedEmail,
        cpf: digits,
        role: UserRole.employee,
        phone: phone?.trim(),
        jobTitle: jobTitle?.trim(),
        mustChangePassword: true,
        createdAt: now,
        updatedAt: now,
      );
      return NewEmployeeResult(user: user, temporaryPassword: tempPassword);
    } on FirebaseFunctionsException catch (e) {
      throw ValidationException(
          e.message ?? 'Não foi possível cadastrar o funcionário.');
    }
  }

  @override
  Future<AppUser> update({
    required String userId,
    required String name,
    String? email,
    String? phone,
    String? jobTitle,
  }) async {
    final ref = _col.doc(userId);
    final doc = await ref.get();
    if (!doc.exists) throw const NotFoundException('Usuário não encontrado.');
    final trimmedEmail = email?.trim();
    final updated = appUserFromFirestore(doc.id, doc.data()!).copyWith(
      name: name.trim(),
      email: (trimmedEmail == null || trimmedEmail.isEmpty) ? null : trimmedEmail,
      phone: phone?.trim(),
      jobTitle: jobTitle?.trim(),
      updatedAt: DateTime.now(),
    );
    await ref.set(appUserToFirestore(updated));
    return updated;
  }

  @override
  Future<void> delete(String userId) async {
    // Remove a conta Auth + o perfil server-side (Admin SDK). O cliente não
    // pode apagar a conta de acesso de outro usuário — daí a Cloud Function.
    try {
      await _functions
          .httpsCallable('deleteUserAccount')
          .call({'userId': userId});
    } on FirebaseFunctionsException catch (e) {
      throw ValidationException(
          e.message ?? 'Não foi possível excluir o usuário.');
    }
  }

  @override
  Future<AppUser> setActive({
    required String userId,
    required bool active,
  }) async {
    final ref = _col.doc(userId);
    await ref.update({'active': active, 'updatedAt': Timestamp.now()});
    final doc = await ref.get();
    return appUserFromFirestore(doc.id, doc.data()!);
  }

  @override
  Future<String> resetEmployeePassword(String employeeId) async {
    try {
      final result = await _functions
          .httpsCallable('resetEmployeePassword')
          .call({'employeeId': employeeId});
      final data = (result.data as Map).cast<String, dynamic>();
      final pwd = data['temporaryPassword'] as String?;
      if (pwd == null || pwd.isEmpty) {
        throw const ValidationException('Resposta inválida do servidor.');
      }
      return pwd;
    } on FirebaseFunctionsException catch (e) {
      throw ValidationException(
          e.message ?? 'Não foi possível redefinir a senha.');
    }
  }

  @override
  Future<AppUser> setContracts({
    required String userId,
    required List<String> contractIds,
    required List<String> clientIds,
  }) async {
    final ref = _col.doc(userId);
    await ref.update({
      'contractIds': contractIds,
      'clientIds': clientIds,
      'updatedAt': Timestamp.now(),
    });
    final doc = await ref.get();
    return appUserFromFirestore(doc.id, doc.data()!);
  }
}
