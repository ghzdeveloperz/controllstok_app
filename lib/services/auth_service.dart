import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';

class AuthService {
  final _db = FirebaseFirestore.instance;

  /// Tenta logar o usuário.
  /// Retorna `null` se sucesso, ou string com a mensagem de erro.
  Future<String?> login({
    required String login,
    required String password,
  }) async {
    try {
      final query = await _db
          .collection('users')
          .where('login', isEqualTo: login.toLowerCase())
          .get();

      if (query.docs.isEmpty) {
        return 'Login ou senha incorretos';
      }

      for (final doc in query.docs) {
        final data = doc.data();

        final bool isActive = data['active'] ?? true;
        final hash = data['passwordHash'] as String?;
        if (hash == null) continue;

        final passwordMatch = BCrypt.checkpw(password, hash);

        if (!isActive) return 'Usuário desativado';
        if (passwordMatch) return null; // login OK
      }

      return 'Login ou senha incorretos';
    } catch (e) {
      return 'Erro ao conectar com o servidor';
    }
  }
}
