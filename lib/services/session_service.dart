  import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _userLoginKey = 'user_login';

  /// Salva o login do usuário
  static Future<void> saveUserLogin(String login) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userLoginKey, login);
  }

  /// Recupera o login salvo (ou null)
  static Future<String?> getUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userLoginKey);
  }

  /// Limpa a sessão do usuário
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userLoginKey);
  }
}
