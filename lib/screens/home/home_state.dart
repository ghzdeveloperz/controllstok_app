// C:\projetos vs\ControlStok\mystoreday_app\lib\screens\home\home_state.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../acounts/login/login_screen.dart';
import '../models/product.dart';
import '../widgets/desactive_acount.dart';

import 'home_tabs.dart';

typedef SetStateFn = void Function(VoidCallback fn);

class HomeStateController {
  HomeStateController({required int initialIndex})
    : _currentIndex = initialIndex;

  int _currentIndex;
  int get currentIndex => _currentIndex;

  String? _uid;
  String? get uid => _uid;

  List<Widget>? _screens;
  List<Widget>? get screens => _screens;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

  // cache de produtos (precache imagens)
  List<Product> _products = [];

  Future<void> init({
    required BuildContext context,
    required SetStateFn setState,
    required bool Function() isMounted,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      return;
    }

    _uid = user.uid;

    _screens = HomeTabs.build(
      uid: _uid!,
      onProductsLoaded: (products) => _onProductsLoaded(context, products),
      onProductSaved: () => _onProductSaved(context, setState, isMounted),
    );

    _listenUserActiveStatus(context, isMounted);

    if (isMounted()) setState(() {});
  }

  void dispose() {
    _userSub?.cancel();
  }

  void onTap({
    required BuildContext context,
    required int index,
    required SetStateFn setState,
  }) {
    if (index == HomeTabs.scannerIndex) {
      HomeTabs.openScanner(context, uid: _uid!);

      return;
    }

    setState(() => _currentIndex = index);
  }

  void _onProductsLoaded(BuildContext context, List<Product> products) {
    _products = products;

    for (final product in _products) {
      if (product.image.isNotEmpty) {
        precacheImage(NetworkImage(product.image), context);
      }
    }
  }

  void _onProductSaved(
    BuildContext context,
    SetStateFn setState,
    bool Function() isMounted,
  ) {
    if (!isMounted()) return;

    setState(() => _currentIndex = HomeTabs.estoqueIndex);

    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.homeProductSavedSuccess)),
          ],
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _listenUserActiveStatus(
    BuildContext context,
    bool Function() isMounted,
  ) {
    if (_uid == null) return;

    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid!)
        .snapshots();

    _userSub = stream.listen((doc) async {
      if (!isMounted()) return;

      if (!doc.exists) return;

      final data = doc.data();
      final active = data?['active'];

      if (active == false) {
        final l10n = AppLocalizations.of(context)!;

        await FirebaseAuth.instance.signOut();
        if (!isMounted()) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => CustomAlertDialog(
            title: l10n.homeAccountDeactivatedTitle,
            message: l10n.homeAccountDeactivatedMessage,
            buttonText: l10n.commonOk,
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        );
      }
    });
  }
}
