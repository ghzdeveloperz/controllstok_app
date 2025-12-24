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
      final email = userDoc['email'];

      // Login com Firebase Auth usando email
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null; // Login bem-sucedido
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') return 'Senha incorreta';
      if (e.code == 'user-not-found') return 'Usuário não encontrado';
      return 'Erro ao autenticar';
    } catch (e) {
      return e.toString();
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
      return 'Erro ao cadastrar usuário';
    } catch (e) {
      return e.toString();
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Usuário atual
  User? get currentUser => _auth.currentUser;
}
