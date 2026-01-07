// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'services/firebase_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'notifications/notification_service.dart';
import 'notifications/save_fcm_token.dart';

/// 🔹 Handler para mensagens em background
/// ⚠️ NÃO cria notificação aqui
/// O Android já cria automaticamente se vier `notification` no payload
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 Mensagem recebida em background: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Firebase
  await FirebaseService.init();

  // 🔹 Notificações locais
  await NotificationService.instance.init();

  // 🔹 Handler background (obrigatório)
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  // 🔹 DateFormatting
  await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();

    return MaterialApp(
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

  @override
  void initState() {
    super.initState();

    /// Aqui o Android NÃO exibe notificação sozinho
    FirebaseMessaging.onMessage.listen((message) {
      final data = message.data;

      if (data.containsKey('productName')) {
        NotificationService.instance.showStockNotification(
          productName: data['productName'] ?? 'Produto',
          quantity: int.tryParse(data['quantity'] ?? '0') ?? 0,
          isCritical: data['isCritical'] == 'true',
          productImageUrl: data['productImageUrl'],
        );
      }
    });

    /// 📲 Clique na notificação
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('📲 Notificação clicada: ${message.data}');
    });
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
          }

          return const HomeScreen();
        }

        _tokenSaved = false;
        return const LoginScreen();
      },
    );
  }
}
