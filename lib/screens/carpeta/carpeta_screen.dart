import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class CarpetaScreen extends StatefulWidget {
  final String? miembroId;
  final String? miembroNombre;
  final VoidCallback? onOpenDrawer;

  const CarpetaScreen({super.key, this.miembroId, this.miembroNombre, this.onOpenDrawer});

  @override
  State<CarpetaScreen> createState() => _CarpetaScreenState();
}

class _CarpetaScreenState extends State<CarpetaScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  final ImagePicker _picker = ImagePicker();
  final NotificationService _notif = NotificationService();

  List<Map<String, dynamic>> _secciones = [];
  Map<String, List<Map<String, dynamic>>> _requisitosMap = {};
  Map<String, Map<String, dynamic>> _progresoMap = {};
  bool _isLoading = true;

  String get _targetId => widget.miembroId ?? _auth.currentUser!.id;
  bool get _isOwnCarpeta => widget.miembroId == null || widget.miembroId == _auth.currentUser?.id;
  bool get _canSubmit => _isOwnCarpeta && (_auth.isAspirante);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    try {
      final secciones = await _db.getCarpetaSecciones();
      final requisitos = await _db.getTodosLosRequisitos();
      final progreso = await _db.getCarpetaProgresoMiembro(_targetId);

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
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get _porcentajeTotal {
    int total = 0;
    int aprobados = 0;
    for (final reqs in _requisitosMap.values) {
      total += reqs.length;
      for (final r in reqs) {
        final prog = _progresoMap[r['id']];
        if (prog != null && prog['estado'] == 'aprobado') aprobados++;
      }
    }
    return total > 0 ? aprobados / total : 0;
  }

  Color _getEstadoColor(Map<String, dynamic>? prog) {
    if (prog == null) return Colors.grey[300]!;
    final estado = prog['estado'] as String? ?? 'pendiente';
    switch (estado) {
      case 'aprobado': return AppTheme.successGreen;
      case 'preaprobado': return AppTheme.infoBlue;
      case 'enviado': return AppTheme.accentGold;
      case 'devuelto': return AppTheme.warningOrange;
      default: return Colors.grey[300]!;
    }
  }

  String _getEstadoTexto(Map<String, dynamic>? prog) {
    if (prog == null) return 'Pendiente';
    final estado = prog['estado'] as String? ?? 'pendiente';
    switch (estado) {
      case 'aprobado': return 'Aprobado';
      case 'preaprobado': return 'Pre-aprobado';
      case 'enviado': return 'Enviado';
      case 'devuelto': return 'Devuelto';
      default: return 'Pendiente';
    }
  }

  IconData _getEstadoIcon(Map<String, dynamic>? prog) {
    if (prog == null) return Icons.radio_button_unchecked;
    final estado = prog['estado'] as String? ?? 'pendiente';
    switch (estado) {
      case 'aprobado': return Icons.check_circle;
      case 'preaprobado': return Icons.verified;
      case 'enviado': return Icons.hourglass_top;
      case 'devuelto': return Icons.replay;
      default: return Icons.radio_button_unchecked;
    }
  }

  Widget? _buildSubtitle(Map<String, dynamic>? prog) {
    if (prog == null) return null;
    final estado = prog['estado'] as String? ?? 'pendiente';

    if (estado == 'devuelto' && prog['comentario_devolucion'] != null) {
      return Text(
        'Devuelto: ${prog['comentario_devolucion']}',
        style: const TextStyle(fontSize: 12, color: AppTheme.warningOrange),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    if (prog['notas'] != null && (prog['notas'] as String).isNotEmpty) {
      return Text(
        prog['notas'],
        style: const TextStyle(fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return null;
  }

  void _onRequisitoTap(Map<String, dynamic> req, Map<String, dynamic>? prog) {
    final estado = prog?['estado'] as String? ?? 'pendiente';
    if (_canSubmit && (estado == 'pendiente' || estado == 'devuelto')) {
      _showSubmitEvidenceDialog(req, prog);
    } else if (prog != null && estado != 'pendiente') {
      _showEvidenceDetailDialog(req, prog);
    }
  }

  Future<String?> _pickImage(BuildContext ctx, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image?.path;
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Error al obtener imagen: $e')),
        );
      }
      return null;
    }
  }

  Future<String> _copyToAppDir(String tempPath, String requisitoId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final carpetaDir = Directory('${appDir.path}/carpeta_evidencias');
    if (!await carpetaDir.exists()) {
      await carpetaDir.create(recursive: true);
    }
    final ext = p.extension(tempPath);
    final fileName = '${_targetId}_${requisitoId}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final newFile = await File(tempPath).copy('${carpetaDir.path}/$fileName');
    return newFile.path;
  }

  void _showSubmitEvidenceDialog(Map<String, dynamic> req, Map<String, dynamic>? prog) {
    final notasCtrl = TextEditingController(text: prog?['notas'] as String? ?? '');
    String? selectedImagePath = prog?['evidencia_path'] as String?;
    final estado = prog?['estado'] as String? ?? 'pendiente';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          estado == 'devuelto' ? 'Re-enviar evidencia' : 'Enviar evidencia',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(req['nombre'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  if (req['descripcion'] != null) ...[
                    const SizedBox(height: 4),
                    Text(req['descripcion'], style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],

                  if (estado == 'devuelto' && prog?['comentario_devolucion'] != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.warningOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.warningOrange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.feedback, color: AppTheme.warningOrange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              prog!['comentario_devolucion'],
                              style: const TextStyle(fontSize: 13, color: AppTheme.warningOrange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  if (selectedImagePath != null && File(selectedImagePath!).existsSync()) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(selectedImagePath!), height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final source = await _showImageSourceDialog(ctx);
                        if (source == null) return;
                        final path = await _pickImage(ctx, source);
                        if (path != null) setModalState(() => selectedImagePath = path);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Cambiar foto'),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final path = await _pickImage(ctx, ImageSource.camera);
                              if (path != null) setModalState(() => selectedImagePath = path);
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camara'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final path = await _pickImage(ctx, ImageSource.gallery);
                              if (path != null) setModalState(() => selectedImagePath = path);
                            },
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galeria'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),
                  TextField(
                    controller: notasCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Descripcion / Notas',
                      hintText: 'Describe tu evidencia...',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (selectedImagePath == null && notasCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Agrega una foto o descripcion')),
                          );
                          return;
                        }

                        String? finalPath;
                        if (selectedImagePath != null) {
                          finalPath = await _copyToAppDir(selectedImagePath!, req['id'] as String);
                        }

                        await _db.enviarEvidencia(
                          miembroId: _targetId,
                          requisitoId: req['id'] as String,
                          evidenciaPath: finalPath,
                          notas: notasCtrl.text.trim().isEmpty ? null : notasCtrl.text.trim(),
                        );

                        final consejeroId = await _db.getConsejeroDeAspirante(_targetId);
                        if (consejeroId != null) {
                          final userName = _auth.currentUser?.nombre ?? 'Aspirante';
                          await _notif.mostrarNotificacion(
                            id: 'carpeta_envio_${DateTime.now().millisecondsSinceEpoch}',
                            titulo: 'Nueva evidencia enviada',
                            mensaje: '$userName envio evidencia para: ${req['nombre']}',
                            tipo: 'info',
                          );
                        }

                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        _cargar();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Evidencia enviada'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Enviar evidencia'),
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

  Future<ImageSource?> _showImageSourceDialog(BuildContext ctx) async {
    return showDialog<ImageSource>(
      context: ctx,
      builder: (c) => SimpleDialog(
        title: const Text('Seleccionar fuente'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(c, ImageSource.camera),
            child: const ListTile(leading: Icon(Icons.camera_alt), title: Text('Camara')),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(c, ImageSource.gallery),
            child: const ListTile(leading: Icon(Icons.photo_library), title: Text('Galeria')),
          ),
        ],
      ),
    );
  }

  void _showEvidenceDetailDialog(Map<String, dynamic> req, Map<String, dynamic> prog) {
    final estado = prog['estado'] as String? ?? 'pendiente';
    final evidenciaPath = prog['evidencia_path'] as String?;
    final notas = prog['notas'] as String?;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(req['nombre'], style: const TextStyle(fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getEstadoColor(prog).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getEstadoTexto(prog),
                  style: TextStyle(color: _getEstadoColor(prog), fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              if (evidenciaPath != null && File(evidenciaPath).existsSync()) ...[
                GestureDetector(
                  onTap: () => _showFullImage(evidenciaPath),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: Image.file(
                        File(evidenciaPath),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey, size: 60),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (notas != null && notas.isNotEmpty) ...[
                const Text('Notas:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(notas, style: const TextStyle(fontSize: 13)),
              ],
              if (estado == 'devuelto' && prog['comentario_devolucion'] != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Comentario: ${prog['comentario_devolucion']}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.warningOrange),
                  ),
                ),
              ],
              if (prog['fecha_envio'] != null) ...[
                const SizedBox(height: 8),
                Text('Enviado: ${_formatFecha(prog['fecha_envio'])}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _showFullImage(String path) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
        body: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: SizedBox.expand(
            child: Image.file(
              File(path),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, color: Colors.grey, size: 80),
              ),
            ),
          ),
        ),
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
    final titulo = widget.miembroNombre != null
        ? 'Carpeta: ${widget.miembroNombre}'
        : 'Mi Carpeta de Investidura';

    return Scaffold(
      appBar: AppBar(
        leading: widget.onOpenDrawer != null
            ? IconButton(icon: const Icon(Icons.menu), onPressed: widget.onOpenDrawer)
            : null,
        title: Text(titulo),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Progreso general
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(
                                    value: _porcentajeTotal,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.grey[200],
                                    color: _porcentajeTotal >= 1.0
                                        ? AppTheme.successGreen
                                        : AppTheme.primaryGreen,
                                  ),
                                ),
                                Text(
                                  '${(_porcentajeTotal * 100).toInt()}%',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Progreso General',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildLegend(Colors.grey[300]!, 'Pendiente'),
                                _buildLegend(AppTheme.accentGold, 'Enviado'),
                                _buildLegend(AppTheme.warningOrange, 'Devuelto'),
                                _buildLegend(AppTheme.infoBlue, 'Pre-aprobado'),
                                _buildLegend(AppTheme.successGreen, 'Aprobado'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Secciones con requisitos
                    ..._secciones.map((seccion) {
                      final reqs = _requisitosMap[seccion['id']] ?? [];
                      final aprobados = reqs.where((r) {
                        final p = _progresoMap[r['id']];
                        return p != null && p['estado'] == 'aprobado';
                      }).length;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        clipBehavior: Clip.antiAlias,
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            child: Text(
                              '${seccion['numero']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                          title: Text(
                            seccion['nombre'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('$aprobados/${reqs.length} aprobados'),
                          children: reqs.map((req) {
                            final prog = _progresoMap[req['id']];
                            final estado = prog?['estado'] as String? ?? 'pendiente';
                            final tappable = _canSubmit && (estado == 'pendiente' || estado == 'devuelto')
                                || (prog != null && estado != 'pendiente');

                            return ListTile(
                              leading: Icon(
                                _getEstadoIcon(prog),
                                color: _getEstadoColor(prog),
                              ),
                              title: Text(
                                req['nombre'],
                                style: TextStyle(
                                  fontSize: 14,
                                  decoration: estado == 'aprobado' ? TextDecoration.lineThrough : null,
                                  color: estado == 'aprobado' ? Colors.grey : null,
                                ),
                              ),
                              subtitle: _buildSubtitle(prog),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getEstadoColor(prog).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getEstadoTexto(prog),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _getEstadoColor(prog),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              onTap: tappable ? () => _onRequisitoTap(req, prog) : null,
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
