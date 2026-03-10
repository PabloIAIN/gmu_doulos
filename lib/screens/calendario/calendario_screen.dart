import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/evento.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class CalendarioScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const CalendarioScreen({super.key, this.onOpenDrawer});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  DateTime _selectedDate = DateTime.now();
  List<Evento> _eventos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    setState(() => _isLoading = true);
    try {
      final eventos = await _db.getEventos();
      setState(() {
        _eventos = eventos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar eventos: $e')),
        );
      }
    }
  }

  List<Evento> get _eventosDelDia {
    return _eventos.where((e) =>
      e.fecha.year == _selectedDate.year &&
      e.fecha.month == _selectedDate.month &&
      e.fecha.day == _selectedDate.day
    ).toList();
  }

  List<Evento> get _proximosEventos {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    return _eventos
        .where((e) => !e.fecha.isBefore(inicio))
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
  }

  Future<void> _exportarICS() async {
    if (_eventos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay eventos para exportar')),
      );
      return;
    }
    try {
      final buffer = StringBuffer();
      buffer.writeln('BEGIN:VCALENDAR');
      buffer.writeln('VERSION:2.0');
      buffer.writeln('PRODID:-//GMU Doulos//Calendario//ES');
      for (final evento in _eventos) {
        final fecha = evento.fecha;
        final fechaStr = '${fecha.year}${fecha.month.toString().padLeft(2, '0')}${fecha.day.toString().padLeft(2, '0')}';
        buffer.writeln('BEGIN:VEVENT');
        buffer.writeln('DTSTART;VALUE=DATE:$fechaStr');
        buffer.writeln('SUMMARY:${evento.titulo}');
        if (evento.descripcion.isNotEmpty) {
          buffer.writeln('DESCRIPTION:${evento.descripcion}');
        }
        if (evento.ubicacion.isNotEmpty) {
          buffer.writeln('LOCATION:${evento.ubicacion}');
        }
        buffer.writeln('END:VEVENT');
      }
      buffer.writeln('END:VCALENDAR');

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/gmu_doulos_eventos.ics');
      await file.writeAsString(buffer.toString());
      await Share.shareXFiles([XFile(file.path)], text: 'Eventos GMU Doulos');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
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
    final eventosDelDia = _eventosDelDia;
    final hayEventosHoy = eventosDelDia.isNotEmpty;
    final eventosAMostrar = hayEventosHoy ? eventosDelDia : _proximosEventos;

    return Scaffold(
      appBar: AppBar(
        leading: widget.onOpenDrawer != null
            ? IconButton(icon: const Icon(Icons.menu), onPressed: widget.onOpenDrawer)
            : null,
        title: const Text('Calendario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: 'Exportar .ics',
            onPressed: _exportarICS,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _cargarEventos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: CalendarDatePicker(
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    onDateChanged: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hayEventosHoy
                            ? 'Eventos del ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'
                            : 'Proximos Eventos',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${eventosAMostrar.length} eventos',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: eventosAMostrar.isEmpty
                      ? _buildEmptyState(hayEventosHoy)
                      : RefreshIndicator(
                          onRefresh: _cargarEventos,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: eventosAMostrar.length,
                            itemBuilder: (context, index) {
                              return _buildEventoCard(eventosAMostrar[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: _auth.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showEventoFormDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Evento'),
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildEmptyState(bool esFiltro) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            esFiltro ? 'Sin eventos este día' : 'No hay eventos próximos',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona + para agregar un evento',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildEventoCard(Evento evento) {
    final diasRestantes = evento.diasRestantes;

    final card = Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEventoDetail(evento),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _getTipoColor(evento.tipo).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      evento.fecha.day.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getTipoColor(evento.tipo),
                      ),
                    ),
                    Text(
                      _getMonthName(evento.fecha.month),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTipoColor(evento.tipo),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getTipoIcon(evento.tipo),
                          size: 16,
                          color: _getTipoColor(evento.tipo),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            evento.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          evento.hora,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            evento.ubicacion,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: evento.yaPaso
                      ? Colors.grey.withValues(alpha: 0.1)
                      : diasRestantes <= 3
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  evento.yaPaso
                      ? 'Pasado'
                      : diasRestantes == 0
                          ? 'Hoy'
                          : diasRestantes == 1
                              ? 'Mañana'
                              : '$diasRestantes días',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: evento.yaPaso
                        ? Colors.grey
                        : diasRestantes <= 3
                            ? Colors.red
                            : Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!_auth.isAdmin) return card;

    return Dismissible(
      key: Key(evento.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Eliminar evento'),
            content: Text('¿Eliminar "${evento.titulo}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) async {
        await _db.deleteEvento(evento.id);
        _cargarEventos();
      },
      child: card,
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month - 1];
  }

  void _showEventoDetail(Evento evento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
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
                    color: _getTipoColor(evento.tipo).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTipoIcon(evento.tipo),
                    color: _getTipoColor(evento.tipo),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evento.titulo,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        TiposEvento.getNombre(evento.tipo),
                        style: TextStyle(
                          color: _getTipoColor(evento.tipo),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_auth.isAdmin)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ]),
                      ),
                    ],
                    onSelected: (value) {
                      Navigator.pop(context);
                      if (value == 'editar') {
                        _showEventoFormDialog(context, evento: evento);
                      } else if (value == 'eliminar') {
                        _confirmDelete(evento);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (evento.descripcion.isNotEmpty)
              _buildDetailRow(Icons.description, 'Descripción', evento.descripcion),
            _buildDetailRow(Icons.calendar_today, 'Fecha',
                '${evento.fecha.day}/${evento.fecha.month}/${evento.fecha.year}'),
            _buildDetailRow(Icons.access_time, 'Hora', evento.hora),
            _buildDetailRow(Icons.location_on, 'Ubicación', evento.ubicacion),
            if (!evento.yaPaso) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.timer,
                'Faltan',
                evento.diasRestantes == 0
                    ? 'Es hoy'
                    : evento.diasRestantes == 1
                        ? '1 día'
                        : '${evento.diasRestantes} días',
              ),
            ],
            const SizedBox(height: 24),
            if (_auth.isAdmin)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEventoFormDialog(context, evento: evento);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(evento);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEventoFormDialog(BuildContext context, {Evento? evento}) {
    final isEditing = evento != null;
    final tituloController = TextEditingController(text: evento?.titulo ?? '');
    final descripcionController = TextEditingController(text: evento?.descripcion ?? '');
    final ubicacionController = TextEditingController(text: evento?.ubicacion ?? '');
    String selectedTipo = evento?.tipo ?? 'reunion';
    DateTime selectedFecha = evento?.fecha ?? _selectedDate;
    TimeOfDay selectedHora = evento != null
        ? _parseTimeOfDay(evento.hora)
        : const TimeOfDay(hour: 8, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                        isEditing ? 'Editar Evento' : 'Nuevo Evento',
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      prefixIcon: Icon(Icons.title),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: Icon(Icons.description),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTipo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de evento',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: TiposEvento.tipos
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Row(
                                children: [
                                  Icon(_getTipoIcon(t), size: 20, color: _getTipoColor(t)),
                                  const SizedBox(width: 8),
                                  Text(TiposEvento.getNombre(t)),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedTipo = v!),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedFecha,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedFecha = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${selectedFecha.day}/${selectedFecha.month}/${selectedFecha.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedHora,
                      );
                      if (picked != null) {
                        setModalState(() => selectedHora = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hora',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(_formatTimeOfDay(selectedHora)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ubicacionController,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (tituloController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('El titulo es obligatorio')),
                          );
                          return;
                        }
                        final nuevoEvento = Evento(
                          id: evento?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          titulo: tituloController.text,
                          descripcion: descripcionController.text,
                          fecha: selectedFecha,
                          hora: _formatTimeOfDay(selectedHora),
                          ubicacion: ubicacionController.text,
                          tipo: selectedTipo,
                        );
                        if (isEditing) {
                          await _db.updateEvento(nuevoEvento);
                        } else {
                          await _db.insertEvento(nuevoEvento);
                        }
                        await _cargarEventos();
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEditing ? 'Evento actualizado' : 'Evento creado'),
                              backgroundColor: AppTheme.successGreen,
                            ),
                          );
                        }
                      },
                      icon: Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(isEditing ? 'Guardar cambios' : 'Crear evento'),
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

  void _confirmDelete(Evento evento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: Text('¿Estás seguro de eliminar "${evento.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              await _db.deleteEvento(evento.id);
              await _cargarEventos();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Evento eliminado'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  TimeOfDay _parseTimeOfDay(String hora) {
    try {
      final parts = hora.replaceAll(RegExp(r'[APMapm\s]'), '').split(':');
      int hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      if (hora.toUpperCase().contains('PM') && hour != 12) hour += 12;
      if (hora.toUpperCase().contains('AM') && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
