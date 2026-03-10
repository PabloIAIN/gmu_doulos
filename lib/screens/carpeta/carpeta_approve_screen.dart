import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class CarpetaApproveScreen extends StatefulWidget {
  const CarpetaApproveScreen({super.key});

  @override
  State<CarpetaApproveScreen> createState() => _CarpetaApproveScreenState();
}

class _CarpetaApproveScreenState extends State<CarpetaApproveScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  final NotificationService _notif = NotificationService();

  List<Map<String, dynamic>> _pendientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    try {
      final pendientes = await _db.getRequisitosPendientesAprobacion();
      setState(() {
        _pendientes = pendientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _aprobar(Map<String, dynamic> item) async {
    await _db.aprobarRequisito(
      miembroId: item['miembro_id'] as String,
      requisitoId: item['requisito_id'] as String,
      aprobadoPor: _auth.currentUser!.id,
    );

    await _notif.mostrarNotificacion(
      id: 'carpeta_aprobado_${DateTime.now().millisecondsSinceEpoch}',
      titulo: 'Requisito aprobado!',
      mensaje: '${item['requisito_nombre']} ha sido aprobado por el Director.',
      tipo: 'info',
    );

    _cargar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Requisito aprobado'),
        backgroundColor: AppTheme.successGreen,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aprobar Requisitos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendientes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No hay requisitos pendientes de aprobacion',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendientes.length,
                    itemBuilder: (ctx, i) {
                      final item = _pendientes[i];
                      final evidenciaPath = item['evidencia_path'] as String?;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppTheme.infoBlue.withValues(alpha: 0.2),
                                    child: const Icon(Icons.verified,
                                        color: AppTheme.infoBlue, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item['miembro_nombre']} ${item['miembro_apellido']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          item['requisito_nombre'] ?? '',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Evidencia foto
                              if (evidenciaPath != null && File(evidenciaPath).existsSync()) ...[
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () => _showFullImage(evidenciaPath),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(evidenciaPath),
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 150,
                                        color: Colors.grey[200],
                                        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 60)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              // Notas
                              if (item['notas'] != null &&
                                  (item['notas'] as String).isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Nota: ${item['notas']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    item['fecha_completado'] != null
                                        ? 'Pre-aprobado: ${_formatFecha(item['fecha_completado'] as String)}'
                                        : '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton.icon(
                                    onPressed: () => _aprobar(item),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('Aprobar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.successGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatFecha(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
