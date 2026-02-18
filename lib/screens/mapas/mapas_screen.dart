import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class MapasScreen extends StatefulWidget {
  const MapasScreen({super.key});

  @override
  State<MapasScreen> createState() => _MapasScreenState();
}

class _MapasScreenState extends State<MapasScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _ubicaciones = [];
  String _categoriaSeleccionada = 'Todas';
  bool _isLoading = true;

  final List<String> _categorias = [
    'Todas',
    'Reunión',
    'Campamento',
    'Emergencia',
    'Actividad',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _cargarUbicaciones();
  }

  Future<void> _cargarUbicaciones() async {
    setState(() => _isLoading = true);
    try {
      final ubicaciones = await _db.getUbicaciones();
      setState(() {
        _ubicaciones = ubicaciones;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ubicaciones: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _ubicacionesFiltradas {
    if (_categoriaSeleccionada == 'Todas') return _ubicaciones;
    return _ubicaciones
        .where((u) => u['categoria'] == _categoriaSeleccionada)
        .toList();
  }

  Color _getCategoriaColor(String categoria) {
    switch (categoria) {
      case 'Reunión':
        return Colors.blue;
      case 'Campamento':
        return Colors.green;
      case 'Emergencia':
        return Colors.red;
      case 'Actividad':
        return Colors.orange;
      case 'Otro':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoriaIcon(String categoria) {
    switch (categoria) {
      case 'Reunión':
        return Icons.groups;
      case 'Campamento':
        return Icons.terrain;
      case 'Emergencia':
        return Icons.local_hospital;
      case 'Actividad':
        return Icons.directions_walk;
      case 'Otro':
        return Icons.place;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _ubicacionesFiltradas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarUbicaciones,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Mapa placeholder
                Container(
                  height: 200,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'Mapa interactivo',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Habilita google_maps_flutter para ver el mapa',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      // Marcadores simulados
                      ...filtradas.asMap().entries.map((entry) {
                        final i = entry.key;
                        final ub = entry.value;
                        final color = _getCategoriaColor(ub['categoria']);
                        // Distribuir los marcadores visualmente
                        final left = 30.0 + (i * 80) % 250;
                        final top = 40.0 + (i * 50) % 120;
                        return Positioned(
                          left: left,
                          top: top,
                          child: Tooltip(
                            message: ub['nombre'],
                            child: Icon(Icons.location_on,
                                color: color, size: 28),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Filtros
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categorias.length,
                    itemBuilder: (context, index) {
                      final cat = _categorias[index];
                      final isSelected = _categoriaSeleccionada == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _categoriaSeleccionada = cat);
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${filtradas.length} ubicaciones',
                          style: TextStyle(color: Colors.grey[600])),
                      Text('${_ubicaciones.length} total',
                          style: TextStyle(color: Colors.green[600])),
                    ],
                  ),
                ),

                // Lista de ubicaciones
                Expanded(
                  child: filtradas.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _cargarUbicaciones,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filtradas.length,
                            itemBuilder: (context, index) {
                              return _buildUbicacionCard(filtradas[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUbicacionForm(context),
        icon: const Icon(Icons.add_location),
        label: const Text('Agregar'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No hay ubicaciones',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Agrega una ubicación con el botón +',
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildUbicacionCard(Map<String, dynamic> ub) {
    final color = _getCategoriaColor(ub['categoria']);
    final icon = _getCategoriaIcon(ub['categoria']);
    final lat = ub['latitud'] as double?;
    final lng = ub['longitud'] as double?;
    final coordStr =
        lat != null && lng != null ? '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}' : 'Sin coordenadas';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(ub['nombre'],
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ub['descripcion'] != null && ub['descripcion'] != '')
              Text(ub['descripcion']),
            Text(coordStr,
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'editar',
              child:
                  Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Editar')]),
            ),
            const PopupMenuItem(
              value: 'eliminar',
              child: Row(children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Eliminar', style: TextStyle(color: Colors.red))
              ]),
            ),
          ],
          onSelected: (value) {
            if (value == 'editar') _showUbicacionForm(context, ubicacion: ub);
            if (value == 'eliminar') _confirmDelete(ub);
          },
        ),
      ),
    );
  }

  void _showUbicacionForm(BuildContext context,
      {Map<String, dynamic>? ubicacion}) {
    final isEditing = ubicacion != null;
    final nombreCtrl =
        TextEditingController(text: ubicacion?['nombre'] ?? '');
    final descCtrl =
        TextEditingController(text: ubicacion?['descripcion'] ?? '');
    final latCtrl = TextEditingController(
        text: ubicacion?['latitud']?.toString() ?? '');
    final lngCtrl = TextEditingController(
        text: ubicacion?['longitud']?.toString() ?? '');
    String selectedCategoria = ubicacion?['categoria'] ?? 'Reunión';

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
                        isEditing ? 'Editar Ubicación' : 'Nueva Ubicación',
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
                    controller: nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.place),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      prefixIcon: Icon(Icons.description),
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
                    items: _categorias
                        .where((c) => c != 'Todas')
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setModalState(() => selectedCategoria = v!),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Latitud',
                            prefixIcon: Icon(Icons.north),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: lngCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Longitud',
                            prefixIcon: Icon(Icons.east),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (nombreCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('El nombre es obligatorio')),
                          );
                          return;
                        }
                        final data = {
                          'id': ubicacion?['id'] ??
                              DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                          'nombre': nombreCtrl.text,
                          'descripcion': descCtrl.text.isEmpty
                              ? null
                              : descCtrl.text,
                          'categoria': selectedCategoria,
                          'latitud': double.tryParse(latCtrl.text),
                          'longitud': double.tryParse(lngCtrl.text),
                          'fecha': DateTime.now().toIso8601String(),
                        };
                        if (isEditing) {
                          await _db.updateUbicacion(data);
                        } else {
                          await _db.insertUbicacion(data);
                        }
                        await _cargarUbicaciones();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEditing
                                  ? 'Ubicación actualizada'
                                  : 'Ubicación guardada'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: Icon(isEditing ? Icons.save : Icons.add_location),
                      label: Text(isEditing ? 'Guardar cambios' : 'Agregar'),
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

  void _confirmDelete(Map<String, dynamic> ub) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ubicación'),
        content: Text('¿Eliminar "${ub['nombre']}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              await _db.deleteUbicacion(ub['id']);
              await _cargarUbicaciones();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Ubicación eliminada'),
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
