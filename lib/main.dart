// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'services/firebase_service.dart';
import 'services/session_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase e notificações
  await FirebaseService.init();
  await NotificationService.instance.init();

  // Inicializa locale pt_BR
  await initializeDateFormatting('pt_BR', null);

  // Recupera login do usuário
  final userLogin = await SessionService.getUserLogin();

  runApp(MyApp(initialLogin: userLogin));
}

class MyApp extends StatelessWidget {
  final String? initialLogin;

  const MyApp({super.key, required this.initialLogin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ControlStok',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      home: initialLogin == null
          ? const LoginScreen()
          : HomeScreen(userLogin: initialLogin!),
    );
  }
}
