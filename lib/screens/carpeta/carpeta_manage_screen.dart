import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class CarpetaManageScreen extends StatefulWidget {
  const CarpetaManageScreen({super.key});

  @override
  State<CarpetaManageScreen> createState() => _CarpetaManageScreenState();
}

class _CarpetaManageScreenState extends State<CarpetaManageScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _secciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    try {
      final secciones = await _db.getCarpetaSecciones();
      final seccionesConConteo = <Map<String, dynamic>>[];
      for (final s in secciones) {
        final reqs = await _db.getCarpetaRequisitos(s['id']);
        seccionesConConteo.add({
          ...s,
          '_reqCount': reqs.length,
        });
      }
      setState(() {
        _secciones = seccionesConConteo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarFormularioSeccion({Map<String, dynamic>? seccion}) {
    final nombreCtrl = TextEditingController(text: seccion?['nombre'] ?? '');
    final descCtrl = TextEditingController(text: seccion?['descripcion'] ?? '');
    final numeroCtrl = TextEditingController(
        text: seccion?['numero']?.toString() ?? '${_secciones.length + 1}');
    final isEdit = seccion != null;

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
              isEdit ? 'Editar Seccion' : 'Nueva Seccion',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: numeroCtrl,
              decoration: const InputDecoration(
                labelText: 'Numero',
                prefixIcon: Icon(Icons.tag),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la seccion',
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
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
                final numero = int.tryParse(numeroCtrl.text.trim());
                if (nombre.isEmpty || numero == null) return;

                if (isEdit) {
                  await _db.updateSeccion({
                    'id': seccion['id'],
                    'numero': numero,
                    'nombre': nombre,
                    'descripcion': descCtrl.text.trim(),
                  });
                } else {
                  final id = 's_${DateTime.now().millisecondsSinceEpoch}';
                  await _db.insertSeccion({
                    'id': id,
                    'numero': numero,
                    'nombre': nombre,
                    'descripcion': descCtrl.text.trim(),
                  });
                }

                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _cargar();
              },
              child: Text(isEdit ? 'Guardar Cambios' : 'Crear Seccion'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eliminarSeccion(Map<String, dynamic> seccion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Seccion'),
        content: Text(
          'Esto eliminara la seccion "${seccion['nombre']}" '
          'y todos sus requisitos y progreso asociado. Esta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await _db.deleteSeccion(seccion['id']);
    _cargar();
  }

  void _verRequisitos(Map<String, dynamic> seccion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _RequisitosManageScreen(
          seccionId: seccion['id'],
          seccionNombre: seccion['nombre'],
          onChanged: _cargar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Carpeta')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _secciones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text('No hay secciones creadas',
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _mostrarFormularioSeccion(),
                        icon: const Icon(Icons.add),
                        label: const Text('Crear Seccion'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _secciones.length,
                    itemBuilder: (ctx, i) {
                      final s = _secciones[i];
                      return Dismissible(
                        key: Key(s['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          await _eliminarSeccion(s);
                          return false;
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1),
                              child: Text(
                                '${s['numero']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            title: Text(s['nombre'],
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              '${s['_reqCount']} requisitos${s['descripcion'] != null && (s['descripcion'] as String).isNotEmpty ? ' - ${s['descripcion']}' : ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => _verRequisitos(s),
                            onLongPress: () => _mostrarFormularioSeccion(seccion: s),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioSeccion(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── Gestion de requisitos de una seccion ──
class _RequisitosManageScreen extends StatefulWidget {
  final String seccionId;
  final String seccionNombre;
  final VoidCallback onChanged;

  const _RequisitosManageScreen({
    required this.seccionId,
    required this.seccionNombre,
    required this.onChanged,
  });

  @override
  State<_RequisitosManageScreen> createState() =>
      _RequisitosManageScreenState();
}

class _RequisitosManageScreenState extends State<_RequisitosManageScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _requisitos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    final reqs = await _db.getCarpetaRequisitos(widget.seccionId);
    setState(() {
      _requisitos = reqs;
      _isLoading = false;
    });
  }

  void _mostrarFormularioRequisito({Map<String, dynamic>? requisito}) {
    final nombreCtrl = TextEditingController(text: requisito?['nombre'] ?? '');
    final descCtrl =
        TextEditingController(text: requisito?['descripcion'] ?? '');
    final ordenCtrl = TextEditingController(
        text: requisito?['orden']?.toString() ?? '${_requisitos.length + 1}');
    final isEdit = requisito != null;

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
              isEdit ? 'Editar Requisito' : 'Nuevo Requisito',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ordenCtrl,
              decoration: const InputDecoration(
                labelText: 'Orden',
                prefixIcon: Icon(Icons.sort),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del requisito',
                prefixIcon: Icon(Icons.task),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripcion (opcional)',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final nombre = nombreCtrl.text.trim();
                final orden = int.tryParse(ordenCtrl.text.trim());
                if (nombre.isEmpty || orden == null) return;

                if (isEdit) {
                  await _db.updateRequisito({
                    'id': requisito['id'],
                    'seccion_id': widget.seccionId,
                    'nombre': nombre,
                    'descripcion': descCtrl.text.trim(),
                    'orden': orden,
                  });
                } else {
                  final id = 'r_${DateTime.now().millisecondsSinceEpoch}';
                  await _db.insertRequisito({
                    'id': id,
                    'seccion_id': widget.seccionId,
                    'nombre': nombre,
                    'descripcion': descCtrl.text.trim(),
                    'orden': orden,
                  });
                }

                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _cargar();
                widget.onChanged();
              },
              child: Text(isEdit ? 'Guardar Cambios' : 'Crear Requisito'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eliminarRequisito(Map<String, dynamic> req) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Requisito'),
        content: Text(
          'Esto eliminara "${req['nombre']}" y todo el progreso asociado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await _db.deleteRequisito(req['id']);
    _cargar();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.seccionNombre)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requisitos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text('No hay requisitos',
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _mostrarFormularioRequisito(),
                        icon: const Icon(Icons.add),
                        label: const Text('Crear Requisito'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requisitos.length,
                    itemBuilder: (ctx, i) {
                      final r = _requisitos[i];
                      return Dismissible(
                        key: Key(r['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          await _eliminarRequisito(r);
                          return false;
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1),
                              child: Text(
                                '${r['orden']}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            title: Text(r['nombre'],
                                style: const TextStyle(fontSize: 14)),
                            subtitle: r['descripcion'] != null &&
                                    (r['descripcion'] as String).isNotEmpty
                                ? Text(r['descripcion'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12))
                                : null,
                            onLongPress: () =>
                                _mostrarFormularioRequisito(requisito: r),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioRequisito(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
