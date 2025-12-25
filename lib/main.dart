// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/firebase_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Try/catch para evitar travamento na inicialização
  try {
    await FirebaseService.init();
  } catch (e, st) {
    debugPrint('Erro ao inicializar Firebase: $e');
    debugPrint('$st');
  }

  try {
    await NotificationService.instance.init();
  } catch (e, st) {
    debugPrint('Erro ao inicializar NotificationService: $e');
    debugPrint('$st');
  }

  try {
    await initializeDateFormatting('pt_BR', null);
  } catch (e, st) {
    debugPrint('Erro ao inicializar DateFormatting: $e');
    debugPrint('$st');
  }

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
        textTheme: baseTextTheme.copyWith(
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(decoration: TextDecoration.none),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(decoration: TextDecoration.none),
          bodySmall: baseTextTheme.bodySmall?.copyWith(decoration: TextDecoration.none),
          titleLarge: baseTextTheme.titleLarge?.copyWith(decoration: TextDecoration.none),
          titleMedium: baseTextTheme.titleMedium?.copyWith(decoration: TextDecoration.none),
          titleSmall: baseTextTheme.titleSmall?.copyWith(decoration: TextDecoration.none),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔹 Tela de loading com timeout visual
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔹 Mostra erro caso algo falhe na stream
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Erro ao autenticar: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        // 🔹 Usuário logado
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // 🔹 Usuário não logado
        return const LoginScreen();
      },
    );
  }
}
