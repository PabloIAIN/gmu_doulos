import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;
import '../../services/database_service.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final ApiService _api = ApiService();
  final DatabaseService _db = DatabaseService();
  bool _syncing = false;
  final List<String> _log = [];

  void _addLog(String msg) {
    setState(() {
      _log.add(msg);
    });
  }

  // ── Subir datos locales al backend ──
  Future<void> _subirDatos() async {
    setState(() {
      _syncing = true;
      _log.clear();
    });

    try {
      _addLog('Preparando datos locales...');

      // Obtener datos locales
      final miembrosObj = await _db.getMiembros();
      final miembros = miembrosObj.map((m) => m.toMap()).toList();
      _addLog('✓ ${miembros.length} miembros encontrados');

      final eventosObj = await _db.getEventos();
      final eventos = eventosObj.map((e) => e.toMap()).toList();
      _addLog('✓ ${eventos.length} eventos encontrados');

      final unidades = await _db.getUnidades();
      _addLog('✓ ${unidades.length} unidades encontradas');

      final asistenciaRaw = await _db.database.then((db) => db.query('asistencia'));
      _addLog('✓ ${asistenciaRaw.length} registros de asistencia');

      final unidadMiembrosRaw = await _db.database.then((db) => db.query('unidad_miembros'));
      _addLog('✓ ${unidadMiembrosRaw.length} asignaciones unidad-miembro');

      _addLog('Subiendo al servidor...');

      // Primero inicializar tablas
      await _api.setupDatabase();
      _addLog('✓ Tablas inicializadas');

      // Sincronizar
      final result = await _api.syncSubir(
        miembros: miembros,
        eventos: eventos,
        unidades: unidades,
        unidadMiembros: unidadMiembrosRaw,
        asistencia: asistenciaRaw,
      );

      final sync = result['sincronizados'] as Map<String, dynamic>;
      _addLog('═══ Sincronización completa ═══');
      _addLog('Miembros: ${sync['miembros']}');
      _addLog('Eventos: ${sync['eventos']}');
      _addLog('Unidades: ${sync['unidades']}');
      _addLog('Asignaciones: ${sync['unidad_miembros']}');
      _addLog('Asistencia: ${sync['asistencia']}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos subidos exitosamente'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      _addLog('✗ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    } finally {
      setState(() => _syncing = false);
    }
  }

  // ── Descargar datos del backend a SQLite local ──
  Future<void> _descargarDatos() async {
    setState(() {
      _syncing = true;
      _log.clear();
    });

    try {
      _addLog('Descargando datos del servidor...');
      final data = await _api.syncDescargar();

      final miembros = List<Map<String, dynamic>>.from(data['miembros'] ?? []);
      final eventos = List<Map<String, dynamic>>.from(data['eventos'] ?? []);
      final unidades = List<Map<String, dynamic>>.from(data['unidades'] ?? []);

      _addLog('Recibidos: ${miembros.length} miembros, ${eventos.length} eventos, ${unidades.length} unidades');
      _addLog('Guardando en base de datos local...');

      final db = await _db.database;

      // Insertar miembros
      for (final m in miembros) {
        await db.insert('miembros', {
          'id': m['id'],
          'nombre': m['nombre'],
          'apellido': m['apellido'],
          'fecha_nacimiento': m['fecha_nacimiento'],
          'telefono': m['telefono'],
          'email': m['email'],
          'foto_url': m['foto_url'],
          'clase': m['clase'],
          'rol': m['rol'],
          'activo': m['activo'],
          'fecha_registro': m['fecha_registro'],
          'usuario': m['usuario'],
          'password_hash': m['password_hash'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      _addLog('✓ ${miembros.length} miembros guardados');

      // Insertar eventos
      for (final e in eventos) {
        await db.insert('eventos', {
          'id': e['id'],
          'titulo': e['titulo'],
          'descripcion': e['descripcion'],
          'fecha': e['fecha'],
          'hora': e['hora'],
          'ubicacion': e['ubicacion'],
          'tipo': e['tipo'],
          'latitud': e['latitud'],
          'longitud': e['longitud'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      _addLog('✓ ${eventos.length} eventos guardados');

      // Insertar unidades
      for (final u in unidades) {
        await db.insert('unidades', {
          'id': u['id'],
          'nombre': u['nombre'],
          'descripcion': u['descripcion'],
          'activo': u['activo'],
          'fecha_creacion': u['fecha_creacion'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      _addLog('✓ ${unidades.length} unidades guardadas');

      _addLog('═══ Descarga completa ═══');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos descargados exitosamente'), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      _addLog('✗ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    } finally {
      setState(() => _syncing = false);
    }
  }

  // ── Health check ──
  Future<void> _healthCheck() async {
    setState(() {
      _log.clear();
    });

    try {
      _addLog('Verificando conexión...');
      final result = await _api.healthCheck();
      _addLog('Estado: ${result['status']}');
      _addLog('Base de datos: ${result['database']}');
      if (result['server_time'] != null) {
        _addLog('Hora del servidor: ${result['server_time']}');
      }
      if (result['message'] != null) {
        _addLog('Nota: ${result['message']}');
      }
      _addLog('Versión API: ${result['version'] ?? 'n/a'}');

      final endpoints = result['endpoints'];
      if (endpoints != null && endpoints is List) {
        _addLog('Endpoints disponibles:');
        for (final ep in endpoints) {
          _addLog('  • $ep');
        }
      }
    } catch (e) {
      _addLog('✗ Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronización')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.cloud_sync, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Backend API',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sincroniza datos entre tu dispositivo y el servidor',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: _buildSyncButton(
                    icon: Icons.cloud_upload,
                    label: 'Subir datos',
                    subtitle: 'Local → Servidor',
                    color: Colors.blue,
                    onTap: _syncing ? null : _subirDatos,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSyncButton(
                    icon: Icons.cloud_download,
                    label: 'Descargar',
                    subtitle: 'Servidor → Local',
                    color: Colors.green,
                    onTap: _syncing ? null : _descargarDatos,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _syncing ? null : _healthCheck,
                icon: const Icon(Icons.wifi_find),
                label: const Text('Verificar conexión'),
              ),
            ),
            const SizedBox(height: 20),

            // Log de actividad
            if (_log.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Actividad', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  if (_syncing)
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _log
                      .map((line) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              line,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: line.startsWith('✗') ? AppTheme.errorRed : Colors.grey[800],
                                fontWeight: line.contains('═══') ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSyncButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
            child: Column(
              children: [
                Icon(icon, color: onTap == null ? Colors.grey : color, size: 32),
                const SizedBox(height: 8),
                Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: onTap == null ? Colors.grey : null)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
