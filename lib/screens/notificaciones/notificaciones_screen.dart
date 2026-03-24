import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../config/app_config.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final DatabaseService _db = DatabaseService();
  final NotificationService _notifService = NotificationService();
  List<Map<String, dynamic>> _notificaciones = [];
  bool _isLoading = true;
  String _filtro = 'todas'; // todas, no_leidas, leidas

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _notifService.init();
    await _notifService.solicitarPermisos();
    await _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    setState(() => _isLoading = true);
    try {
      final notifs = await _db.getNotificaciones();
      setState(() {
        _notificaciones = notifs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar notificaciones: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _notificacionesFiltradas {
    switch (_filtro) {
      case 'no_leidas':
        return _notificaciones.where((n) => n['leida'] == 0).toList();
      case 'leidas':
        return _notificaciones.where((n) => n['leida'] == 1).toList();
      default:
        return _notificaciones;
    }
  }

  int get _noLeidas =>
      _notificaciones.where((n) => n['leida'] == 0).length;

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'evento':
        return Colors.blue;
      case 'recordatorio':
        return Colors.orange;
      case 'urgente':
        return Colors.red;
      case 'info':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'evento':
        return Icons.event;
      case 'recordatorio':
        return Icons.alarm;
      case 'urgente':
        return Icons.priority_high;
      case 'info':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'evento':
        return 'Evento';
      case 'recordatorio':
        return 'Recordatorio';
      case 'urgente':
        return 'Urgente';
      case 'info':
        return 'Información';
      default:
        return 'General';
    }
  }

  String _formatFecha(String isoDate) {
    try {
      final fecha = DateTime.parse(isoDate);
      final ahora = DateTime.now();
      final diff = ahora.difference(fecha);

      if (diff.isNegative) {
        // Futuro
        final diffAbs = fecha.difference(ahora);
        if (diffAbs.inMinutes < 60) return 'En ${diffAbs.inMinutes} min';
        if (diffAbs.inHours < 24) return 'En ${diffAbs.inHours}h';
        if (diffAbs.inDays == 1) return 'Mañana';
        return '${fecha.day}/${fecha.month} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
      }

      // Pasado
      if (diff.inMinutes < 1) return 'Justo ahora';
      if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
      if (diff.inDays == 1) return 'Ayer';
      if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _notificacionesFiltradas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (_noLeidas > 0)
            TextButton.icon(
              onPressed: _marcarTodasLeidas,
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Leer todas'),
            ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'limpiar_leidas',
                child: Row(children: [
                  Icon(Icons.cleaning_services),
                  SizedBox(width: 8),
                  Text('Limpiar leídas'),
                ]),
              ),
              const PopupMenuItem(
                value: 'test',
                child: Row(children: [
                  Icon(Icons.science),
                  SizedBox(width: 8),
                  Text('Notificación de prueba'),
                ]),
              ),
            ],
            onSelected: (value) {
              if (value == 'limpiar_leidas') _limpiarLeidas();
              if (value == 'test') _enviarPrueba();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtros
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildFiltroChip('Todas', 'todas',
                          _notificaciones.length),
                      const SizedBox(width: 8),
                      _buildFiltroChip(
                          'No leídas', 'no_leidas', _noLeidas),
                      const SizedBox(width: 8),
                      _buildFiltroChip(
                          'Leídas',
                          'leidas',
                          _notificaciones.length - _noLeidas),
                    ],
                  ),
                ),

                // Lista
                Expanded(
                  child: filtradas.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _cargarNotificaciones,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filtradas.length,
                            itemBuilder: (context, index) {
                              return _buildNotificacionCard(filtradas[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCrearRecordatorio(context),
        icon: const Icon(Icons.add_alarm),
        label: const Text('Recordatorio'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFiltroChip(String label, String filtro, int count) {
    final isSelected = _filtro == filtro;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => setState(() => _filtro = filtro),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _filtro == 'no_leidas'
                ? 'No hay notificaciones sin leer'
                : _filtro == 'leidas'
                    ? 'No hay notificaciones leídas'
                    : 'No hay notificaciones',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea un recordatorio con el botón +',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificacionCard(Map<String, dynamic> notif) {
    final leida = notif['leida'] == 1;
    final tipo = notif['tipo'] as String? ?? 'general';
    final color = _getTipoColor(tipo);
    final icon = _getTipoIcon(tipo);
    final fechaStr = _formatFecha(notif['fecha_programada']);

    return Dismissible(
      key: Key(notif['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar notificación'),
            content: Text('¿Eliminar "${notif['titulo']}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        await _db.deleteNotificacion(notif['id']);
        await _cargarNotificaciones();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notificación eliminada'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: leida ? 0 : 2,
        color: leida
            ? null
            : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            if (!leida) {
              await _db.marcarNotificacionLeida(notif['id']);
              await _cargarNotificaciones();
            }
            if (mounted) _showDetalleNotificacion(notif);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif['titulo'],
                              style: TextStyle(
                                fontWeight: leida
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!leida)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      if (notif['mensaje'] != null &&
                          notif['mensaje'] != '') ...[
                        const SizedBox(height: 4),
                        Text(
                          notif['mensaje'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getTipoLabel(tipo),
                              style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.access_time,
                              size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            fechaStr,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetalleNotificacion(Map<String, dynamic> notif) {
    final tipo = notif['tipo'] as String? ?? 'general';
    final color = _getTipoColor(tipo);
    final icon = _getTipoIcon(tipo);

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif['titulo'],
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _getTipoLabel(tipo),
                        style: TextStyle(color: color),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (notif['mensaje'] != null && notif['mensaje'] != '')
              Text(
                notif['mensaje'],
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(
                  'Programada: ${_formatFechaCompleta(notif['fecha_programada'])}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.create, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(
                  'Creada: ${_formatFechaCompleta(notif['fecha_creacion'])}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await _db.deleteNotificacion(notif['id']);
                  await _cargarNotificaciones();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notificación eliminada'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Eliminar',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatFechaCompleta(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final fecha = DateTime.parse(isoDate);
      final meses = [
        '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return '${fecha.day} ${meses[fecha.month]} ${fecha.year}, '
          '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  void _showCrearRecordatorio(BuildContext context) {
    final tituloCtrl = TextEditingController();
    final mensajeCtrl = TextEditingController();
    String tipoSeleccionado = 'recordatorio';
    DateTime fechaSeleccionada = DateTime.now().add(const Duration(hours: 1));
    TimeOfDay horaSeleccionada = TimeOfDay.fromDateTime(fechaSeleccionada);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Nuevo Recordatorio',
                        style: GoogleFonts.poppins(
                            fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: tituloCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(Icons.title),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: mensajeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Mensaje (opcional)',
                      prefixIcon: Icon(Icons.message),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: tipoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'recordatorio', child: Text('Recordatorio')),
                      DropdownMenuItem(
                          value: 'evento', child: Text('Evento')),
                      DropdownMenuItem(
                          value: 'urgente', child: Text('Urgente')),
                      DropdownMenuItem(
                          value: 'info', child: Text('Información')),
                    ],
                    onChanged: (v) =>
                        setModalState(() => tipoSeleccionado = v!),
                  ),
                  const SizedBox(height: 16),
                  // Fecha y hora
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final fecha = await showDatePicker(
                              context: context,
                              initialDate: fechaSeleccionada,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)),
                            );
                            if (fecha != null) {
                              setModalState(() {
                                fechaSeleccionada = DateTime(
                                  fecha.year,
                                  fecha.month,
                                  fecha.day,
                                  horaSeleccionada.hour,
                                  horaSeleccionada.minute,
                                );
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            '${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final hora = await showTimePicker(
                              context: context,
                              initialTime: horaSeleccionada,
                            );
                            if (hora != null) {
                              setModalState(() {
                                horaSeleccionada = hora;
                                fechaSeleccionada = DateTime(
                                  fechaSeleccionada.year,
                                  fechaSeleccionada.month,
                                  fechaSeleccionada.day,
                                  hora.hour,
                                  hora.minute,
                                );
                              });
                            }
                          },
                          icon: const Icon(Icons.access_time, size: 18),
                          label: Text(
                            '${horaSeleccionada.hour.toString().padLeft(2, '0')}:${horaSeleccionada.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (tituloCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('El título es obligatorio')),
                          );
                          return;
                        }
                        await _notifService.crearRecordatorio(
                          titulo: tituloCtrl.text,
                          mensaje: mensajeCtrl.text.isEmpty
                              ? ''
                              : mensajeCtrl.text,
                          fecha: fechaSeleccionada,
                          tipo: tipoSeleccionado,
                        );
                        await _cargarNotificaciones();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Recordatorio creado'),
                              backgroundColor: AppTheme.successGreen,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add_alarm),
                      label: const Text('Crear Recordatorio'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _marcarTodasLeidas() async {
    await _db.marcarTodasLeidas();
    await _cargarNotificaciones();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todas marcadas como leídas')),
      );
    }
  }

  Future<void> _limpiarLeidas() async {
    final leidas =
        _notificaciones.where((n) => n['leida'] == 1).length;
    if (leidas == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay notificaciones leídas')),
      );
      return;
    }
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar leídas'),
        content: Text('¿Eliminar $leidas notificaciones leídas?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await _db.deleteNotificacionesLeidas();
      await _cargarNotificaciones();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$leidas notificaciones eliminadas')),
        );
      }
    }
  }

  Future<void> _enviarPrueba() async {
    await _notifService.mostrarNotificacion(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      titulo: 'Notificación de prueba',
      mensaje:
          'Esta es una notificación de prueba del Club ${AppConfig.appName}. ¡Todo funciona correctamente!',
      tipo: 'info',
    );
    await _cargarNotificaciones();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación de prueba enviada'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
