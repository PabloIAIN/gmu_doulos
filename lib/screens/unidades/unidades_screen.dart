import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class UnidadesScreen extends StatefulWidget {
  const UnidadesScreen({super.key});

  @override
  State<UnidadesScreen> createState() => _UnidadesScreenState();
}

class _UnidadesScreenState extends State<UnidadesScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _unidades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarUnidades();
  }

  Future<void> _cargarUnidades() async {
    setState(() => _isLoading = true);
    try {
      final unidades = await _db.getUnidades();
      // Cargar conteos para cada unidad
      final unidadesConConteo = <Map<String, dynamic>>[];
      for (final u in unidades) {
        final miembros = await _db.getMiembrosDeUnidad(u['id']);
        final consejeros =
            miembros.where((m) => m['rol_en_unidad'] == 'consejero').length;
        final aspirantes =
            miembros.where((m) => m['rol_en_unidad'] == 'aspirante').length;
        unidadesConConteo.add({
          ...u,
          '_consejeros': consejeros,
          '_aspirantes': aspirantes,
        });
      }
      setState(() {
        _unidades = unidadesConConteo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarFormulario({Map<String, dynamic>? unidad}) {
    final nombreCtrl = TextEditingController(text: unidad?['nombre'] ?? '');
    final descCtrl = TextEditingController(text: unidad?['descripcion'] ?? '');
    final isEdit = unidad != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? 'Editar Unidad' : 'Nueva Unidad',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la unidad',
                prefixIcon: Icon(Icons.group_work),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripcion (opcional)',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final nombre = nombreCtrl.text.trim();
                if (nombre.isEmpty) return;

                if (isEdit) {
                  await _db.updateUnidad({
                    'id': unidad['id'],
                    'nombre': nombre,
                    'descripcion': descCtrl.text.trim(),
                  });
                } else {
                  final id = DateTime.now().millisecondsSinceEpoch.toString();
                  await _db.insertUnidad({
                    'id': id,
                    'nombre': nombre,
                    'descripcion': descCtrl.text.trim(),
                    'activo': 1,
                    'fecha_creacion': DateTime.now().toIso8601String(),
                  });
                }

                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _cargarUnidades();
              },
              child: Text(isEdit ? 'Guardar Cambios' : 'Crear Unidad'),
            ),
          ],
        ),
      ),
    );
  }

  void _verDetalle(Map<String, dynamic> unidad) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _UnidadDetalleScreen(
          unidadId: unidad['id'],
          nombre: unidad['nombre'],
          onChanged: _cargarUnidades,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unidades')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _unidades.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_work, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text('No hay unidades creadas',
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _mostrarFormulario(),
                        icon: const Icon(Icons.add),
                        label: const Text('Crear Unidad'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarUnidades,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _unidades.length,
                    itemBuilder: (ctx, i) {
                      final u = _unidades[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1),
                            child: Icon(Icons.group_work,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          title: Text(u['nombre'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${u['_consejeros']} consejeros - ${u['_aspirantes']} aspirantes',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 16),
                          onTap: () => _verDetalle(u),
                          onLongPress: () => _mostrarFormulario(unidad: u),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── Detalle de Unidad ──
class _UnidadDetalleScreen extends StatefulWidget {
  final String unidadId;
  final String nombre;
  final VoidCallback onChanged;

  const _UnidadDetalleScreen({
    required this.unidadId,
    required this.nombre,
    required this.onChanged,
  });

  @override
  State<_UnidadDetalleScreen> createState() => _UnidadDetalleScreenState();
}

class _UnidadDetalleScreenState extends State<_UnidadDetalleScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _miembrosUnidad = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    final miembros = await _db.getMiembrosDeUnidad(widget.unidadId);
    setState(() {
      _miembrosUnidad = miembros;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _consejeros =>
      _miembrosUnidad.where((m) => m['rol_en_unidad'] == 'consejero').toList();

  List<Map<String, dynamic>> get _aspirantes =>
      _miembrosUnidad.where((m) => m['rol_en_unidad'] == 'aspirante').toList();

  Future<void> _asignarMiembro(String rolEnUnidad) async {
    // Obtener todos los miembros activos y los que ya estan en CUALQUIER unidad
    final db = await _db.database;
    final todosQuery = await db.query('miembros', where: 'activo = 1');

    // Consultar TODAS las asignaciones de unidad (no solo la actual)
    final todasAsignaciones = await db.query('unidad_miembros');
    final idsAsignados =
        todasAsignaciones.map((m) => m['miembro_id']).toSet();

    final disponibles = todosQuery
        .where((m) => !idsAsignados.contains(m['id']))
        .toList();

    // Filtrar por rol adecuado
    final filtrados = disponibles.where((m) {
      if (rolEnUnidad == 'consejero') {
        return m['rol'] == 'Consejero' || m['rol'] == 'Instructor';
      } else {
        return m['rol'] == 'Miembro';
      }
    }).toList();

    if (!mounted) return;

    if (filtrados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rolEnUnidad == 'consejero'
              ? 'No hay consejeros/instructores disponibles (todos ya estan asignados a una unidad)'
              : 'No hay aspirantes disponibles (todos ya estan asignados a una unidad)'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Asignar ${rolEnUnidad == 'consejero' ? 'Consejero' : 'Aspirante'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 0),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filtrados.length,
              itemBuilder: (_, i) {
                final m = filtrados[i];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      '${(m['nombre'] as String)[0]}${(m['apellido'] as String)[0]}'
                          .toUpperCase(),
                    ),
                  ),
                  title: Text('${m['nombre']} ${m['apellido']}'),
                  subtitle: Text(m['rol'] as String),
                  onTap: () async {
                    await _db.asignarMiembroAUnidad(
                      unidadId: widget.unidadId,
                      miembroId: m['id'] as String,
                      rolEnUnidad: rolEnUnidad,
                    );
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    _cargar();
                    widget.onChanged();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _desasignar(String miembroId, String nombreCompleto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desasignar miembro'),
        content: Text('¿Estas seguro de desasignar a $nombreCompleto de esta unidad?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Desasignar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    await _db.desasignarMiembroDeUnidad(
      unidadId: widget.unidadId,
      miembroId: miembroId,
    );
    _cargar();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.nombre)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Consejeros
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Consejeros',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _consejeros.length >= 2
                            ? null
                            : () => _asignarMiembro('consejero'),
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                  if (_consejeros.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text('Sin consejeros asignados',
                              style: TextStyle(color: Colors.grey[500])),
                        ),
                      ),
                    )
                  else
                    ..._consejeros.map((m) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.withValues(alpha: 0.1),
                              child: const Icon(Icons.school,
                                  color: Colors.blue),
                            ),
                            title: Text(
                                '${m['nombre']} ${m['apellido']}'),
                            subtitle: Text(m['rol'] as String),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red),
                              onPressed: () => _desasignar(
                                  m['miembro_id'] as String,
                                  '${m['nombre']} ${m['apellido']}'),
                            ),
                          ),
                        )),

                  const SizedBox(height: 24),

                  // Aspirantes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Aspirantes (${_aspirantes.length}/12)',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _aspirantes.length >= 12
                            ? null
                            : () => _asignarMiembro('aspirante'),
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                  if (_aspirantes.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text('Sin aspirantes asignados',
                              style: TextStyle(color: Colors.grey[500])),
                        ),
                      ),
                    )
                  else
                    ..._aspirantes.map((m) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.withValues(alpha: 0.1),
                              child: Text(
                                '${(m['nombre'] as String)[0]}${(m['apellido'] as String)[0]}'
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              ),
                            ),
                            title: Text(
                                '${m['nombre']} ${m['apellido']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red),
                              onPressed: () => _desasignar(
                                  m['miembro_id'] as String,
                                  '${m['nombre']} ${m['apellido']}'),
                            ),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}
