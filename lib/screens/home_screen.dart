import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'estoque_screen.dart';
import 'novo_produto_screen.dart';
import 'scanner_screen.dart';
import 'relatorios_screen.dart';
import 'config_screen.dart';
import '../notifications/notification_service.dart';
import 'login_screen.dart';
import '../screens/widgets/desactive_acount.dart'; // CustomAlertDialog

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget>? _screens;
  bool _notificationsStarted = false;
  String? _uid;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;

  @override
  void initState() {
    super.initState();
    _initUserAndScreens();
  }

  Future<void> _initUserAndScreens() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    _uid = user.uid;

    _screens = [
      EstoqueScreen(uid: _uid!), // 0 Estoque
      NovoProdutoScreen(uid: _uid!), // 1 Novo Produto
      const SizedBox(), // 2 Scanner (abre modal)
      const RelatoriosDays(), // 3 Relatórios
      const ConfigScreen(), // 4 Configurações
    ];

    await _initNotifications();
    _listenUserActiveStatus();

    if (mounted) setState(() {});
  }

  void _listenUserActiveStatus() {
    if (_uid == null) return;

    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid!)
        .snapshots();

    _userStream!.listen((doc) {
      if (!mounted) return;
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['active'] == false) {
          FirebaseAuth.instance.signOut();

          // Impede o usuário de permanecer na HomeScreen
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => CustomAlertDialog(
              title: "Conta desativada",
              message:
                  "Sua conta foi desativada. Entre em contato com o suporte.",
              buttonText: "OK",
              onPressed: () {
                // Fecha todas as telas e envia para LoginScreen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          );
        }
      }
    });
  }

  Future<void> _initNotifications() async {
    if (_notificationsStarted || _uid == null) return;
    _notificationsStarted = true;

    await NotificationService.instance.init();
    if (!mounted) return;

    NotificationService.instance.startListeningStockAlerts(_uid!);
  }

  void _onTap(int index) {
    if (index == 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ScannerScreen(uid: _uid!)));
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _navItem({required IconData icon, required int index}) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.translationValues(0, isActive ? -4 : 0, 0),
              child: Icon(
                icon,
                size: 26,
                color: isActive ? Colors.black : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              width: isActive ? 16 : 0,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scannerButton() {
    return GestureDetector(
      onTap: () => _onTap(2),
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.document_scanner,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  @override
  void dispose() {
    NotificationService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_screens == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: _screens!),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 72,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 212, 31, 31),
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(icon: Icons.inventory_2_outlined, index: 0),
                  _navItem(icon: Icons.add_business_outlined, index: 1),
                  _scannerButton(),
                  _navItem(icon: Icons.bar_chart, index: 3),
                  _navItem(icon: Icons.settings, index: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
