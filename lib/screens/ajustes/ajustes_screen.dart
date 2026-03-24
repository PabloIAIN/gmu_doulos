import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import '../../config/app_config.dart';
import 'audit_log_screen.dart';
import 'backup_screen.dart';

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
  late bool _darkMode;
  bool _notificaciones = true;
  bool _sonido = true;
  bool _recordatorios = true;

  String _clubNombre = AppConfig.appName;
  String _clubUbicacion = AppConfig.location;
  String _clubIglesia = AppConfig.church;
  String? _ultimoRespaldo;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.darkMode;
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    try {
      final config = await _db.getAllConfig();
      setState(() {
        _clubNombre = config['club_nombre'] ?? AppConfig.appName;
        _clubUbicacion = config['club_ubicacion'] ?? AppConfig.location;
        _clubIglesia = config['club_iglesia'] ?? AppConfig.church;
        _ultimoRespaldo = config['ultimo_respaldo'];
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading config: $e');
    }
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
                  subtitle: const Text(AppConfig.clubName),
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
                _darkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              title: const Text('Modo oscuro'),
              subtitle: Text(_darkMode ? 'Activado' : 'Desactivado'),
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
                widget.onDarkModeChanged(value);
              },
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
                  title: const Text('Backup de datos'),
                  subtitle: Text(
                    _ultimoRespaldo != null
                        ? 'Último: ${_formatFechaRespaldo(_ultimoRespaldo!)}'
                        : 'Exportar e importar datos',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()));
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Registro de actividad'),
                  subtitle: const Text('Historial de cambios'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditLogScreen()));
                  },
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
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Version'),
                  trailing: Text('1.1.0'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Desarrollador'),
                  trailing: Text('Pablo'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.school),
                  title: Text('Universidad'),
                  subtitle: Text('Universidad de Montemorelos'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.new_releases),
                  title: const Text('Novedades v1.1'),
                  subtitle: const Text('Ver que hay de nuevo'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _mostrarNovedades(),
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
                Icon(Icons.shield, size: 40, color: AppTheme.primaryGreen.withValues(alpha: 0.4)),
                const SizedBox(height: 8),
                Text(
                  _clubNombre,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  AppConfig.tagline,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2025 Programacion de Dispositivos Moviles\nUniversidad de Montemorelos',
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
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryGreen,
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

  void _mostrarNovedades() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.new_releases, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Text('Novedades v1.1',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              _NovedadItem(icon: Icons.search, text: 'Busqueda global en todo el club'),
              _NovedadItem(icon: Icons.backup, text: 'Exportar e importar backups'),
              _NovedadItem(icon: Icons.filter_list, text: 'Filtros avanzados por clase y rol'),
              _NovedadItem(icon: Icons.fact_check, text: 'Historial de asistencia por miembro'),
              _NovedadItem(icon: Icons.animation, text: 'Splash screen y animaciones'),
              _NovedadItem(icon: Icons.verified, text: 'Validacion de formularios mejorada'),
              _NovedadItem(icon: Icons.school, text: 'Onboarding para nuevos usuarios'),
              _NovedadItem(icon: Icons.dark_mode, text: 'Modo oscuro persistente'),
              _NovedadItem(icon: Icons.bar_chart, text: 'Estadisticas con graficas'),
              _NovedadItem(icon: Icons.picture_as_pdf, text: 'Exportar reportes en PDF'),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Genial!'),
          ),
        ],
      ),
    );
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

class _NovedadItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _NovedadItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
