import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  DateTime? _lastNotificationTime;
  StreamSubscription? _subscription;

  static const String _channelId = 'stock_alerts';

  /// 🔔 Inicializa notificações locais + cria canal Android
  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/logo_controllstok');

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    // ✅ CANAL ANDROID (OBRIGATÓRIO)
    const channel = AndroidNotificationChannel(
      _channelId,
      'Alertas de Estoque',
      description: 'Notificações de estoque crítico ou zerado',
      importance: Importance.max,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);

    // ✅ Solicitar permissão no Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  /// 🧪 TESTE MANUAL
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Alertas de Estoque',
      channelDescription: 'Canal de testes',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      999,
      '🔔 Teste de Notificação',
      'Se isso apareceu, o sistema está funcionando',
      details,
    );
  }

  /// 🔥 Escuta o Firestore e decide se notifica
  void startListeningStockAlerts(String userLogin) {
    _subscription?.cancel();

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userLogin)
        .collection('products')
        .snapshots()
        .listen((snapshot) {
      int zeroStock = 0;
      int criticalStock = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final int quantity = data['quantity'] is int
            ? data['quantity']
            : int.tryParse(data['quantity']?.toString() ?? '0') ?? 0;

        if (quantity == 0) {
          zeroStock++;
        } else if (quantity <= 10) {
          criticalStock++;
        }
      }

      if (zeroStock == 0 && criticalStock == 0) return;

      final now = DateTime.now();

      // ⏱️ Limite: 1 notificação por hora
      if (_lastNotificationTime != null &&
          now.difference(_lastNotificationTime!).inMinutes < 60) {
        return;
      }

      _lastNotificationTime = now;

      _showNotification(
        zeroStock: zeroStock,
        criticalStock: criticalStock,
      );
    });
  }

  Future<void> _showNotification({
    required int zeroStock,
    required int criticalStock,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Alertas de Estoque',
      channelDescription: 'Notificações de estoque crítico ou zerado',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    final title = '⚠️ Alerta de Estoque';
    final body = [
      if (zeroStock > 0) '$zeroStock produto(s) zerados',
      if (criticalStock > 0)
        '$criticalStock produto(s) em estoque crítico',
    ].join(' • ');

    await _notifications.show(
      0,
      title,
      body,
      details,
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}

