import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';

class ConsejeroUnidadScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const ConsejeroUnidadScreen({super.key, this.onOpenDrawer});

  @override
  State<ConsejeroUnidadScreen> createState() => _ConsejeroUnidadScreenState();
}

class _ConsejeroUnidadScreenState extends State<ConsejeroUnidadScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  Map<String, dynamic>? _unidad;
  List<Map<String, dynamic>> _aspirantes = [];
  bool _isLoading = true;
  bool _sinUnidad = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    try {
      final userId = _auth.currentUser!.id;
      final unidad = await _db.getUnidadDeConsejero(userId);

      if (unidad == null) {
        setState(() {
          _sinUnidad = true;
          _isLoading = false;
        });
        return;
      }

      final miembros = await _db.getMiembrosDeUnidad(unidad['id']);
      final aspirantes = miembros
          .where((m) => m['rol_en_unidad'] == 'aspirante')
          .toList();

      setState(() {
        _unidad = unidad;
        _aspirantes = aspirantes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.onOpenDrawer != null
            ? IconButton(icon: const Icon(Icons.menu), onPressed: widget.onOpenDrawer)
            : null,
        title: Text(_unidad != null ? _unidad!['nombre'] : 'Mi Unidad'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sinUnidad
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No estas asignado a ninguna unidad',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Contacta al Director para ser asignado',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: _aspirantes.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 100),
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.people_outline,
                                      size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No hay aspirantes en tu unidad',
                                    style:
                                        TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _aspirantes.length,
                          itemBuilder: (ctx, i) {
                            final a = _aspirantes[i];
                            final nombre = a['nombre'] as String;
                            final apellido = a['apellido'] as String;
                            final iniciales =
                                '${nombre[0]}${apellido[0]}'.toUpperCase();

                            return Card(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  // TODO: Navegar a carpeta del aspirante
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.1),
                                        child: Text(
                                          iniciales,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        apellido,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Aspirante',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
