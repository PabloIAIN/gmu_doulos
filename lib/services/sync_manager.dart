import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'api_service.dart';
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
      debugPrint('SyncManager.init: sin conexión, usando datos locales');
    }
  }

  /// Disparar sync en background (con debounce de 3 segundos)
  void syncEnBackground() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      _subirDatos();
    });
  }

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
      );

      _syncController.add(SyncStatus.success);
      debugPrint('SyncManager: datos subidos correctamente');
    } catch (e) {
      _syncController.add(SyncStatus.error);
      debugPrint('SyncManager: error al subir - $e');
    } finally {
      _syncing = false;
    }
  }

  /// Descargar datos del servidor y actualizar local
  Future<void> descargarDatos() async {
    if (_syncing) return;
    _syncing = true;
    _syncController.add(SyncStatus.syncing);

    try {
      final data = await _api.syncDescargar();
      final db = await _db.database;

      // Miembros
      if (data['miembros'] != null) {
        for (final m in data['miembros']) {
          await db.insert('miembros', Map<String, dynamic>.from(m),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Eventos
      if (data['eventos'] != null) {
        for (final e in data['eventos']) {
          final evento = Map<String, dynamic>.from(e);
          // Remover campos que no existen en SQLite local
          evento.remove('created_at');
          evento.remove('updated_at');
          await db.insert('eventos', evento,
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Unidades
      if (data['unidades'] != null) {
        for (final u in data['unidades']) {
          final unidad = Map<String, dynamic>.from(u);
          unidad.remove('created_at');
          await db.insert('unidades', unidad,
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Unidad-Miembros
      if (data['unidad_miembros'] != null) {
        for (final um in data['unidad_miembros']) {
          await db.insert('unidad_miembros', Map<String, dynamic>.from(um),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      // Asistencia
      if (data['asistencia'] != null) {
        for (final a in data['asistencia']) {
          await db.insert('asistencia', Map<String, dynamic>.from(a),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      _syncController.add(SyncStatus.success);
      debugPrint('SyncManager: datos descargados correctamente');
    } catch (e) {
      _syncController.add(SyncStatus.error);
      debugPrint('SyncManager: error al descargar - $e');
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
