// lib/main.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/firebase_service.dart';
import 'screens/acounts/auth_choice/auth_choice_screen.dart';
import 'screens/acounts/register/register_screen.dart';
import 'screens/home_screen.dart';
import 'notifications/notification_service.dart';
import 'notifications/save_fcm_token.dart';

/// 🔹 GlobalKey para navegar fora do context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 🔹 Handler para mensagens em background e app killed
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await FirebaseService.init();
  debugPrint('📩 Mensagem recebida em background/killed: ${message.data}');

  final data = message.data;
  if (data.containsKey('productName')) {
    await NotificationService.instance.showStockNotification(
      productName: data['productName'] ?? 'Produto',
      quantity: int.tryParse(data['quantity'] ?? '0') ?? 0,
      isCritical: data['isCritical'] == 'true',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Firebase
  await FirebaseService.init();

  // 🔹 Notificações locais (foreground e background)
  await NotificationService.instance.init();

  // 🔹 Handler background (obrigatório)
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  // 🔹 Date formatting
  await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'ControlStok',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: baseTextTheme,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _tokenSaved = false;
  Map<String, dynamic>? _pendingNotification;

  // ✅ chaves usadas no RegisterController
  static const _kPendingEmail = 'register_pending_email';
  static const _kPendingTempPass = 'register_pending_temp_pass';

  @override
  void initState() {
    super.initState();

    // 🔹 Listener de notificações em foreground (app aberto)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final data = message.data;
      debugPrint('📩 Mensagem recebida em foreground: $data');

      if (data.containsKey('productName')) {
        await NotificationService.instance.showStockNotification(
          productName: data['productName'] ?? 'Produto',
          quantity: int.tryParse(data['quantity'] ?? '0') ?? 0,
          isCritical: data['isCritical'] == 'true',
        );
      }
    });

    // 🔹 Listener de clique em notificações (background ou app aberto)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _pendingNotification = message.data;
      _tryNavigate();
    });

    // 🔹 Notificação que abriu o app quando estava fechado
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _pendingNotification = message.data;
        _tryNavigate();
      }
    });
  }

  Future<bool> _hasPendingRegister() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_kPendingEmail);
    final pass = prefs.getString(_kPendingTempPass);
    return email != null && pass != null;
  }

  // 🔹 Tenta navegar para HomeScreen na aba Alertas se o usuário estiver logado
  // ✅ MAS: não navega se houver cadastro pendente
  Future<void> _tryNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_pendingNotification == null || user == null) return;

    final pending = await _hasPendingRegister();
    if (pending) {
      // usuário temporário logado → não deve ir pra Home
      return;
    }

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(initialIndex: 4),
      ),
      (route) => false,
    );

    _pendingNotification = null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Erro ao autenticar: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        // ✅ usuário logado (pode ser temporário)
        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: _hasPendingRegister(),
            builder: (context, pendingSnap) {
              if (pendingSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final pending = pendingSnap.data == true;

              // ✅ Se existir cadastro pendente, fica no Register (não Home)
              if (pending) {
                _tokenSaved = false; // não salva token como sessão "final"
                return const RegisterScreen();
              }

              /// 🔑 Salva o token FCM UMA VEZ por sessão (somente quando é login final)
              if (!_tokenSaved) {
                _tokenSaved = true;
                saveFcmTokenIfLoggedIn();

                // Caso haja notificação pendente após login final, navega
                _tryNavigate();
              }

              return const HomeScreen();
            },
          );
        }

        _tokenSaved = false;
        return const AuthChoiceScreen();
      },
    );
  }
}
