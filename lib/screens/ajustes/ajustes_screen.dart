import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../services/database_service.dart';

class AjustesScreen extends StatefulWidget {
  final bool darkMode;
  final Function(bool) onDarkModeChanged;

  const AjustesScreen({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final DatabaseService _db = DatabaseService();
  bool _notificaciones = true;
  bool _sonido = true;
  bool _recordatorios = true;

  String _clubNombre = 'GMU Doulos';
  String _clubUbicacion = 'Montemorelos, Nuevo León';
  String _clubIglesia = 'Iglesia Adventista Central';
  String? _ultimoRespaldo;

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    try {
      final config = await _db.getAllConfig();
      setState(() {
        _clubNombre = config['club_nombre'] ?? 'GMU Doulos';
        _clubUbicacion = config['club_ubicacion'] ?? 'Montemorelos, Nuevo León';
        _clubIglesia = config['club_iglesia'] ?? 'Iglesia Adventista Central';
        _ultimoRespaldo = config['ultimo_respaldo'];
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Perfil del Club
          _buildSectionTitle('Perfil del Club'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shield,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(_clubNombre),
                  subtitle: const Text('Club de Guías Mayores'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _editarPerfilDialog('club_nombre', 'Nombre del Club', _clubNombre),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Ubicación'),
                  subtitle: Text(_clubUbicacion),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _editarPerfilDialog('club_ubicacion', 'Ubicación', _clubUbicacion),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.church),
                  title: const Text('Iglesia'),
                  subtitle: Text(_clubIglesia),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _editarPerfilDialog('club_iglesia', 'Iglesia', _clubIglesia),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Apariencia
          _buildSectionTitle('Apariencia'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: SwitchListTile(
              secondary: Icon(
                widget.darkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              title: const Text('Modo oscuro'),
              subtitle: Text(widget.darkMode ? 'Activado' : 'Desactivado'),
              value: widget.darkMode,
              onChanged: widget.onDarkModeChanged,
            ),
          ),
          const SizedBox(height: 16),

          // Notificaciones
          _buildSectionTitle('Notificaciones'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text('Notificaciones'),
                  subtitle: const Text('Recibir alertas del club'),
                  value: _notificaciones,
                  onChanged: (value) {
                    setState(() => _notificaciones = value);
                  },
                ),
                if (_notificaciones) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.volume_up),
                    title: const Text('Sonido'),
                    value: _sonido,
                    onChanged: (value) {
                      setState(() => _sonido = value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.alarm),
                    title: const Text('Recordatorios de eventos'),
                    subtitle: const Text('1 día antes'),
                    value: _recordatorios,
                    onChanged: (value) {
                      setState(() => _recordatorios = value);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Datos
          _buildSectionTitle('Datos'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Respaldo de datos'),
                  subtitle: Text(
                    _ultimoRespaldo != null
                        ? 'Último: ${_formatFechaRespaldo(_ultimoRespaldo!)}'
                        : 'Último: Nunca',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _crearRespaldo,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Exportar datos'),
                  subtitle: const Text('Guardar como JSON'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _exportarDatos,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text('Resumen de datos'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _mostrarResumen,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Borrar todos los datos',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _showDeleteConfirmation(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Acerca de
          _buildSectionTitle('Acerca de'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Versión'),
                  trailing: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Desarrollador'),
                  trailing: const Text('Pablo'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.school),
                  title: Text('Universidad'),
                  subtitle: Text('Universidad de Montemorelos'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.shield, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  _clubNombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '"Siervos de Cristo"',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2025 Programación de Dispositivos Móviles\nUniversidad de Montemorelos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _editarPerfilDialog(String clave, String label, String valorActual) {
    final controller = TextEditingController(text: valorActual);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _db.setConfig(clave, controller.text);
                await _cargarConfiguracion();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label actualizado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _crearRespaldo() async {
    try {
      _showLoadingDialog('Creando respaldo...');
      final jsonData = await _db.exportarDatosJson();
      final dbPath = await getDatabasesPath();
      final fecha = DateTime.now();
      final fileName = 'respaldo_gmu_${fecha.year}${fecha.month.toString().padLeft(2, '0')}${fecha.day.toString().padLeft(2, '0')}_${fecha.hour.toString().padLeft(2, '0')}${fecha.minute.toString().padLeft(2, '0')}.json';
      final filePath = p.join(dbPath, fileName);
      final file = File(filePath);
      await file.writeAsString(jsonData);

      await _db.setConfig('ultimo_respaldo', fecha.toIso8601String());
      await _cargarConfiguracion();

      if (mounted) {
        Navigator.pop(context); // dismiss loading
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Respaldo creado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Archivo: $fileName'),
                const SizedBox(height: 8),
                Text(
                  'Ubicación: $dbPath',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear respaldo: $e')),
        );
      }
    }
  }

  Future<void> _exportarDatos() async {
    try {
      _showLoadingDialog('Exportando datos...');
      final jsonData = await _db.exportarDatosJson();
      final dbPath = await getDatabasesPath();
      final filePath = p.join(dbPath, 'gmu_doulos_export.json');
      final file = File(filePath);
      await file.writeAsString(jsonData);

      if (mounted) {
        Navigator.pop(context); // dismiss loading
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.download_done, color: Colors.green, size: 48),
            title: const Text('Datos exportados'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Se exportaron todos los datos en formato JSON.'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    filePath,
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
  }

  Future<void> _mostrarResumen() async {
    try {
      final resumen = await _db.getResumenDatos();
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Resumen de datos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResumenRow(Icons.people, 'Miembros', resumen['miembros']!),
              _buildResumenRow(Icons.event, 'Eventos', resumen['eventos']!),
              _buildResumenRow(Icons.check_circle, 'Registros de asistencia', resumen['asistencia']!),
              _buildResumenRow(Icons.emoji_events, 'Especialidades', resumen['especialidades']!),
              _buildResumenRow(Icons.photo, 'Evidencias', resumen['evidencias']!),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildResumenRow(IconData icon, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar todos los datos?'),
        content: const Text(
          'Esta acción eliminará todos los miembros, eventos, '
          'asistencias, especialidades y evidencias. '
          'Se restaurarán los datos de ejemplo.\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingDialog('Restaurando datos...');
              try {
                await _db.resetDatabase();
                if (mounted) {
                  Navigator.pop(context); // dismiss loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Datos restaurados a valores de ejemplo'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // dismiss loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Borrar todo'),
          ),
        ],
      ),
    );
  }

  String _formatFechaRespaldo(String isoDate) {
    final fecha = DateTime.tryParse(isoDate);
    if (fecha == null) return isoDate;
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}
