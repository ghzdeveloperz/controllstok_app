import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'stock_alerts';

  /// 🔔 Inicializa notificações locais + canal Android
  Future<void> init() async {
    // Configurações iniciais do Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    // Cria canal de notificações no Android
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

    // Solicita permissão no Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // 🔹 Obtém token FCM do dispositivo
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print('✅ FCM Token: $token');
      // Aqui você pode enviar para seu backend ou Firestore para notificações direcionadas
      // Exemplo:
      // await FirebaseFirestore.instance.collection('users').doc(userId).set({
      //   'fcmToken': token,
      // }, SetOptions(merge: true));
    }

    // 🔹 Listener para atualizar token caso mude
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token atualizado: $newToken');
      // Atualize também no backend
    });
  }

  /// 🧪 Teste manual (local)
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

  /// 🔔 Exibe notificação de estoque (título e corpo dinâmicos)
  Future<void> showStockNotification({
    required String productName,
    required int quantity,
    required bool isCritical,
    String? productImageUrl, // opcional para imagem futuramente
  }) async {
    final title = isCritical
        ? "$productName em Estoque Crítico!"
        : "$productName em Estoque Baixo";

    final body = "Quantidade restante: $quantity";

    AndroidNotificationDetails androidDetails;

    if (productImageUrl != null && productImageUrl.isNotEmpty) {
      androidDetails = AndroidNotificationDetails(
        _channelId,
        'Alertas de Estoque',
        channelDescription: 'Notificações de estoque crítico ou zerado',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigPictureStyleInformation(
          FilePathAndroidBitmap(productImageUrl), // futuramente local ou cache
          contentTitle: title,
          summaryText: body,
        ),
      );
    } else {
      androidDetails = const AndroidNotificationDetails(
        _channelId,
        'Alertas de Estoque',
        channelDescription: 'Notificações de estoque crítico ou zerado',
        importance: Importance.max,
        priority: Priority.high,
      );
    }

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
