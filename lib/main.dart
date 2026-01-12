// lib/main.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'services/firebase_service.dart';
import 'screens/acounts/login/login_screen.dart';
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
      navigatorKey: navigatorKey, // ← essencial para navegação global
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

  // 🔹 Tenta navegar para HomeScreen na aba Alertas se o usuário estiver logado
  void _tryNavigate() {
    final user = FirebaseAuth.instance.currentUser;
    if (_pendingNotification != null && user != null) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeScreen(initialIndex: 4), // aba Alertas
        ),
        (route) => false,
      );
      _pendingNotification = null; // limpa pending
    }
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

        if (snapshot.hasData) {
          /// 🔑 Salva o token FCM UMA VEZ por sessão
          if (!_tokenSaved) {
            _tokenSaved = true;
            saveFcmTokenIfLoggedIn();

            // Caso haja notificação pendente após login, navega
            _tryNavigate();
          }

          return const HomeScreen(); // default aba Estoque
        }

        _tokenSaved = false;
        return const LoginScreen();
      },
    );
  }
}
