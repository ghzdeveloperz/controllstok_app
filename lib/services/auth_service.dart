// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= LOGIN =================
  Future<String?> login({
    required String login,
    required String password,
  }) async {
    try {
      // Buscar usuário pelo login na coleção 'users'
      final query = await _firestore
          .collection('users')
          .where('login', isEqualTo: login)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return 'Usuário não encontrado';
      }

      final userDoc = query.docs.first;
      final email = userDoc['email'] as String;

      // Login com Firebase Auth usando email
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return 'Erro ao autenticar usuário';

      // Checa se o email está verificado
      await user.reload();
      final updatedUser = _auth.currentUser;
      if (updatedUser != null && !updatedUser.emailVerified) {
        await updatedUser.sendEmailVerification();
        return 'Email não verificado. Um link de verificação foi enviado para seu email.';
      }

      return null; // Login bem-sucedido
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
    required String password,
  }) async {
    try {
      // Verifica se já existe usuário com mesmo login
      final query = await _firestore
          .collection('users')
          .where('login', isEqualTo: login)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return 'Login já está em uso';
      }

      // Cria usuário no Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return 'Erro ao criar usuário';

      // Envia email de verificação
      await user.sendEmailVerification();

      // Salva informações adicionais no Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'login': login,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Cadastro bem-sucedido
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'Email já está em uso';
      if (e.code == 'weak-password') return 'Senha muito fraca';
      return 'Erro ao cadastrar usuário: ${e.message}';
    } catch (e) {
      return 'Erro ao cadastrar usuário: $e';
    }
  }

  // ================= VERIFICA EMAIL =================
  Future<bool> checkEmailVerified() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      await user.reload(); // Atualiza info do Firebase
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
