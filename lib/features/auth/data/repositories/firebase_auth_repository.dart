import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/credentials.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_firestore.dart';

/// Implementação real da autenticação (Fase 8).
///
/// Autentica via Firebase Authentication e carrega o perfil do usuário
/// (role/companyId) do Firestore em `/users/{uid}`.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Future<AppUser> signIn({
    required String identifier,
    required String password,
  }) async {
    try {
      final email = Credentials.resolveLoginEmail(identifier);
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user!;
      return _loadProfile(user.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_messageFor(e));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<AppUser> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthenticationException('Sessão expirada. Entre novamente.');
    }
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_messageFor(e));
    }
    await _users.doc(user.uid).update({
      'mustChangePassword': false,
      'updatedAt': Timestamp.now(),
    });
    final doc = await _users.doc(user.uid).get();
    return appUserFromFirestore(user.uid, doc.data()!);
  }

  @override
  Future<AppUser?> currentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _users.doc(user.uid).get();
    if (!doc.exists) return null;
    return appUserFromFirestore(user.uid, doc.data()!);
  }

  /// Carrega o perfil do Firestore após a autenticação.
  ///
  /// A partir da Fase 12 (Security Rules) **não** há auto-provisionamento: o
  /// usuário não pode se criar sozinho (seria escalonamento de privilégio). O
  /// perfil é provisionado pelo gestor/plataforma. Sem perfil → desloga e erra.
  Future<AppUser> _loadProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) return appUserFromFirestore(uid, doc.data()!);

    await _auth.signOut();
    throw const AuthenticationException(
      'Seu acesso ainda não foi liberado. Contate o administrador.',
    );
  }

  String _messageFor(FirebaseAuthException e) => switch (e.code) {
        'invalid-email' => 'E-mail inválido.',
        'user-disabled' => 'Este usuário está desativado.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'E-mail ou senha inválidos.',
        'too-many-requests' =>
          'Muitas tentativas. Aguarde um momento e tente novamente.',
        'network-request-failed' =>
          'Sem conexão. Verifique sua internet e tente novamente.',
        'weak-password' => 'A senha deve ter pelo menos 6 caracteres.',
        'requires-recent-login' =>
          'Por segurança, entre novamente para trocar a senha.',
        _ => 'Não foi possível entrar. Tente novamente.',
      };
}
