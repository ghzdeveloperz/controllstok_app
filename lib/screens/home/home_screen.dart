// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';

import 'home_state.dart';
import 'home_tabs.dart';
import 'widgets/home_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  final int? initialIndex; // aba inicial opcional

  const HomeScreen({super.key, this.initialIndex});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late final HomeStateController controller;

  @override
  void initState() {
    super.initState();

    controller = HomeStateController(
      initialIndex: widget.initialIndex ?? HomeTabs.estoqueIndex,
    );

    // init precisa rodar após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.init(
        context: context,
        setState: setState,
        isMounted: () => mounted,
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    controller.onTap(
      context: context,
      index: index,
      setState: setState,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = controller.screens ?? const [SizedBox()];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: controller.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: controller.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
