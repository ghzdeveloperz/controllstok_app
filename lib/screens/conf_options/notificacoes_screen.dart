import 'package:flutter/material.dart';

class NotificacoesScreen extends StatelessWidget {
  const NotificacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Alertas de estoque: Ativo', style: TextStyle(fontSize: 18)),
            SizedBox(height: 12),
            Text('Notificações do app: Ativo', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
