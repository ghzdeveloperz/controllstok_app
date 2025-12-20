import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/firebase_service.dart';
import 'services/session_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService.init();
  await NotificationService.instance.init();

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
      home: initialLogin == null
          ? const LoginScreen()
          : HomeScreen(userLogin: initialLogin!),
    );
  }
}
