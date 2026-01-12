// lib/notifications/notification_service.dart
// ignore_for_file: avoid_print

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'stock_alerts';

  /// 🔔 Inicializa notificações locais (usadas APENAS em foreground)
  Future<void> init() async {
    // 🔹 Inicialização Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    // 🔹 Canal Android (obrigatório)
    const channel = AndroidNotificationChannel(
      _channelId,
      'Alertas de Estoque',
      description: 'Notificações de estoque crítico ou zerado',
      importance: Importance.max,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(channel);

    // 🔹 Permissão de notificação (Android 13+ / iOS)
    await FirebaseMessaging.instance.requestPermission();

    // 🔹 Apenas para debug (opcional)
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print('✅ FCM Token obtido: $token'); // agora imprime o token completo
    } else {
      print('⚠️ Não foi possível obter o FCM Token');
    }

    // 🔹 Listener de refresh de token (backend deve atualizar)
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token atualizado');
    });
  }

  /// 🧪 Teste local (não envolve FCM)
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
      'Se isso apareceu, o sistema local está funcionando',
      details,
    );
  }

  /// 🔔 Exibe notificação SOMENTE em foreground
  /// ⚠️ Nunca usar isso para background ou killed
  Future<void> showStockNotification({
    required String productName,
    required int quantity,
    required bool isCritical,
  }) async {
    final title = isCritical
        ? '$productName em Estoque Crítico!'
        : '$productName em Estoque Baixo!';

    final body = 'Quantidade restante: $quantity';

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Alertas de Estoque',
      channelDescription: 'Notificações de estoque crítico ou zerado',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
