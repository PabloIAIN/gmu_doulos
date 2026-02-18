import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'database_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final DatabaseService _db = DatabaseService();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

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

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Marcar como leída si tiene payload con ID
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
}
