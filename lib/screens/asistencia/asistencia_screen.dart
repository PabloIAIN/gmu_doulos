import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({super.key});

  @override
  State<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();

  // Unidades
  List<Map<String, dynamic>> _unidades = [];
  Map<String, dynamic>? _unidadSeleccionada;
  List<Map<String, dynamic>> _miembrosUnidad = [];

  // Fecha
  DateTime _fechaSeleccionada = DateTime.now();
  String _diaSemana = '';
  bool _esDomingo = false;

  // Asistencia por miembro: {miembroId: {puntualidad, panoleta, biblia, cuota}}
  Map<String, Map<String, dynamic>> _asistencia = {};

  bool _isLoading = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _inicializarFecha();
    _cargarDatos();
  }

  void _inicializarFecha() {
    final hoy = DateTime.now();
    if (hoy.weekday == DateTime.saturday) {
      _fechaSeleccionada = hoy;
    } else if (hoy.weekday == DateTime.sunday) {
      _fechaSeleccionada = hoy;
    } else {
      // Entre semana: ir al sábado más reciente
      var d = hoy;
      while (d.weekday != DateTime.saturday) {
        d = d.subtract(const Duration(days: 1));
      }
      _fechaSeleccionada = d;
    }
    _actualizarDiaSemana();
  }

  void _actualizarDiaSemana() {
    if (_fechaSeleccionada.weekday == DateTime.saturday) {
      _diaSemana = 'sabado';
      _esDomingo = false;
    } else if (_fechaSeleccionada.weekday == DateTime.sunday) {
      _diaSemana = 'domingo';
      _esDomingo = true;
    } else {
      _diaSemana = '';
      _esDomingo = false;
    }
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      if (_auth.isAdmin) {
        final unidades = await _db.getUnidades();
        setState(() {
          _unidades = unidades;
          if (_unidadSeleccionada == null && unidades.isNotEmpty) {
            _unidadSeleccionada = unidades.first;
          }
        });
        if (_unidadSeleccionada != null) {
          await _cargarMiembrosYAsistencia(_unidadSeleccionada!['id'] as String);
        } else {
          setState(() => _isLoading = false);
        }
      } else if (_auth.isConsejero) {
        final unidad = await _db.getUnidadDeConsejero(_auth.currentUser!.id);
        if (unidad != null) {
          setState(() => _unidadSeleccionada = unidad);
          await _cargarMiembrosYAsistencia(unidad['id'] as String);
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _cargarMiembrosYAsistencia(String unidadId) async {
    final miembros = await _db.getMiembrosDeUnidad(unidadId);
    final aspirantes = miembros
        .where((m) => m['rol_en_unidad'] == 'aspirante')
        .toList();

    final fechaStr = _fechaSeleccionada.toIso8601String().substring(0, 10);
    final registros = await _db.getAsistenciaPorUnidadFecha(unidadId, fechaStr);

    // Inicializar asistencia para todos los aspirantes
    final asistencia = <String, Map<String, dynamic>>{};
    for (final m in aspirantes) {
      final id = m['miembro_id'] as String;
      asistencia[id] = {
        'puntualidad': 'ausente',
        'panoleta': false,
        'biblia': false,
        'cuota': false,
      };
    }

    // Llenar con registros existentes
    for (final r in registros) {
      final id = r['miembro_id'] as String;
      if (asistencia.containsKey(id)) {
        asistencia[id] = {
          'puntualidad': r['puntualidad'] as String,
          'panoleta': r['panoleta'] == 1,
          'biblia': r['biblia'] == 1,
          'cuota': r['cuota'] == 1,
        };
      }
    }

    setState(() {
      _miembrosUnidad = aspirantes;
      _asistencia = asistencia;
      _isLoading = false;
    });
  }

  void _navegarFecha(int direccion) {
    setState(() {
      if (direccion > 0) {
        // Adelante: sab→dom→sig sab
        if (_fechaSeleccionada.weekday == DateTime.saturday) {
          _fechaSeleccionada = _fechaSeleccionada.add(const Duration(days: 1));
        } else {
          _fechaSeleccionada = _fechaSeleccionada.add(const Duration(days: 6));
        }
      } else {
        // Atrás: dom→sab→ant dom
        if (_fechaSeleccionada.weekday == DateTime.sunday) {
          _fechaSeleccionada = _fechaSeleccionada.subtract(const Duration(days: 1));
        } else {
          _fechaSeleccionada = _fechaSeleccionada.subtract(const Duration(days: 6));
        }
      }
      _actualizarDiaSemana();
    });
    if (_unidadSeleccionada != null) {
      _cargarMiembrosYAsistencia(_unidadSeleccionada!['id'] as String);
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      selectableDayPredicate: (date) =>
          date.weekday == DateTime.saturday || date.weekday == DateTime.sunday,
    );
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
        _actualizarDiaSemana();
      });
      if (_unidadSeleccionada != null) {
        _cargarMiembrosYAsistencia(_unidadSeleccionada!['id'] as String);
      }
    }
  }

  int get _presentes => _asistencia.values
      .where((a) => a['puntualidad'] == 'presente')
      .length;

  int get _tardanzas => _asistencia.values
      .where((a) => a['puntualidad'] == 'tardanza')
      .length;

  int get _ausentes => _asistencia.values
      .where((a) => a['puntualidad'] == 'ausente')
      .length;

  double get _porcentaje {
    if (_asistencia.isEmpty) return 0;
    return ((_presentes + _tardanzas) / _asistencia.length) * 100;
  }

  Future<void> _guardarAsistencia() async {
    if (_unidadSeleccionada == null || _diaSemana.isEmpty) return;
    setState(() => _guardando = true);

    try {
      final registros = _miembrosUnidad.map((m) {
        final miembroId = m['miembro_id'] as String;
        final data = _asistencia[miembroId]!;
        return {
          'miembroId': miembroId,
          'puntualidad': data['puntualidad'] as String,
          'panoleta': data['panoleta'] as bool,
          'biblia': data['biblia'] as bool,
          'cuota': _esDomingo ? (data['cuota'] as bool) : false,
        };
      }).toList();

      await _db.registrarAsistenciaUnidad(
        unidadId: _unidadSeleccionada!['id'] as String,
        fecha: _fechaSeleccionada.toIso8601String().substring(0, 10),
        diaSemana: _diaSemana,
        registros: registros,
        registradoPor: _auth.currentUser!.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Asistencia guardada: ${_presentes + _tardanzas} de ${_miembrosUnidad.length} asistieron'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
    setState(() => _guardando = false);
  }

  String _formatFecha(DateTime fecha) {
    const dias = ['Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'];
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${dias[fecha.weekday - 1]}, ${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _unidadSeleccionada == null
              ? _buildSinUnidad()
              : _miembrosUnidad.isEmpty
                  ? _buildSinMiembros()
                  : Column(
                      children: [
                        _buildFechaSelector(),
                        if (_auth.isAdmin) _buildUnidadSelector(),
                        _buildResumen(),
                        _buildBotonesRapidos(),
                        Expanded(child: _buildListaMiembros()),
                        // Boton guardar fijo abajo
                        if (_diaSemana.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton.icon(
                                onPressed: _guardando ? null : _guardarAsistencia,
                                icon: _guardando
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.save_rounded),
                                label: Text(
                                  _guardando ? 'Guardando...' : 'Guardar Asistencia',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
    );
  }

  Widget _buildFechaSelector() {
    final horario = _diaSemana == 'sabado'
        ? '7:00 - 9:00 AM'
        : _diaSemana == 'domingo'
            ? '8:00 - 10:00 AM'
            : '';

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _navegarFecha(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _seleccionarFecha,
              child: Column(
                children: [
                  Text(
                    _formatFecha(_fechaSeleccionada),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (horario.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        horario,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => _navegarFecha(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildUnidadSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: DropdownButtonFormField<String>(
        initialValue: _unidadSeleccionada?['id'] as String?,
        decoration: const InputDecoration(
          labelText: 'Unidad',
          prefixIcon: Icon(Icons.group_work),
          isDense: true,
        ),
        isExpanded: true,
        items: _unidades.map((u) {
          return DropdownMenuItem(
            value: u['id'] as String,
            child: Text(u['nombre'] as String),
          );
        }).toList(),
        onChanged: (id) {
          final unidad = _unidades.firstWhere((u) => u['id'] == id);
          setState(() => _unidadSeleccionada = unidad);
          _cargarMiembrosYAsistencia(id!);
        },
      ),
    );
  }

  Widget _buildResumen() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Presentes', _presentes.toString(), Icons.check_circle),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStatItem('Tardanzas', _tardanzas.toString(), Icons.schedule),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStatItem('Ausentes', _ausentes.toString(), Icons.cancel),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStatItem('${_porcentaje.toStringAsFixed(0)}%', '${_miembrosUnidad.length}', Icons.people),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildBotonesRapidos() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '${_miembrosUnidad.length} miembros',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              setState(() {
                for (final id in _asistencia.keys) {
                  _asistencia[id]!['puntualidad'] = 'presente';
                }
              });
            },
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Todos'),
          ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                for (final id in _asistencia.keys) {
                  _asistencia[id]!['puntualidad'] = 'ausente';
                }
              });
            },
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Ninguno'),
          ),
        ],
      ),
    );
  }

  Widget _buildListaMiembros() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: _miembrosUnidad.length,
      itemBuilder: (context, index) {
        final miembro = _miembrosUnidad[index];
        final miembroId = miembro['miembro_id'] as String;
        final nombre = '${miembro['nombre']} ${miembro['apellido']}';
        final data = _asistencia[miembroId]!;
        final puntualidad = data['puntualidad'] as String;

        Color cardBorder;
        if (puntualidad == 'presente') {
          cardBorder = AppTheme.successGreen;
        } else if (puntualidad == 'tardanza') {
          cardBorder = Colors.amber;
        } else {
          cardBorder = Colors.red.shade300;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: cardBorder, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: cardBorder.withValues(alpha: 0.15),
                      child: Text(
                        '${miembro['nombre']}'.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cardBorder,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Puntualidad
                Row(
                  children: [
                    const SizedBox(width: 8),
                    const Text('Puntualidad', style: TextStyle(fontSize: 13)),
                    const Spacer(),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'presente',
                          label: Text('P', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.check_circle, size: 14),
                        ),
                        ButtonSegment(
                          value: 'tardanza',
                          label: Text('T', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.schedule, size: 14),
                        ),
                        ButtonSegment(
                          value: 'ausente',
                          label: Text('A', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.cancel, size: 14),
                        ),
                      ],
                      selected: {puntualidad},
                      onSelectionChanged: (val) {
                        setState(() {
                          _asistencia[miembroId]!['puntualidad'] = val.first;
                        });
                      },
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 16),

                // Pañoleta
                _buildSwitchRow(
                  icon: Icons.dry_cleaning,
                  label: 'Panoleta',
                  value: data['panoleta'] as bool,
                  color: Colors.indigo,
                  onChanged: (val) {
                    setState(() {
                      _asistencia[miembroId]!['panoleta'] = val;
                    });
                  },
                ),

                // Biblia
                _buildSwitchRow(
                  icon: Icons.menu_book,
                  label: 'Biblia',
                  value: data['biblia'] as bool,
                  color: Colors.brown,
                  onChanged: (val) {
                    setState(() {
                      _asistencia[miembroId]!['biblia'] = val;
                    });
                  },
                ),

                // Cuota (solo domingos)
                if (_esDomingo)
                  _buildSwitchRow(
                    icon: Icons.payments,
                    label: 'Cuota \$10',
                    value: data['cuota'] as bool,
                    color: AppTheme.successGreen,
                    onChanged: (val) {
                      setState(() {
                        _asistencia[miembroId]!['cuota'] = val;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String label,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          SizedBox(
            height: 32,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinUnidad() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No estas asignado a una unidad',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Contacta al Director para ser asignado',
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildSinMiembros() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No hay aspirantes en esta unidad',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Asigna miembros desde la seccion de Unidades',
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
