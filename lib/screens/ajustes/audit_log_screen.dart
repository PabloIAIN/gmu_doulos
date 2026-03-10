import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarLogs();
  }

  Future<void> _cargarLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _db.getAuditLog(limit: 200);
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  IconData _getAccionIcon(String accion) {
    switch (accion) {
      case 'crear':
        return Icons.add_circle_outline;
      case 'editar':
        return Icons.edit_outlined;
      case 'eliminar':
        return Icons.delete_outline;
      case 'registrar':
        return Icons.how_to_reg;
      default:
        return Icons.info_outline;
    }
  }

  Color _getAccionColor(String accion) {
    switch (accion) {
      case 'crear':
        return AppTheme.successGreen;
      case 'editar':
        return AppTheme.infoBlue;
      case 'eliminar':
        return AppTheme.errorRed;
      case 'registrar':
        return AppTheme.warningOrange;
      default:
        return Colors.grey;
    }
  }

  String _formatFecha(String isoDate) {
    try {
      final fecha = DateTime.parse(isoDate);
      final ahora = DateTime.now();
      final diff = ahora.difference(fecha);

      if (diff.inMinutes < 1) return 'Justo ahora';
      if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
      if (diff.inDays == 1) return 'Ayer';
      if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de actividad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarLogs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Sin actividad registrada',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarLogs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      final accion = log['accion'] as String? ?? '';
                      final descripcion = log['descripcion'] as String? ?? '';
                      final tabla = log['tabla'] as String? ?? '';
                      final fecha = log['fecha'] as String? ?? '';
                      final color = _getAccionColor(accion);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.1),
                            child: Icon(_getAccionIcon(accion), color: color, size: 20),
                          ),
                          title: Text(
                            descripcion,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  accion.toUpperCase(),
                                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(tabla, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                            ],
                          ),
                          trailing: Text(
                            _formatFecha(fecha),
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
