import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'database_service.dart';

/// Servicio de sincronización automática offline-first.
/// Guarda datos localmente y sincroniza con el backend en background.
class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final ApiService _api = ApiService();
  final DatabaseService _db = DatabaseService();

  bool _syncing = false;
  Timer? _debounceTimer;
  final _syncController = StreamController<SyncStatus>.broadcast();

  /// Stream para escuchar el estado de sincronización
  Stream<SyncStatus> get syncStream => _syncController.stream;

  /// Inicializar: descarga datos del servidor al abrir la app
  Future<void> init() async {
    try {
      await descargarDatos();
    } catch (e) {
      if (kDebugMode) debugPrint('SyncManager.init: sin conexión, usando datos locales');
    }
  }

  /// Disparar sync en background (con debounce de 3 segundos)
  void syncEnBackground() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      _subirDatos();
    });
  }

  String? get _clubId => AuthService().clubId;

  /// Subir todos los datos locales al servidor
  Future<void> _subirDatos() async {
    if (_syncing) return;
    _syncing = true;
    _syncController.add(SyncStatus.syncing);

    try {
      final db = await _db.database;

      final miembros = await db.query('miembros');
      final eventos = await db.query('eventos');
      final unidades = await db.query('unidades');
      final unidadMiembros = await db.query('unidad_miembros');
      final asistencia = await db.query('asistencia');

      await _api.syncSubir(
        miembros: miembros,
        eventos: eventos,
        unidades: unidades,
        unidadMiembros: unidadMiembros,
        asistencia: asistencia,
        clubId: _clubId,
      );

      _syncController.add(SyncStatus.success);
      if (kDebugMode) debugPrint('SyncManager: datos subidos correctamente');
    } catch (e) {
      _syncController.add(SyncStatus.error);
      if (kDebugMode) debugPrint('SyncManager: error al subir - $e');
    } finally {
      _syncing = false;
    }
  }

  // Helper to clean server fields that don't exist locally
  Map<String, dynamic> _cleanForLocal(Map<String, dynamic> row, List<String> validColumns) {
    final clean = <String, dynamic>{};
    for (final entry in row.entries) {
      if (validColumns.contains(entry.key)) {
        clean[entry.key] = entry.value;
      }
    }
    return clean;
  }

  static const _miembroCols = ['id','nombre','apellido','fecha_nacimiento','telefono','email','foto_url','clase','rol','activo','fecha_registro','usuario','password_hash','club_id','ministerio','clase_ministerio'];
  static const _eventoCols = ['id','titulo','descripcion','fecha','hora','ubicacion','tipo','latitud','longitud','club_id','ministerio'];
  static const _unidadCols = ['id','nombre','descripcion','activo','fecha_creacion','club_id','ministerio'];
  static const _umCols = ['id','unidad_id','miembro_id','rol_en_unidad','fecha_asignacion'];
  static const _asistCols = ['id','unidad_id','miembro_id','fecha','dia_semana','puntualidad','panoleta','biblia','cuota','registrado_por','fecha_registro','club_id'];

  /// Descargar datos del servidor y actualizar local
  Future<void> descargarDatos() async {
    if (_syncing) return;
    _syncing = true;
    _syncController.add(SyncStatus.syncing);

    try {
      final data = await _api.syncDescargar(clubId: _clubId);
      final db = await _db.database;

      if (data['miembros'] != null) {
        for (final m in data['miembros']) {
          final clean = _cleanForLocal(Map<String, dynamic>.from(m), _miembroCols);
          await db.insert('miembros', clean, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      if (data['eventos'] != null) {
        for (final e in data['eventos']) {
          final clean = _cleanForLocal(Map<String, dynamic>.from(e), _eventoCols);
          await db.insert('eventos', clean, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      if (data['unidades'] != null) {
        for (final u in data['unidades']) {
          final clean = _cleanForLocal(Map<String, dynamic>.from(u), _unidadCols);
          await db.insert('unidades', clean, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      if (data['unidad_miembros'] != null) {
        for (final um in data['unidad_miembros']) {
          final clean = _cleanForLocal(Map<String, dynamic>.from(um), _umCols);
          await db.insert('unidad_miembros', clean, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      if (data['asistencia'] != null) {
        for (final a in data['asistencia']) {
          final clean = _cleanForLocal(Map<String, dynamic>.from(a), _asistCols);
          await db.insert('asistencia', clean, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      _syncController.add(SyncStatus.success);
      if (kDebugMode) debugPrint('SyncManager: datos descargados correctamente');
    } catch (e) {
      _syncController.add(SyncStatus.error);
      if (kDebugMode) debugPrint('SyncManager: error al descargar - $e');
    } finally {
      _syncing = false;
    }
  }

  /// Forzar subida inmediata (sin debounce)
  Future<void> subirAhora() => _subirDatos();

  void dispose() {
    _debounceTimer?.cancel();
    _syncController.close();
  }
}

enum SyncStatus { syncing, success, error }
