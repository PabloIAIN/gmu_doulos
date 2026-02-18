import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/database_service.dart';

class EvidenciasScreen extends StatefulWidget {
  const EvidenciasScreen({super.key});

  @override
  State<EvidenciasScreen> createState() => _EvidenciasScreenState();
}

class _EvidenciasScreenState extends State<EvidenciasScreen> {
  final DatabaseService _db = DatabaseService();
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _evidencias = [];
  String _categoriaSeleccionada = 'Todas';
  bool _isLoading = true;

  final List<String> _categorias = [
    'Todas',
    'Campamento',
    'Reunión',
    'Especialidad',
    'Actividad',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _cargarEvidencias();
  }

  Future<void> _cargarEvidencias() async {
    setState(() => _isLoading = true);
    try {
      final evidencias = await _db.getEvidencias();
      setState(() {
        _evidencias = evidencias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar evidencias: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _evidenciasFiltradas {
    if (_categoriaSeleccionada == 'Todas') return _evidencias;
    return _evidencias
        .where((e) => e['categoria'] == _categoriaSeleccionada)
        .toList();
  }

  Future<void> _tomarFoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        _showGuardarEvidenciaDialog(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener imagen: $e')),
        );
      }
    }
  }

  void _showGuardarEvidenciaDialog(String fotoPath) {
    final tituloController = TextEditingController();
    final descripcionController = TextEditingController();
    String selectedCategoria = 'Actividad';

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
                      const Text(
                        'Nueva Evidencia',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Preview de la foto
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(fotoPath),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título (opcional)',
                      prefixIcon: Icon(Icons.title),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      prefixIcon: Icon(Icons.description),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
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
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setModalState(() => selectedCategoria = v!),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final data = {
                          'id': DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          'titulo': tituloController.text.isEmpty
                              ? null
                              : tituloController.text,
                          'descripcion': descripcionController.text.isEmpty
                              ? null
                              : descripcionController.text,
                          'categoria': selectedCategoria,
                          'foto_path': fotoPath,
                          'fecha': DateTime.now().toIso8601String(),
                        };
                        await _db.insertEvidencia(data);
                        await _cargarEvidencias();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Evidencia guardada'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar evidencia'),
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

  Color _getCategoriaColor(String categoria) {
    switch (categoria) {
      case 'Campamento':
        return Colors.green;
      case 'Reunión':
        return Colors.blue;
      case 'Especialidad':
        return Colors.orange;
      case 'Actividad':
        return Colors.teal;
      case 'Otro':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoriaIcon(String categoria) {
    switch (categoria) {
      case 'Campamento':
        return Icons.terrain;
      case 'Reunión':
        return Icons.groups;
      case 'Especialidad':
        return Icons.emoji_events;
      case 'Actividad':
        return Icons.directions_walk;
      case 'Otro':
        return Icons.photo;
      default:
        return Icons.photo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _evidenciasFiltradas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarEvidencias,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtros por categoría
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
                            setState(
                                () => _categoriaSeleccionada = cat);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filtradas.length} fotos',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        '${_evidencias.length} total',
                        style: TextStyle(color: Colors.green[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Galería
                Expanded(
                  child: filtradas.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _cargarEvidencias,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                            ),
                            itemCount: filtradas.length,
                            itemBuilder: (context, index) {
                              return _buildFotoThumbnail(filtradas[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCameraOptions(context),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Agregar'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No hay evidencias',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Toma una foto o selecciona de la galería',
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildFotoThumbnail(Map<String, dynamic> evidencia) {
    final file = File(evidencia['foto_path'] as String);
    final categoria = evidencia['categoria'] as String;

    return GestureDetector(
      onTap: () => _showFotoDetail(evidencia),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen real o placeholder si el archivo no existe
            file.existsSync()
                ? Image.file(file, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image,
                        color: Colors.grey[500], size: 40),
                  ),
            // Badge de categoría
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoriaColor(categoria).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  categoria,
                  style: const TextStyle(color: Colors.white, fontSize: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFotoDetail(Map<String, dynamic> evidencia) {
    final file = File(evidencia['foto_path'] as String);
    final titulo = evidencia['titulo'] as String?;
    final descripcion = evidencia['descripcion'] as String?;
    final categoria = evidencia['categoria'] as String;
    final fecha = DateTime.tryParse(evidencia['fecha'] as String);
    final fechaStr = fecha != null
        ? '${fecha.day}/${fecha.month}/${fecha.year} - ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}'
        : '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Imagen
            SizedBox(
              height: 300,
              width: double.infinity,
              child: file.existsSync()
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showFullScreenImage(file);
                      },
                      child: Image.file(file, fit: BoxFit.cover),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 80),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getCategoriaIcon(categoria),
                          color: _getCategoriaColor(categoria), size: 20),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              _getCategoriaColor(categoria).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          categoria,
                          style: TextStyle(
                            color: _getCategoriaColor(categoria),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(fechaStr,
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                  if (titulo != null && titulo.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      titulo,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                  if (descripcion != null && descripcion.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(descripcion,
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _confirmDelete(evidencia);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Eliminar',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(file),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> evidencia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar evidencia'),
        content: const Text('¿Estás seguro de eliminar esta foto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              await _db.deleteEvidencia(evidencia['id']);
              await _cargarEvidencias();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Evidencia eliminada'),
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

  void _showCameraOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Agregar evidencia',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  context,
                  Icons.camera_alt,
                  'Cámara',
                  Colors.blue,
                  () {
                    Navigator.pop(context);
                    _tomarFoto(ImageSource.camera);
                  },
                ),
                _buildOptionButton(
                  context,
                  Icons.photo_library,
                  'Galería',
                  Colors.green,
                  () {
                    Navigator.pop(context);
                    _tomarFoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
