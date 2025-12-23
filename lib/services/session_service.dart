//lib/services/session_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _userIdKey = 'user_login';

  /// Salva o login do usuário
  static Future<void> saveuserId(String login) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, login);
  }

  /// Recupera o login salvo (ou null)
  static Future<String?> getuserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Limpa a sessão do usuário
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }
}
