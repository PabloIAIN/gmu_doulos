import 'package:flutter/material.dart';
import '../models/evento.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'asistencia/asistencia_screen.dart';
import 'evidencias/evidencias_screen.dart';
import 'carpeta/carpeta_review_screen.dart';
import 'unidades/unidades_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  final VoidCallback? onOpenDrawer;

  const HomeScreen({super.key, this.onNavigateToTab, this.onOpenDrawer});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  bool _isLoading = true;

  // Datos comunes
  List<Evento> _proximosEventos = [];

  // Admin stats
  int _totalMiembros = 0;
  int _totalEventos = 0;
  int _totalUnidades = 0;
  double _porcentajeAsistencia = 0;
  int _pendientesAprobacion = 0;

  // Consejero stats
  String _unidadNombre = '';
  int _aspirantesEnUnidad = 0;
  int _pendientesRevision = 0;

  // Aspirante stats
  int _carpetaTotal = 0;
  int _carpetaCompletados = 0;
  int _carpetaAprobados = 0;
  int _carpetaEnviados = 0;
  int _carpetaDevueltos = 0;
  double _miAsistencia = 0;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    try {
      // Eventos próximos (todos los roles)
      final todosEventos = await _db.getEventos();
      final hoy = DateTime.now();
      final inicio = DateTime(hoy.year, hoy.month, hoy.day);
      final proximos = todosEventos
          .where((e) => !e.fecha.isBefore(inicio))
          .toList()
        ..sort((a, b) => a.fecha.compareTo(b.fecha));

      if (_auth.isAdmin) {
        final miembros = await _db.countMiembros();
        final eventos = await _db.countEventos();
        final asistencia = await _db.getPorcentajeAsistencia();
        final resumen = await _db.getResumenDatos();
        final pendientes = await _db.getRequisitosPendientesAprobacion();

        setState(() {
          _totalMiembros = miembros;
          _totalEventos = eventos;
          _totalUnidades = resumen['unidades'] ?? 0;
          _porcentajeAsistencia = asistencia;
          _pendientesAprobacion = pendientes.length;
          _proximosEventos = proximos.take(3).toList();
          _isLoading = false;
        });
      } else if (_auth.isConsejero) {
        final userId = _auth.currentUser!.id;
        final unidad = await _db.getUnidadDeConsejero(userId);

        if (unidad != null) {
          final miembrosUnidad = await _db.getMiembrosDeUnidad(unidad['id']);
          final aspirantes = miembrosUnidad
              .where((m) => m['rol_en_unidad'] == 'aspirante')
              .toList();

          // Contar requisitos enviados pendientes de revisión
          int pendientes = 0;
          for (final asp in aspirantes) {
            final resumen = await _db.getCarpetaResumen(asp['miembro_id'] as String);
            pendientes += resumen['enviados'] ?? 0;
          }

          setState(() {
            _unidadNombre = unidad['nombre'] as String;
            _aspirantesEnUnidad = aspirantes.length;
            _pendientesRevision = pendientes;
            _proximosEventos = proximos.take(3).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _proximosEventos = proximos.take(3).toList();
            _isLoading = false;
          });
        }
      } else {
        // Aspirante
        final userId = _auth.currentUser!.id;
        final resumen = await _db.getCarpetaResumen(userId);
        final miAsistencia = await _db.getPorcentajeAsistenciaMiembro(userId);

        setState(() {
          _carpetaTotal = resumen['total'] ?? 0;
          _carpetaCompletados = resumen['completados'] ?? 0;
          _carpetaAprobados = resumen['aprobados'] ?? 0;
          _carpetaEnviados = resumen['enviados'] ?? 0;
          _carpetaDevueltos = resumen['devueltos'] ?? 0;
          _miAsistencia = miAsistencia;
          _proximosEventos = proximos.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'reunion':
        return Icons.groups;
      case 'campamento':
        return Icons.terrain;
      case 'clase':
        return Icons.school;
      case 'ceremonia':
        return Icons.celebration;
      case 'actividad':
        return Icons.directions_walk;
      case 'servicio':
        return Icons.volunteer_activism;
      default:
        return Icons.event;
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'reunion':
        return Colors.blue;
      case 'campamento':
        return Colors.green;
      case 'clase':
        return Colors.orange;
      case 'ceremonia':
        return Colors.purple;
      case 'actividad':
        return Colors.teal;
      case 'servicio':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.onOpenDrawer != null
            ? IconButton(icon: const Icon(Icons.menu), onPressed: widget.onOpenDrawer)
            : null,
        title: const Text('GMU Doulos'),
      ),
      body: RefreshIndicator(
        onRefresh: _cargarEstadisticas,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ))
                  : _buildRoleContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleContent(BuildContext context) {
    if (_auth.isAdmin) {
      return _buildAdminContent(context);
    } else if (_auth.isConsejero) {
      return _buildConsejeroContent(context);
    } else {
      return _buildAspiranteContent(context);
    }
  }

  // ══════════════════════ ADMIN ══════════════════════

  Widget _buildAdminContent(BuildContext context) {
    final asistenciaStr = _porcentajeAsistencia > 0
        ? '${_porcentajeAsistencia.toStringAsFixed(0)}%'
        : '--';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Resumen del Club',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(Icons.people, 'Miembros', _totalMiembros.toString(), Colors.blue),
            _buildStatCard(Icons.calendar_today, 'Eventos', _totalEventos.toString(), Colors.green),
            _buildStatCard(Icons.check_circle, 'Asistencia', asistenciaStr, Colors.purple),
            _buildStatCard(Icons.group_work, 'Unidades', _totalUnidades.toString(), Colors.orange),
          ],
        ),
        if (_pendientesAprobacion > 0) ...[
          const SizedBox(height: 16),
          Card(
            color: AppTheme.accentGold.withOpacity(0.1),
            child: ListTile(
              leading: const Icon(Icons.pending_actions, color: AppTheme.accentGold),
              title: Text('$_pendientesAprobacion requisitos pendientes de aprobación'),
              subtitle: const Text('Carpetas de investidura'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => widget.onNavigateToTab?.call(3), // Admin panel
            ),
          ),
        ],
        const SizedBox(height: 24),
        _buildEventosSection(),
        const SizedBox(height: 24),
        const Text('Acciones Rápidas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildQuickActions(context),
      ],
    );
  }

  // ══════════════════════ CONSEJERO ══════════════════════

  Widget _buildConsejeroContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mi Unidad',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_unidadNombre.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.group, color: AppTheme.primaryGreen, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_unidadNombre,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('$_aspirantesEnUnidad aspirantes asignados',
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => widget.onNavigateToTab?.call(1),
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(Icons.people, 'Aspirantes', _aspirantesEnUnidad.toString(), Colors.blue),
              _buildStatCard(Icons.pending_actions, 'Por revisar', _pendientesRevision.toString(), Colors.orange),
            ],
          ),
        ] else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.group_off, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text('No estas asignado a una unidad',
                        style: TextStyle(color: Colors.grey[600])),
                    Text('Contacta al Director', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        _buildEventosSection(),
        const SizedBox(height: 24),
        const Text('Acciones Rápidas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildQuickActions(context),
      ],
    );
  }

  // ══════════════════════ ASPIRANTE ══════════════════════

  Widget _buildAspiranteContent(BuildContext context) {
    final porcentaje = _carpetaTotal > 0 ? _carpetaAprobados / _carpetaTotal : 0.0;
    final asistStr = _miAsistencia > 0 ? '${_miAsistencia.toStringAsFixed(0)}%' : '--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mi Carpeta de Investidura',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // Progreso circular grande
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: porcentaje,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[200],
                        color: porcentaje >= 1.0
                            ? AppTheme.successGreen
                            : AppTheme.primaryGreen,
                      ),
                    ),
                    Text(
                      '${(porcentaje * 100).toInt()}%',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Progreso General',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _buildProgressRow(Icons.check_circle, 'Aprobados', '$_carpetaAprobados/$_carpetaTotal', AppTheme.successGreen),
                      const SizedBox(height: 4),
                      _buildProgressRow(Icons.pending, 'Completados', '$_carpetaCompletados/$_carpetaTotal', AppTheme.accentGold),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => widget.onNavigateToTab?.call(1),
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(Icons.fact_check, 'Asistencia', asistStr, Colors.purple),
            _buildStatCard(Icons.upcoming, 'Próximos', _proximosEventos.length.toString(), Colors.amber),
          ],
        ),
        if (_carpetaDevueltos > 0) ...[
          const SizedBox(height: 12),
          Card(
            color: AppTheme.warningOrange.withOpacity(0.1),
            child: ListTile(
              leading: const Icon(Icons.replay, color: AppTheme.warningOrange),
              title: Text('$_carpetaDevueltos requisitos devueltos'),
              subtitle: const Text('Revisa los comentarios y re-envia'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => widget.onNavigateToTab?.call(1),
            ),
          ),
        ],
        if (_carpetaEnviados > 0) ...[
          const SizedBox(height: 12),
          Card(
            color: AppTheme.accentGold.withOpacity(0.1),
            child: ListTile(
              leading: const Icon(Icons.hourglass_top, color: AppTheme.accentGold),
              title: Text('$_carpetaEnviados requisitos en revision'),
              subtitle: const Text('Esperando que tu consejero los revise'),
            ),
          ),
        ],
        const SizedBox(height: 24),
        _buildEventosSection(),
        const SizedBox(height: 24),
        const Text('Acciones Rápidas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildQuickActions(context),
      ],
    );
  }

  Widget _buildProgressRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  // ══════════════════════ SHARED WIDGETS ══════════════════════

  Widget _buildWelcomeCard(BuildContext context) {
    final user = _auth.currentUser;
    final nombre = user?.nombre ?? 'Guia';
    final rol = user?.rol ?? '';

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, $nombre!',
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Club GMU Doulos',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      rol,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.shield, size: 50, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildEventosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Próximos Eventos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => widget.onNavigateToTab?.call(2),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildEventsList(),
      ],
    );
  }

  Widget _buildEventsList() {
    if (_proximosEventos.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.event_available, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text('No hay eventos próximos', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: _proximosEventos.map((evento) {
        final diasRestantes = evento.diasRestantes;
        final subtitulo = diasRestantes == 0
            ? 'Hoy - ${evento.hora}'
            : diasRestantes == 1
                ? 'Mañana - ${evento.hora}'
                : '${evento.fecha.day}/${evento.fecha.month} - ${evento.hora}';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getTipoColor(evento.tipo).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getTipoIcon(evento.tipo),
                color: _getTipoColor(evento.tipo),
              ),
            ),
            title: Text(evento.titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(subtitulo),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => widget.onNavigateToTab?.call(2),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    if (_auth.isAdmin) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(icon: Icons.person_add, label: 'Agregar\nMiembro', color: Colors.blue, onTap: () => widget.onNavigateToTab?.call(1)),
          _buildActionItem(icon: Icons.add_task, label: 'Registrar\nAsistencia', color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AsistenciaScreen()))),
          _buildActionItem(icon: Icons.group_work, label: 'Ver\nUnidades', color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UnidadesScreen()))),
          _buildActionItem(icon: Icons.event, label: 'Nuevo\nEvento', color: Colors.purple, onTap: () => widget.onNavigateToTab?.call(2)),
        ],
      );
    } else if (_auth.isConsejero) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(icon: Icons.group, label: 'Mi\nUnidad', color: Colors.blue, onTap: () => widget.onNavigateToTab?.call(1)),
          _buildActionItem(icon: Icons.folder_special, label: 'Revisar\nCarpetas', color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CarpetaReviewScreen()))),
          _buildActionItem(icon: Icons.add_task, label: 'Registrar\nAsistencia', color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AsistenciaScreen()))),
          _buildActionItem(icon: Icons.camera_alt, label: 'Tomar\nFoto', color: Colors.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EvidenciasScreen()))),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(icon: Icons.folder, label: 'Mi\nCarpeta', color: Colors.blue, onTap: () => widget.onNavigateToTab?.call(1)),
          _buildActionItem(icon: Icons.calendar_month, label: 'Ver\nCalendario', color: Colors.green, onTap: () => widget.onNavigateToTab?.call(2)),
          _buildActionItem(icon: Icons.camera_alt, label: 'Subir\nEvidencia', color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EvidenciasScreen()))),
          _buildActionItem(icon: Icons.handyman, label: 'Herramientas', color: Colors.purple, onTap: () => widget.onNavigateToTab?.call(3)),
        ],
      );
    }
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
