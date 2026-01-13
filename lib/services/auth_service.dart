// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= LOGIN =================
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return 'Erro ao autenticar usuário';
      }

      await user.reload();

      if (!user.emailVerified) {
        await user.sendEmailVerification();
        return 'E-mail não verificado. Enviamos um link de verificação para seu e-mail.';
      }

      return null;
    } on FirebaseAuthException catch (e) {
      // 🔥 Mensagens humanas e padronizadas
      switch (e.code) {
        case 'wrong-password':
        case 'user-not-found':
        case 'invalid-credential':
          return 'E-mail ou senha incorretos';

        case 'invalid-email':
          return 'E-mail inválido';

        case 'too-many-requests':
          return 'Muitas tentativas. Tente novamente mais tarde';

        case 'network-request-failed':
          return 'Erro de conexão. Verifique sua internet';

        default:
          return 'Erro ao autenticar. Tente novamente';
      }
    } catch (_) {
      return 'Erro inesperado ao autenticar';
    }
  }

  // ================= REGISTER =================
  Future<String?> register({
    required String login,
    required String email,
    String temporaryPassword = 'Temporary123!',
  }) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('login', isEqualTo: login)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return 'Login já está em uso';
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: temporaryPassword,
      );

      final user = credential.user;
      if (user == null) {
        return 'Erro ao criar usuário';
      }

      await user.sendEmailVerification();

      await _firestore.collection('users').doc(user.uid).set({
        'login': login,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isTemporaryPassword': true,
        'active': true,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'E-mail já está em uso';
        case 'invalid-email':
          return 'E-mail inválido';
        case 'weak-password':
          return 'Senha muito fraca';
        default:
          return 'Erro ao cadastrar usuário';
      }
    } catch (_) {
      return 'Erro inesperado ao cadastrar usuário';
    }
  }

  // ================= UPDATE PASSWORD =================
  Future<String?> updatePassword({
    required String newPassword,
    String? currentPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return 'Usuário não autenticado';
      }

      if (currentPassword != null) {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(cred);
      }

      await user.updatePassword(newPassword);

      await _firestore.collection('users').doc(user.uid).update({
        'isTemporaryPassword': false,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Faça login novamente antes de alterar a senha';
      }
      return 'Erro ao atualizar a senha';
    } catch (_) {
      return 'Erro inesperado ao atualizar a senha';
    }
  }

  // ================= RESET PASSWORD =================
  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'Enviamos um link de redefinição para seu e-mail';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuário não encontrado';
        case 'invalid-email':
          return 'E-mail inválido';
        default:
          return 'Erro ao enviar e-mail de redefinição';
      }
    } catch (_) {
      return 'Erro inesperado ao redefinir senha';
    }
  }

  // ================= VERIFICA EMAIL =================
  Future<bool> checkEmailVerified() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      await user.reload();
      user = _auth.currentUser;

      return user?.emailVerified ?? false;
    } catch (_) {
      return false;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ================= USUÁRIO ATUAL =================
  User? get currentUser => _auth.currentUser;
}
