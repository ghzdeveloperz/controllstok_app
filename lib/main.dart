import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // garante que async funciona
  await FirebaseService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ControlStok',
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      home: const LoginScreen(), // abrimos direto a tela de login
    );
  }
}
