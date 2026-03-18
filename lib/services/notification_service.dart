import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'database_service.dart';

/// Handler para mensajes en background (debe ser top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase ya se inicializa en main.dart; aqui solo procesamos el mensaje
  final db = DatabaseService();
  final id = message.messageId ?? 'fcm_${DateTime.now().millisecondsSinceEpoch}';
  await db.insertNotificacion({
    'id': id,
    'titulo': message.notification?.title ?? 'Notificacion',
    'mensaje': message.notification?.body ?? '',
    'tipo': message.data['tipo'] ?? 'general',
    'fecha_programada': DateTime.now().toIso8601String(),
    'leida': 0,
    'enviada': 1,
    'fecha_creacion': DateTime.now().toIso8601String(),
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final DatabaseService _db = DatabaseService();
  bool _initialized = false;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    if (_initialized) return;

    // ── Local notifications ──
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // ── Firebase Cloud Messaging ──
    await _initFCM();

    _initialized = true;
  }

  Future<void> _initFCM() async {
    // Solicitar permisos
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    // Obtener token FCM
    _fcmToken = await _fcm.getToken();
    // Token disponible en _fcmToken para uso interno

    // Escuchar cambios de token
    _fcm.onTokenRefresh.listen((token) {
      _fcmToken = token;
    });

    // Mensajes en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Cuando el usuario toca una notificacion estando la app en background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Verificar si la app fue abierta desde una notificacion (app terminada)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Mensaje recibido con la app en primer plano
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final id =
        message.messageId ?? 'fcm_${DateTime.now().millisecondsSinceEpoch}';

    // Mostrar como local notification (FCM no la muestra automaticamente en foreground)
    await mostrarNotificacion(
      id: id,
      titulo: notification.title ?? 'Notificacion',
      mensaje: notification.body ?? '',
      tipo: message.data['tipo'] ?? 'general',
    );
  }

  /// Usuario toco la notificacion desde background/terminated
  void _handleMessageOpenedApp(RemoteMessage message) {
    final id = message.messageId;
    if (id != null) {
      _db.marcarNotificacionLeida(id);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      _db.marcarNotificacionLeida(response.payload!);
    }
  }

  // Mostrar notificación inmediata
  Future<void> mostrarNotificacion({
    required String id,
    required String titulo,
    required String mensaje,
    String tipo = 'general',
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'gmu_doulos_channel',
      'GMU Doulos',
      channelDescription: 'Notificaciones del Club de Guías Mayores',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // Guardar en DB
    await _db.insertNotificacion({
      'id': id,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'fecha_programada': DateTime.now().toIso8601String(),
      'leida': 0,
      'enviada': 1,
      'fecha_creacion': DateTime.now().toIso8601String(),
    });

    await _plugin.show(
      id.hashCode,
      titulo,
      mensaje,
      details,
      payload: id,
    );
  }

  // Programar notificación para recordatorio de evento
  Future<void> programarRecordatorioEvento({
    required String eventoId,
    required String tituloEvento,
    required DateTime fechaEvento,
    required String horaEvento,
    int minutosAntes = 60,
  }) async {
    await init();

    final fechaRecordatorio =
        fechaEvento.subtract(Duration(minutes: minutosAntes));

    // No programar si ya pasó
    if (fechaRecordatorio.isBefore(DateTime.now())) return;

    final id = 'evento_${eventoId}_$minutosAntes';
    final tiempoTexto = minutosAntes >= 60
        ? '${minutosAntes ~/ 60} hora${minutosAntes >= 120 ? "s" : ""}'
        : '$minutosAntes minutos';

    // Guardar en DB como pendiente
    await _db.insertNotificacion({
      'id': id,
      'titulo': 'Recordatorio: $tituloEvento',
      'mensaje': 'El evento "$tituloEvento" comienza en $tiempoTexto ($horaEvento)',
      'tipo': 'evento',
      'fecha_programada': fechaRecordatorio.toIso8601String(),
      'evento_id': eventoId,
      'leida': 0,
      'enviada': 0,
      'fecha_creacion': DateTime.now().toIso8601String(),
    });
  }

  // Crear recordatorio personalizado
  Future<void> crearRecordatorio({
    required String titulo,
    required String mensaje,
    required DateTime fecha,
    String tipo = 'recordatorio',
  }) async {
    await init();

    final id = 'rec_${DateTime.now().millisecondsSinceEpoch}';

    await _db.insertNotificacion({
      'id': id,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'fecha_programada': fecha.toIso8601String(),
      'leida': 0,
      'enviada': 0,
      'fecha_creacion': DateTime.now().toIso8601String(),
    });

    // Si es para ahora o ya pasó, mostrar inmediatamente
    if (!fecha.isAfter(DateTime.now())) {
      await mostrarNotificacion(
        id: id,
        titulo: titulo,
        mensaje: mensaje,
        tipo: tipo,
      );
    }
  }

  // Verificar y enviar notificaciones pendientes
  Future<int> verificarPendientes() async {
    final pendientes = await _db.getNotificacionesPendientes();
    final ahora = DateTime.now();
    int enviadas = 0;

    for (final notif in pendientes) {
      if (notif['enviada'] == 1) continue;

      final fechaProgramada = DateTime.parse(notif['fecha_programada']);
      if (fechaProgramada.isBefore(ahora) ||
          fechaProgramada.difference(ahora).inMinutes <= 1) {
        await mostrarNotificacion(
          id: notif['id'],
          titulo: notif['titulo'],
          mensaje: notif['mensaje'] ?? '',
          tipo: notif['tipo'],
        );
        enviadas++;
      }
    }
    return enviadas;
  }

  // Cancelar notificación
  Future<void> cancelarNotificacion(String id) async {
    await _plugin.cancel(id.hashCode);
    await _db.deleteNotificacion(id);
  }

  // Cancelar todas
  Future<void> cancelarTodas() async {
    await _plugin.cancelAll();
  }

  // Solicitar permisos (Android 13+)
  Future<bool> solicitarPermisos() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  // Suscribirse a un topic (ej: 'admin', 'consejero', 'aspirante', 'todos')
  Future<void> suscribirseATopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  // Desuscribirse de un topic
  Future<void> desuscribirseDeTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  // ── Enviar push notification via backend ──
  // URL del backend en Vercel (configurar despues del deploy)
  static const String _backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: '',
  );
  static const String _apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );

  /// Enviar push notification a un topic via el backend
  Future<bool> enviarPushNotification({
    required String titulo,
    required String mensaje,
    String topic = 'todos',
    String tipo = 'general',
  }) async {
    if (_backendUrl.isEmpty) {
      // Si no hay backend configurado, solo mostrar local
      await mostrarNotificacion(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        titulo: titulo,
        mensaje: mensaje,
        tipo: tipo,
      );
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/send-notification'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
        },
        body: jsonEncode({
          'titulo': titulo,
          'mensaje': mensaje,
          'topic': topic,
          'tipo': tipo,
        }),
      );
      debugPrint('Push response: ${response.statusCode}');
      if (response.statusCode == 200) return true;
      // Si el backend fallo, mostrar local como fallback
      await mostrarNotificacion(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        titulo: titulo,
        mensaje: mensaje,
        tipo: tipo,
      );
      return false;
    } catch (e) {
      debugPrint('Push error: $e');
      // Si falla la conexion, mostrar local como fallback
      await mostrarNotificacion(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        titulo: titulo,
        mensaje: mensaje,
        tipo: tipo,
      );
      return false;
    }
  }
}
