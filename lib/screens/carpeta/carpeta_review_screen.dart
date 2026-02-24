import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class CarpetaReviewScreen extends StatefulWidget {
  const CarpetaReviewScreen({super.key});

  @override
  State<CarpetaReviewScreen> createState() => _CarpetaReviewScreenState();
}

class _CarpetaReviewScreenState extends State<CarpetaReviewScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();

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

      final conResumen = <Map<String, dynamic>>[];
      for (final a in aspirantes) {
        final resumen = await _db.getCarpetaResumen(a['miembro_id']);
        conResumen.add({
          ...a,
          '_total': resumen['total'],
          '_completados': resumen['completados'],
          '_aprobados': resumen['aprobados'],
          '_enviados': resumen['enviados'],
        });
      }

      setState(() {
        _aspirantes = conResumen;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _verCarpeta(Map<String, dynamic> aspirante) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CarpetaReviewDetailScreen(
          miembroId: aspirante['miembro_id'] as String,
          miembroNombre: '${aspirante['nombre']} ${aspirante['apellido']}',
          onChanged: _cargar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revisar Carpetas')),
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
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: _aspirantes.isEmpty
                      ? ListView(children: [
                          const SizedBox(height: 100),
                          Center(
                            child: Text('No hay aspirantes en tu unidad',
                                style: TextStyle(color: Colors.grey[600])),
                          )
                        ])
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _aspirantes.length,
                          itemBuilder: (ctx, i) {
                            final a = _aspirantes[i];
                            final total = (a['_total'] as int?) ?? 0;
                            final aprobados = (a['_aprobados'] as int?) ?? 0;
                            final enviados = (a['_enviados'] as int?) ?? 0;
                            final porcentaje = total > 0 ? aprobados / total : 0.0;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: CircularProgressIndicator(
                                        value: porcentaje,
                                        strokeWidth: 4,
                                        backgroundColor: Colors.grey[200],
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                    Text(
                                      '${(porcentaje * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  '${a['nombre']} ${a['apellido']}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    enviados > 0
                                        ? '$enviados por revisar - $aprobados aprobados de $total'
                                        : '$aprobados aprobados de $total',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: enviados > 0 ? AppTheme.accentGold : null,
                                      fontWeight: enviados > 0 ? FontWeight.w600 : null,
                                    ),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (enviados > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '$enviados',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.accentGold,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_ios, size: 16),
                                  ],
                                ),
                                onTap: () => _verCarpeta(a),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}

// ── Detalle de revision para un aspirante ──
class _CarpetaReviewDetailScreen extends StatefulWidget {
  final String miembroId;
  final String miembroNombre;
  final VoidCallback onChanged;

  const _CarpetaReviewDetailScreen({
    required this.miembroId,
    required this.miembroNombre,
    required this.onChanged,
  });

  @override
  State<_CarpetaReviewDetailScreen> createState() =>
      _CarpetaReviewDetailScreenState();
}

class _CarpetaReviewDetailScreenState extends State<_CarpetaReviewDetailScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  final NotificationService _notif = NotificationService();

  List<Map<String, dynamic>> _secciones = [];
  Map<String, List<Map<String, dynamic>>> _requisitosMap = {};
  Map<String, Map<String, dynamic>> _progresoMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    final secciones = await _db.getCarpetaSecciones();
    final requisitos = await _db.getTodosLosRequisitos();
    final progreso = await _db.getCarpetaProgresoMiembro(widget.miembroId);

    final reqMap = <String, List<Map<String, dynamic>>>{};
    for (final r in requisitos) {
      final secId = r['seccion_id'] as String;
      reqMap.putIfAbsent(secId, () => []);
      reqMap[secId]!.add(r);
    }

    final progMap = <String, Map<String, dynamic>>{};
    for (final p in progreso) {
      if (p['estado'] != null) {
        progMap[p['id'] as String] = p;
      }
    }

    setState(() {
      _secciones = secciones;
      _requisitosMap = reqMap;
      _progresoMap = progMap;
      _isLoading = false;
    });
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'aprobado': return AppTheme.successGreen;
      case 'preaprobado': return AppTheme.infoBlue;
      case 'enviado': return AppTheme.accentGold;
      case 'devuelto': return AppTheme.warningOrange;
      default: return Colors.grey[300]!;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'aprobado': return Icons.check_circle;
      case 'preaprobado': return Icons.verified;
      case 'enviado': return Icons.mail;
      case 'devuelto': return Icons.replay;
      default: return Icons.radio_button_unchecked;
    }
  }

  Widget? _buildReviewSubtitle(Map<String, dynamic>? prog, String estado) {
    if (estado == 'enviado') {
      final hasPhoto = prog?['evidencia_path'] != null;
      final hasNotes = prog?['notas'] != null && (prog!['notas'] as String).isNotEmpty;
      return Text(
        'Evidencia: ${hasPhoto ? "Foto" : ""}${hasPhoto && hasNotes ? " + " : ""}${hasNotes ? "Texto" : ""}',
        style: const TextStyle(fontSize: 12, color: AppTheme.accentGold),
      );
    }
    if (estado == 'preaprobado') {
      return const Text('Esperando aprobacion del Director',
          style: TextStyle(fontSize: 11, color: AppTheme.infoBlue));
    }
    if (estado == 'aprobado') {
      return const Text('Aprobado por Director',
          style: TextStyle(fontSize: 11, color: AppTheme.successGreen));
    }
    if (estado == 'devuelto') {
      return Text('Devuelto: ${prog?['comentario_devolucion'] ?? ""}',
          style: const TextStyle(fontSize: 11, color: AppTheme.warningOrange),
          maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return const Text('Sin enviar', style: TextStyle(fontSize: 11, color: Colors.grey));
  }

  Future<void> _preAprobar(String requisitoId, String requisitoNombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pre-aprobar requisito'),
        content: const Text('Confirmas que la evidencia es valida? Se enviara al Director para aprobacion final.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
            child: const Text('Pre-aprobar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _db.preAprobarRequisito(
      miembroId: widget.miembroId,
      requisitoId: requisitoId,
      completadoPor: _auth.currentUser!.id,
    );

    await _notif.mostrarNotificacion(
      id: 'carpeta_preaprobado_${DateTime.now().millisecondsSinceEpoch}',
      titulo: 'Requisito pre-aprobado',
      mensaje: '${widget.miembroNombre}: $requisitoNombre - Esperando aprobacion final',
      tipo: 'info',
    );

    _cargar();
    widget.onChanged();
  }

  Future<void> _devolver(String requisitoId, String requisitoNombre) async {
    final comentarioCtrl = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Devolver requisito'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Escribe un comentario explicando que debe corregir:'),
            const SizedBox(height: 12),
            TextField(
              controller: comentarioCtrl,
              decoration: const InputDecoration(
                hintText: 'Ej: La foto no es clara...',
                prefixIcon: Icon(Icons.feedback),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (comentarioCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Escribe un comentario')),
                );
                return;
              }
              Navigator.pop(ctx, comentarioCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningOrange),
            child: const Text('Devolver'),
          ),
        ],
      ),
    );

    if (result == null) return;

    await _db.devolverRequisito(
      miembroId: widget.miembroId,
      requisitoId: requisitoId,
      comentario: result,
    );

    await _notif.mostrarNotificacion(
      id: 'carpeta_devuelto_${DateTime.now().millisecondsSinceEpoch}',
      titulo: 'Requisito devuelto',
      mensaje: '$requisitoNombre fue devuelto. Revisa los comentarios.',
      tipo: 'info',
    );

    _cargar();
    widget.onChanged();
  }

  void _showFullImage(String path) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(child: InteractiveViewer(child: Image.file(File(path)))),
      ),
    ));
  }

  String _formatFecha(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.miembroNombre)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: _secciones.map((seccion) {
                final reqs = _requisitosMap[seccion['id']] ?? [];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      child: Text(
                        '${seccion['numero']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                    title: Text(seccion['nombre'],
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    children: reqs.map((req) {
                      final prog = _progresoMap[req['id']];
                      final estado = prog?['estado'] as String? ?? 'pendiente';
                      final evidenciaPath = prog?['evidencia_path'] as String?;
                      final notas = prog?['notas'] as String?;
                      final hasEvidence = evidenciaPath != null || (notas != null && notas.isNotEmpty);

                      return Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              _getEstadoIcon(estado),
                              color: _getEstadoColor(estado),
                            ),
                            title: Text(
                              req['nombre'],
                              style: TextStyle(
                                fontSize: 14,
                                decoration: estado == 'aprobado' ? TextDecoration.lineThrough : null,
                                color: estado == 'aprobado' ? Colors.grey : null,
                              ),
                            ),
                            subtitle: _buildReviewSubtitle(prog, estado),
                          ),
                          // Mostrar evidencia inline para items con evidencia
                          if (hasEvidence && estado != 'pendiente')
                            Padding(
                              padding: const EdgeInsets.only(left: 56, right: 16, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (evidenciaPath != null && File(evidenciaPath).existsSync())
                                    GestureDetector(
                                      onTap: () => _showFullImage(evidenciaPath),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          File(evidenciaPath),
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  if (notas != null && notas.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Notas del aspirante:',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                                          const SizedBox(height: 4),
                                          Text(notas, style: const TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (prog?['fecha_envio'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text('Enviado: ${_formatFecha(prog!['fecha_envio'] as String)}',
                                        style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                  ],
                                  if (estado == 'devuelto' && prog?['comentario_devolucion'] != null) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warningOrange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.warningOrange.withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.feedback, color: AppTheme.warningOrange, size: 16),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              prog!['comentario_devolucion'] as String,
                                              style: const TextStyle(fontSize: 12, color: AppTheme.warningOrange),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          // Botones de accion solo para items "enviado"
                          if (estado == 'enviado')
                            Padding(
                              padding: const EdgeInsets.only(left: 56, right: 16, bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _devolver(req['id'] as String, req['nombre'] as String),
                                      icon: const Icon(Icons.replay, size: 16),
                                      label: const Text('Devolver'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.warningOrange,
                                        side: const BorderSide(color: AppTheme.warningOrange),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _preAprobar(req['id'] as String, req['nombre'] as String),
                                      icon: const Icon(Icons.check, size: 16),
                                      label: const Text('Pre-aprobar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.successGreen,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Divider(height: 1),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
