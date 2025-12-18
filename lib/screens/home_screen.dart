import 'package:flutter/material.dart';
import 'estoque_screen.dart';
import 'relatorios_screen.dart';
import 'scanner_screen.dart';
import 'alertas_screen.dart';
import 'config_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userLogin;
  const HomeScreen({super.key, required this.userLogin});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    EstoqueScreen(userLogin: widget.userLogin),
    const RelatoriosScreen(),
    const SizedBox(), // scanner é tratado separado
    const AlertasScreen(),
    const ConfigScreen(),
  ];

  void _onTap(int index) {
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ScannerScreen()),
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  Widget _navItem({
    required IconData icon,
    required int index,
  }) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(
                0,
                isActive ? -4 : 0,
                0,
              ),
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
              color: Colors.black.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  icon: Icons.inventory_2_outlined,
                  index: 0,
                ),
                _navItem(
                  icon: Icons.bar_chart,
                  index: 1,
                ),
                _scannerButton(),
                _navItem(
                  icon: Icons.notifications,
                  index: 3,
                ),
                _navItem(
                  icon: Icons.settings,
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
