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
      if (user == null) return 'Erro ao autenticar usuário';

      await user.reload();
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        return 'Email não verificado. Um link de verificação foi enviado para seu email.';
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') return 'Senha incorreta';
      if (e.code == 'user-not-found') return 'Usuário não encontrado';
      return 'Erro ao autenticar: ${e.message}';
    } catch (e) {
      return 'Erro ao autenticar: $e';
    }
  }

  // ================= REGISTER =================
  Future<String?> register({
    required String login,
    required String email,
    String temporaryPassword = 'Temporary123!', // senha temporária
  }) async {
    try {
      // Verifica se login já existe
      final query = await _firestore
          .collection('users')
          .where('login', isEqualTo: login)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) return 'Login já está em uso';

      // Cria usuário com senha temporária
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: temporaryPassword,
      );

      final user = credential.user;
      if (user == null) return 'Erro ao criar usuário';

      // Envia email de verificação
      await user.sendEmailVerification();

      // Salva dados no Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'login': login,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isTemporaryPassword': true, // marca que ainda não atualizou a senha
      });

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'Email já está em uso';
      if (e.code == 'weak-password') return 'Senha muito fraca';
      return 'Erro ao cadastrar usuário: ${e.message}';
    } catch (e) {
      return 'Erro ao cadastrar usuário: $e';
    }
  }

  // ================= UPDATE PASSWORD =================
  Future<String?> updatePassword({
    required String newPassword,
    String? currentPassword, // atual senha, se existir
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return 'Usuário não autenticado';

      // Reautentica se necessário
      if (currentPassword != null) {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(cred);
      }

      // Atualiza senha
      await user.updatePassword(newPassword);

      // Atualiza flag no Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'isTemporaryPassword': false,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Por favor, faça login novamente antes de alterar a senha';
      }
      return 'Erro ao atualizar senha: ${e.message}';
    } catch (e) {
      return 'Erro ao atualizar senha: $e';
    }
  }

  // ================= RESET PASSWORD =================
  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Link de redefinição enviado para seu e-mail";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'Usuário não encontrado';
      if (e.code == 'invalid-email') return 'Email inválido';
      return e.message ?? "Erro ao enviar email de redefinição";
    } catch (e) {
      return 'Erro ao enviar email de redefinição: $e';
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
