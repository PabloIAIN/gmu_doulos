import 'package:flutter/material.dart';
import '../models/evento.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/section_header.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/user_avatar.dart';
import '../widgets/skeleton_loader.dart';
import 'asistencia/asistencia_screen.dart';
import 'carpeta/carpeta_review_screen.dart';
import 'notificaciones/notificaciones_screen.dart';
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
      case 'reunion': return Icons.groups;
      case 'campamento': return Icons.terrain;
      case 'clase': return Icons.school;
      case 'ceremonia': return Icons.celebration;
      case 'actividad': return Icons.directions_walk;
      case 'servicio': return Icons.volunteer_activism;
      default: return Icons.event;
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'reunion': return Colors.blue;
      case 'campamento': return Colors.green;
      case 'clase': return Colors.orange;
      case 'ceremonia': return Colors.purple;
      case 'actividad': return Colors.teal;
      case 'servicio': return Colors.pink;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.onOpenDrawer != null
            ? IconButton(icon: const Icon(Icons.menu), onPressed: widget.onOpenDrawer)
            : null,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield, size: 22, color: AppTheme.primaryGreen),
            SizedBox(width: 8),
            Text('GMU Doulos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificacionesScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarEstadisticas,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              _isLoading
                  ? _buildSkeletonContent()
                  : _buildRoleContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonStatRow(count: 4),
        const SizedBox(height: 24),
        const SkeletonLoader(height: 20, width: 160),
        const SizedBox(height: 12),
        for (int i = 0; i < 3; i++) ...[
          const SkeletonCard(),
        ],
      ],
    );
  }

  Widget _buildRoleContent() {
    if (_auth.isAdmin) return _buildAdminContent();
    if (_auth.isConsejero) return _buildConsejeroContent();
    return _buildAspiranteContent();
  }

  // ══════════════════════ ADMIN ══════════════════════

  Widget _buildAdminContent() {
    final asistenciaStr = _porcentajeAsistencia > 0
        ? '${_porcentajeAsistencia.toStringAsFixed(0)}%'
        : '--';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Resumen del Club'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            StatCard(icon: Icons.people, title: 'Miembros', value: _totalMiembros.toString(), color: Colors.blue),
            StatCard(icon: Icons.calendar_today, title: 'Eventos', value: _totalEventos.toString(), color: Colors.green),
            StatCard(icon: Icons.check_circle, title: 'Asistencia', value: asistenciaStr, color: Colors.purple),
            StatCard(icon: Icons.group_work, title: 'Unidades', value: _totalUnidades.toString(), color: Colors.orange),
          ],
        ),
        if (_pendientesAprobacion > 0) ...[
          const SizedBox(height: 16),
          _buildAlertCard(
            icon: Icons.pending_actions,
            color: AppTheme.accentGold,
            title: '$_pendientesAprobacion requisitos pendientes de aprobacion',
            subtitle: 'Carpetas de investidura',
            onTap: () => widget.onNavigateToTab?.call(3),
          ),
        ],
        const SizedBox(height: 24),
        _buildEventosSection(),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Acciones Rapidas'),
        const SizedBox(height: 12),
        _buildQuickActions(),
      ],
    );
  }

  // ══════════════════════ CONSEJERO ══════════════════════

  Widget _buildConsejeroContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Mi Unidad'),
        const SizedBox(height: 12),
        if (_unidadNombre.isNotEmpty) ...[
          _buildUnidadCard(),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              StatCard(icon: Icons.people, title: 'Aspirantes', value: _aspirantesEnUnidad.toString(), color: Colors.blue),
              StatCard(icon: Icons.pending_actions, title: 'Por revisar', value: _pendientesRevision.toString(), color: Colors.orange),
            ],
          ),
        ] else ...[
          const EmptyState(
            icon: Icons.group_off,
            title: 'No estas asignado a una unidad',
            subtitle: 'Contacta al Director',
          ),
        ],
        const SizedBox(height: 24),
        _buildEventosSection(),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Acciones Rapidas'),
        const SizedBox(height: 12),
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildUnidadCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.1),
                  AppTheme.primaryGreen.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.group, color: AppTheme.primaryGreen, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_unidadNombre,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('$_aspirantesEnUnidad aspirantes asignados',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => widget.onNavigateToTab?.call(1),
            icon: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // ══════════════════════ ASPIRANTE ══════════════════════

  Widget _buildAspiranteContent() {
    final porcentaje = _carpetaTotal > 0 ? _carpetaAprobados / _carpetaTotal : 0.0;
    final asistStr = _miAsistencia > 0 ? '${_miAsistencia.toStringAsFixed(0)}%' : '--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Mi Carpeta de Investidura'),
        const SizedBox(height: 12),
        _buildCarpetaProgressCard(porcentaje),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            StatCard(icon: Icons.fact_check, title: 'Asistencia', value: asistStr, color: Colors.purple),
            StatCard(icon: Icons.upcoming, title: 'Proximos', value: _proximosEventos.length.toString(), color: Colors.amber),
          ],
        ),
        if (_carpetaDevueltos > 0) ...[
          const SizedBox(height: 12),
          _buildAlertCard(
            icon: Icons.replay,
            color: AppTheme.warningOrange,
            title: '$_carpetaDevueltos requisitos devueltos',
            subtitle: 'Revisa los comentarios y re-envia',
            onTap: () => widget.onNavigateToTab?.call(1),
          ),
        ],
        if (_carpetaEnviados > 0) ...[
          const SizedBox(height: 12),
          _buildAlertCard(
            icon: Icons.hourglass_top,
            color: AppTheme.accentGold,
            title: '$_carpetaEnviados requisitos en revision',
            subtitle: 'Esperando que tu consejero los revise',
          ),
        ],
        const SizedBox(height: 24),
        _buildEventosSection(),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Acciones Rapidas'),
        const SizedBox(height: 12),
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildCarpetaProgressCard(double porcentaje) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        color: Theme.of(context).colorScheme.surface,
      ),
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
                  color: porcentaje >= 1.0 ? AppTheme.successGreen : AppTheme.primaryGreen,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${(porcentaje * 100).toInt()}%',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
                const SizedBox(height: 10),
                _buildProgressRow(Icons.check_circle, 'Aprobados', '$_carpetaAprobados/$_carpetaTotal', AppTheme.successGreen),
                const SizedBox(height: 6),
                _buildProgressRow(Icons.pending, 'Completados', '$_carpetaCompletados/$_carpetaTotal', AppTheme.accentGold),
              ],
            ),
          ),
          IconButton(
            onPressed: () => widget.onNavigateToTab?.call(1),
            icon: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ),
        ],
      ),
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

  Widget _buildWelcomeCard() {
    final user = _auth.currentUser;
    final nombre = user?.nombre ?? 'Guia';
    final rol = user?.rol ?? '';

    return GradientCard(
      colors: const [
        AppTheme.primaryGreenDark,
        AppTheme.primaryGreen,
        Color(0xFF43A047),
      ],
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $nombre!',
                  style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.9)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Club GMU Doulos',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    rol,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: UserAvatar(
              fotoUrl: user?.fotoUrl,
              iniciales: user?.iniciales ?? 'U',
              radius: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: onTap != null ? Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]) : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildEventosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Proximos Eventos',
          actionLabel: 'Ver todos',
          onAction: () => widget.onNavigateToTab?.call(2),
        ),
        const SizedBox(height: 12),
        _buildEventsList(),
      ],
    );
  }

  Widget _buildEventsList() {
    if (_proximosEventos.isEmpty) {
      return const EmptyState(
        icon: Icons.event_available,
        title: 'No hay eventos proximos',
      );
    }

    return Column(
      children: _proximosEventos.map((evento) {
        final diasRestantes = evento.diasRestantes;
        final subtitulo = diasRestantes == 0
            ? 'Hoy - ${evento.hora}'
            : diasRestantes == 1
                ? 'Manana - ${evento.hora}'
                : '${evento.fecha.day}/${evento.fecha.month} - ${evento.hora}';
        final color = _getTipoColor(evento.tipo);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Borde izquierdo coloreado
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.08),
                            color.withValues(alpha: 0.18),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getTipoIcon(evento.tipo), color: color, size: 22),
                    ),
                    title: Text(evento.titulo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(subtitulo, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                    onTap: () => widget.onNavigateToTab?.call(2),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions() {
    if (_auth.isAdmin) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickActionButton(icon: Icons.person_add, label: 'Agregar\nMiembro', color: Colors.blue, onTap: () => widget.onNavigateToTab?.call(1)),
          QuickActionButton(icon: Icons.add_task, label: 'Registrar\nAsistencia', color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AsistenciaScreen()))),
          QuickActionButton(icon: Icons.group_work, label: 'Ver\nUnidades', color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UnidadesScreen()))),
          QuickActionButton(icon: Icons.event, label: 'Nuevo\nEvento', color: Colors.purple, onTap: () => widget.onNavigateToTab?.call(2)),
        ],
      );
    } else if (_auth.isConsejero) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickActionButton(icon: Icons.group, label: 'Mi\nUnidad', color: Colors.blue, onTap: () => widget.onNavigateToTab?.call(1)),
          QuickActionButton(icon: Icons.folder_special, label: 'Revisar\nCarpetas', color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CarpetaReviewScreen()))),
          QuickActionButton(icon: Icons.add_task, label: 'Registrar\nAsistencia', color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AsistenciaScreen()))),
          QuickActionButton(icon: Icons.menu_book, label: 'Manual', color: Colors.purple, onTap: () => widget.onNavigateToTab?.call(3)),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickActionButton(icon: Icons.folder, label: 'Mi\nCarpeta', color: Colors.blue, onTap: () => widget.onNavigateToTab?.call(1)),
          QuickActionButton(icon: Icons.calendar_month, label: 'Ver\nCalendario', color: Colors.green, onTap: () => widget.onNavigateToTab?.call(2)),
          QuickActionButton(icon: Icons.menu_book, label: 'Manual', color: Colors.orange, onTap: () => widget.onNavigateToTab?.call(3)),
          QuickActionButton(icon: Icons.notifications, label: 'Avisos', color: Colors.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificacionesScreen()))),
        ],
      );
    }
  }
}
