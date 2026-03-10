import 'package:flutter/material.dart';
import '../../models/miembro.dart';
import '../../services/database_service.dart';
import '../../widgets/user_avatar.dart';
import '../asistencia/historial_asistencia_screen.dart';

class MiembrosScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const MiembrosScreen({super.key, this.onOpenDrawer});

  @override
  State<MiembrosScreen> createState() => _MiembrosScreenState();
}

class _MiembrosScreenState extends State<MiembrosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  String _filtroClase = 'Todos';
  String _filtroRol = 'Todos';
  List<Miembro> _miembros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMiembros();
  }

  Future<void> _cargarMiembros() async {
    setState(() => _isLoading = true);
    try {
      final miembros = await _db.getMiembros();
      setState(() {
        _miembros = miembros;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar miembros: $e')),
        );
      }
    }
  }

  List<Miembro> get _miembrosFiltrados {
    return _miembros.where((m) {
      final matchesSearch = m.nombreCompleto
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      final matchesClase = _filtroClase == 'Todos' || m.clase == _filtroClase;
      final matchesRol = _filtroRol == 'Todos' || m.rol == _filtroRol;
      return matchesSearch && matchesClase && matchesRol;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.onOpenDrawer != null
            ? IconButton(icon: const Icon(Icons.menu), onPressed: widget.onOpenDrawer)
            : null,
        title: const Text('Miembros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarMiembros,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar miembro...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          if (_filtroClase != 'Todos' || _filtroRol != 'Todos')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_filtroClase != 'Todos')
                    Chip(
                      label: Text(_filtroClase),
                      onDeleted: () => setState(() => _filtroClase = 'Todos'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                    ),
                  if (_filtroRol != 'Todos')
                    Chip(
                      label: Text(_filtroRol),
                      onDeleted: () => setState(() => _filtroRol = 'Todos'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_miembrosFiltrados.length} miembros',
                    style: TextStyle(color: Colors.grey[600])),
                Text('${_miembros.where((m) => m.activo).length} activos',
                    style: TextStyle(color: Colors.green[600])),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _miembrosFiltrados.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _cargarMiembros,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _miembrosFiltrados.length,
                          itemBuilder: (context, index) =>
                              _buildMiembroCard(_miembrosFiltrados[index]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMemberDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Agregar'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No hay miembros',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Agrega el primer miembro del club',
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildMiembroCard(Miembro miembro) {
    return Dismissible(
      key: Key(miembro.id),
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
            title: const Text('Eliminar miembro'),
            content: Text('¿Eliminar a ${miembro.nombreCompleto}?'),
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
        await _db.deleteMiembro(miembro.id);
        _cargarMiembros();
      },
      child: Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showMemberDetail(miembro),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              UserAvatar(
                fotoUrl: miembro.fotoUrl,
                iniciales: miembro.iniciales,
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(miembro.nombreCompleto,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                _getClaseColor(miembro.clase).withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            miembro.clase,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getClaseColor(miembro.clase),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (miembro.rol != 'Miembro') ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              miembro.rol,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.amber,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'ver',
                      child: Row(children: [
                        Icon(Icons.visibility),
                        SizedBox(width: 8),
                        Text('Ver perfil')
                      ])),
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
                        Text('Eliminar', style: TextStyle(color: Colors.red))
                      ])),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'ver':
                      _showMemberDetail(miembro);
                      break;
                    case 'editar':
                      _showAddMemberDialog(context, miembro: miembro);
                      break;
                    case 'eliminar':
                      _confirmDelete(miembro);
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Color _getClaseColor(String clase) {
    switch (clase) {
      case 'Guía Mayor Aspirante':
        return Colors.teal;
      case 'Guía Mayor':
        return Colors.indigo;
      case 'Guía Mayor Avanzado':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  void _showFilterDialog() {
    final clases = ['Todos', 'Guía Mayor Aspirante', 'Guía Mayor', 'Guía Mayor Avanzado'];
    final roles = ['Todos', 'Miembro', 'Consejero', 'Instructor', 'Director', 'Director Asociado', 'Secretario', 'Tesorero'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filtros',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (_filtroClase != 'Todos' || _filtroRol != 'Todos')
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _filtroClase = 'Todos';
                          _filtroRol = 'Todos';
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Limpiar filtros'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Clase',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: clases.map((clase) {
                  return FilterChip(
                    label: Text(clase),
                    selected: _filtroClase == clase,
                    onSelected: (selected) {
                      setState(() => _filtroClase = clase);
                      setSheetState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Rol',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: roles.map((rol) {
                  return FilterChip(
                    label: Text(rol),
                    selected: _filtroRol == rol,
                    onSelected: (selected) {
                      setState(() => _filtroRol = rol);
                      setSheetState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showMemberDetail(Miembro miembro) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: UserAvatar(
                  fotoUrl: miembro.fotoUrl,
                  iniciales: miembro.iniciales,
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  miembro.nombreCompleto,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text(miembro.clase)),
                    if (miembro.rol != 'Miembro') Chip(label: Text(miembro.rol)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow(Icons.cake, 'Edad', '${miembro.edad} años'),
              _buildDetailRow(Icons.phone, 'Teléfono', miembro.telefono),
              _buildDetailRow(Icons.email, 'Email', miembro.email),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistorialAsistenciaScreen(
                          miembroId: miembro.id,
                          nombreCompleto: miembro.nombreCompleto,
                          fotoUrl: miembro.fotoUrl,
                          iniciales: miembro.iniciales,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fact_check),
                  label: const Text('Ver historial de asistencia'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, {Miembro? miembro}) {
    final isEditing = miembro != null;
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: miembro?.nombre ?? '');
    final apellidoController = TextEditingController(text: miembro?.apellido ?? '');
    final telefonoController = TextEditingController(text: miembro?.telefono ?? '');
    final emailController = TextEditingController(text: miembro?.email ?? '');
    String selectedClase = miembro?.clase ?? 'Guía Mayor Aspirante';
    String selectedRol = miembro?.rol ?? 'Miembro';
    DateTime selectedDate = miembro?.fechaNacimiento ?? DateTime(2010, 1, 1);

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
              child: Form(
                key: formKey,
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(isEditing ? 'Editar Miembro' : 'Nuevo Miembro',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre *', prefixIcon: Icon(Icons.person)),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: apellidoController,
                    decoration: const InputDecoration(labelText: 'Apellido *', prefixIcon: Icon(Icons.person_outline)),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'El apellido es obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setModalState(() => selectedDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Fecha de nacimiento', prefixIcon: Icon(Icons.cake)),
                      child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: telefonoController,
                    decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone)),
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v != null && v.isNotEmpty && v.length < 7) {
                        return 'Ingresa un teléfono válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v != null && v.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) {
                        return 'Ingresa un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedClase,
                    decoration: const InputDecoration(labelText: 'Clase', prefixIcon: Icon(Icons.school)),
                    items: ['Guía Mayor Aspirante', 'Guía Mayor', 'Guía Mayor Avanzado']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setModalState(() => selectedClase = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRol,
                    decoration: const InputDecoration(labelText: 'Rol', prefixIcon: Icon(Icons.badge)),
                    items: ['Miembro', 'Consejero', 'Instructor', 'Director', 'Director Asociado', 'Secretario', 'Tesorero']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => setModalState(() => selectedRol = v!),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final nuevoMiembro = Miembro(
                          id: miembro?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          nombre: nombreController.text.trim(),
                          apellido: apellidoController.text.trim(),
                          fechaNacimiento: selectedDate,
                          telefono: telefonoController.text.trim(),
                          email: emailController.text.trim(),
                          clase: selectedClase,
                          rol: selectedRol,
                          activo: true,
                        );
                        if (isEditing) {
                          await _db.updateMiembro(nuevoMiembro);
                        } else {
                          await _db.insertMiembro(nuevoMiembro);
                        }
                        await _cargarMiembros();
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEditing ? 'Miembro actualizado' : 'Miembro agregado'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(isEditing ? 'Guardar cambios' : 'Agregar miembro'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Miembro miembro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content: Text('¿Estás seguro de eliminar a ${miembro.nombreCompleto}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              await _db.deleteMiembro(miembro.id);
              await _cargarMiembros();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Miembro eliminado'), backgroundColor: Colors.red));
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