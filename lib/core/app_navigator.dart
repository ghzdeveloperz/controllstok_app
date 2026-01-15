import 'package:flutter/material.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static NavigatorState? get _nav => key.currentState;

  static void resetTo(Widget screen) {
    final nav = _nav;
    if (nav == null) return;

    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  static Future<T?> push<T>(Widget screen) {
    final nav = _nav;
    if (nav == null) return Future.value(null);

    return nav.push<T>(MaterialPageRoute(builder: (_) => screen));
  }

  static void pop() => _nav?.pop();
}
