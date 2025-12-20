import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:controllstok_app/main.dart';

void main() {
  testWidgets('App inicia sem crash', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MyApp(initialLogin: null),
    );

    // Apenas verifica se o app construiu sem erro
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
