import 'package:flutter/material.dart';
import '../../models/miembro.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';

class EspecialidadesScreen extends StatefulWidget {
  const EspecialidadesScreen({super.key});

  @override
  State<EspecialidadesScreen> createState() => _EspecialidadesScreenState();
}

class _EspecialidadesScreenState extends State<EspecialidadesScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  String _categoriaSeleccionada = 'Todas';
  List<Map<String, dynamic>> _especialidades = [];
  List<Miembro> _miembros = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categorias = [
    {'nombre': 'Todas', 'icon': Icons.apps, 'color': Colors.grey},
    {'nombre': 'Actividades Misioneras', 'icon': Icons.volunteer_activism, 'color': Colors.red},
    {'nombre': 'Artes y Habilidades', 'icon': Icons.palette, 'color': Colors.purple},
    {'nombre': 'Naturaleza', 'icon': Icons.eco, 'color': Colors.green},
    {'nombre': 'Actividades Recreativas', 'icon': Icons.sports_soccer, 'color': Colors.orange},
    {'nombre': 'Industrias Agrícolas', 'icon': Icons.agriculture, 'color': Colors.brown},
    {'nombre': 'Hogar', 'icon': Icons.home, 'color': Colors.blue},
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final especialidades = await _db.getEspecialidades();
      final miembros = await _db.getMiembros();
      setState(() {
        _especialidades = especialidades;
        _miembros = miembros.where((m) => m.activo).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _especialidadesFiltradas {
    if (_categoriaSeleccionada == 'Todas') return _especialidades;
    return _especialidades
        .where((e) => e['categoria'] == _categoriaSeleccionada)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Especialidades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categorias.length,
                    itemBuilder: (context, index) {
                      final cat = _categorias[index];
                      final isSelected = _categoriaSeleccionada == cat['nombre'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(cat['nombre']),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _categoriaSeleccionada = cat['nombre']);
                          },
                          avatar: Icon(cat['icon'], size: 18,
                              color: isSelected ? Colors.white : cat['color']),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_especialidadesFiltradas.length} especialidades',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        '${_especialidades.length} total',
                        style: TextStyle(color: Colors.green[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _especialidadesFiltradas.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _cargarDatos,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _especialidadesFiltradas.length,
                            itemBuilder: (context, index) {
                              return _buildEspecialidadCard(
                                  _especialidadesFiltradas[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: _auth.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showEspecialidadFormDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Nueva'),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No hay especialidades',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Presiona + para agregar una',
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildEspecialidadCard(Map<String, dynamic> esp) {
    final requisitos = esp['requisitos'] as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEspecialidadDetail(esp),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(esp['nombre'],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(esp['categoria'],
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$requisitos req.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    esp['nivel'] ?? '',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEspecialidadDetail(Map<String, dynamic> esp) async {
    final miembrosAsignados = await _db.getMiembrosDeEspecialidad(esp['id']);

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EspecialidadDetailSheet(
        especialidad: esp,
        miembrosAsignados: miembrosAsignados,
        todosLosMiembros: _miembros,
        db: _db,
        isAdmin: _auth.isAdmin,
        onChanged: () {
          _cargarDatos();
        },
        onEdit: () {
          Navigator.pop(context);
          _showEspecialidadFormDialog(context, especialidad: esp);
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(esp);
        },
      ),
    );
  }

  void _showEspecialidadFormDialog(BuildContext context,
      {Map<String, dynamic>? especialidad}) {
    final isEditing = especialidad != null;
    final nombreController =
        TextEditingController(text: especialidad?['nombre'] ?? '');
    final requisitosController = TextEditingController(
        text: especialidad?['requisitos']?.toString() ?? '8');
    String selectedCategoria =
        especialidad?['categoria'] ?? 'Actividades Recreativas';
    String selectedNivel = especialidad?['nivel'] ?? 'Básico';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                        isEditing ? 'Editar Especialidad' : 'Nueva Especialidad',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.emoji_events),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategoria,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category),
                    ),
                    isExpanded: true,
                    items: _categorias
                        .where((c) => c['nombre'] != 'Todas')
                        .map((c) => DropdownMenuItem(
                              value: c['nombre'] as String,
                              child: Text(c['nombre'] as String),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setModalState(() => selectedCategoria = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedNivel,
                    decoration: const InputDecoration(
                      labelText: 'Nivel',
                      prefixIcon: Icon(Icons.signal_cellular_alt),
                    ),
                    items: ['Básico', 'Avanzado']
                        .map((n) =>
                            DropdownMenuItem(value: n, child: Text(n)))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedNivel = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: requisitosController,
                    decoration: const InputDecoration(
                      labelText: 'Número de requisitos',
                      prefixIcon: Icon(Icons.checklist),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (nombreController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('El nombre es obligatorio')),
                          );
                          return;
                        }
                        final data = {
                          'id': especialidad?['id'] ??
                              DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                          'nombre': nombreController.text,
                          'categoria': selectedCategoria,
                          'nivel': selectedNivel,
                          'requisitos':
                              int.tryParse(requisitosController.text) ?? 8,
                        };
                        if (isEditing) {
                          await _db.updateEspecialidad(data);
                        } else {
                          await _db.insertEspecialidad(data);
                        }
                        await _cargarDatos();
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEditing
                                  ? 'Especialidad actualizada'
                                  : 'Especialidad creada'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(
                          isEditing ? 'Guardar cambios' : 'Crear especialidad'),
                      style: ElevatedButton.styleFrom(
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

  void _confirmDelete(Map<String, dynamic> esp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar especialidad'),
        content: Text('¿Eliminar "${esp['nombre']}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              await _db.deleteEspecialidad(esp['id']);
              await _cargarDatos();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Especialidad eliminada'),
                      backgroundColor: Colors.red),
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
}

// Widget separado para el detalle con seguimiento de progreso
class _EspecialidadDetailSheet extends StatefulWidget {
  final Map<String, dynamic> especialidad;
  final List<Map<String, dynamic>> miembrosAsignados;
  final List<Miembro> todosLosMiembros;
  final DatabaseService db;
  final bool isAdmin;
  final VoidCallback onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EspecialidadDetailSheet({
    required this.especialidad,
    required this.miembrosAsignados,
    required this.todosLosMiembros,
    required this.db,
    this.isAdmin = false,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_EspecialidadDetailSheet> createState() =>
      _EspecialidadDetailSheetState();
}

class _EspecialidadDetailSheetState extends State<_EspecialidadDetailSheet> {
  late List<Map<String, dynamic>> _asignados;

  @override
  void initState() {
    super.initState();
    _asignados = List.from(widget.miembrosAsignados);
  }

  Future<void> _recargarAsignados() async {
    final data = await widget.db
        .getMiembrosDeEspecialidad(widget.especialidad['id']);
    setState(() => _asignados = data);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final esp = widget.especialidad;
    final totalRequisitos = esp['requisitos'] as int;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(24),
        child: ListView(
          controller: scrollController,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.emoji_events, size: 40,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(esp['nombre'],
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(esp['categoria'],
                          style: TextStyle(color: Colors.grey[600])),
                      Text('${esp['nivel']} - $totalRequisitos requisitos',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                if (widget.isAdmin)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'editar',
                          child: Row(children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Editar')
                          ])),
                      const PopupMenuItem(
                          value: 'eliminar',
                          child: Row(children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar',
                                style: TextStyle(color: Colors.red))
                          ])),
                    ],
                    onSelected: (value) {
                      if (value == 'editar') widget.onEdit();
                      if (value == 'eliminar') widget.onDelete();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Miembros asignados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Miembros asignados (${_asignados.length})',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _showAsignarMiembroDialog(context),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Asignar'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_asignados.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.people_outline,
                            size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('Sin miembros asignados',
                            style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Text('Presiona "Asignar" para agregar',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              )
            else
              ..._asignados.map((ma) => _buildMiembroProgresoCard(
                  ma, totalRequisitos)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiembroProgresoCard(
      Map<String, dynamic> ma, int totalRequisitos) {
    final completados = ma['requisitos_completados'] as int;
    final progreso =
        totalRequisitos > 0 ? completados / totalRequisitos : 0.0;
    final completado = ma['completado'] == 1;
    final nombre = '${ma['nombre']} ${ma['apellido']}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  completado ? Icons.check_circle : Icons.person,
                  color: completado ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        completado
                            ? 'Completada'
                            : '$completados de $totalRequisitos requisitos',
                        style: TextStyle(
                          fontSize: 12,
                          color: completado ? Colors.green : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Botones + y -
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: completados > 0
                      ? () async {
                          await widget.db.actualizarProgresoEspecialidad(
                            miembroId: ma['miembro_id'],
                            especialidadId: widget.especialidad['id'],
                            requisitosCompletados: completados - 1,
                            totalRequisitos: totalRequisitos,
                          );
                          await _recargarAsignados();
                        }
                      : null,
                  color: Colors.red,
                ),
                Text('$completados',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: completados < totalRequisitos
                      ? () async {
                          await widget.db.actualizarProgresoEspecialidad(
                            miembroId: ma['miembro_id'],
                            especialidadId: widget.especialidad['id'],
                            requisitosCompletados: completados + 1,
                            totalRequisitos: totalRequisitos,
                          );
                          await _recargarAsignados();
                        }
                      : null,
                  color: Colors.green,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () async {
                    await widget.db.desasignarEspecialidad(
                      miembroId: ma['miembro_id'],
                      especialidadId: widget.especialidad['id'],
                    );
                    await _recargarAsignados();
                  },
                  color: Colors.grey,
                  tooltip: 'Desasignar',
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progreso,
              backgroundColor: Colors.grey[200],
              color: completado
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  void _showAsignarMiembroDialog(BuildContext context) {
    final asignadosIds =
        _asignados.map((a) => a['miembro_id'] as String).toSet();
    final disponibles = widget.todosLosMiembros
        .where((m) => !asignadosIds.contains(m.id))
        .toList();

    if (disponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los miembros ya están asignados')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Asignar miembro'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: disponibles.length,
            itemBuilder: (context, index) {
              final miembro = disponibles[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(miembro.iniciales),
                ),
                title: Text(miembro.nombreCompleto),
                subtitle: Text(miembro.clase),
                onTap: () async {
                  await widget.db.asignarEspecialidad(
                    miembroId: miembro.id,
                    especialidadId: widget.especialidad['id'],
                  );
                  await _recargarAsignados();
                  if (context.mounted) Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar')),
        ],
      ),
    );
  }
}
