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
  List<Map<String, dynamic>> _allLogs = [];
  List<Map<String, dynamic>> _filteredLogs = [];
  bool _isLoading = true;

  // Filtros
  String? _filtroAccion;
  String? _filtroTabla;
  final List<String> _acciones = ['crear', 'editar', 'eliminar', 'registrar'];
  List<String> _tablas = [];

  @override
  void initState() {
    super.initState();
    _cargarLogs();
  }

  Future<void> _cargarLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _db.getAuditLog(limit: 500);
      final tablasSet = <String>{};
      for (final log in logs) {
        final tabla = log['tabla'] as String? ?? '';
        if (tabla.isNotEmpty) tablasSet.add(tabla);
      }
      setState(() {
        _allLogs = logs;
        _tablas = tablasSet.toList()..sort();
        _aplicarFiltros();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _aplicarFiltros() {
    _filteredLogs = _allLogs.where((log) {
      if (_filtroAccion != null && log['accion'] != _filtroAccion) return false;
      if (_filtroTabla != null && log['tabla'] != _filtroTabla) return false;
      return true;
    }).toList();
  }

  void _limpiarFiltros() {
    setState(() {
      _filtroAccion = null;
      _filtroTabla = null;
      _aplicarFiltros();
    });
  }

  bool get _hayFiltrosActivos => _filtroAccion != null || _filtroTabla != null;

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
      if (diff.inDays < 7) return 'Hace ${diff.inDays} dias';
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
          if (_hayFiltrosActivos)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Limpiar filtros',
              onPressed: _limpiarFiltros,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarLogs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtros
                _buildFiltros(),
                // Contador
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      Text(
                        '${_filteredLogs.length} registros',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      if (_hayFiltrosActivos) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Filtrado',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Lista
                Expanded(
                  child: _filteredLogs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                _hayFiltrosActivos
                                    ? 'Sin resultados para estos filtros'
                                    : 'Sin actividad registrada',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                              if (_hayFiltrosActivos) ...[
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: _limpiarFiltros,
                                  icon: const Icon(Icons.filter_alt_off),
                                  label: const Text('Limpiar filtros'),
                                ),
                              ],
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _cargarLogs,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _filteredLogs.length,
                            itemBuilder: (context, index) {
                              final log = _filteredLogs[index];
                              final accion = log['accion'] as String? ?? '';
                              final descripcion = log['descripcion'] as String? ?? '';
                              final tabla = log['tabla'] as String? ?? '';
                              final fecha = log['fecha'] as String? ?? '';
                              final usuario = log['usuario_nombre'] as String? ?? '';
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
                                      if (usuario.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Icon(Icons.person, size: 12, color: Colors.grey[400]),
                                        const SizedBox(width: 2),
                                        Flexible(
                                          child: Text(
                                            usuario,
                                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
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
                ),
              ],
            ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          // Filtro por accion
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filtroAccion,
              decoration: const InputDecoration(
                labelText: 'Accion',
                prefixIcon: Icon(Icons.filter_list, size: 20),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas')),
                ..._acciones.map((a) => DropdownMenuItem(
                      value: a,
                      child: Row(
                        children: [
                          Icon(_getAccionIcon(a), size: 16, color: _getAccionColor(a)),
                          const SizedBox(width: 8),
                          Text(a[0].toUpperCase() + a.substring(1)),
                        ],
                      ),
                    )),
              ],
              onChanged: (v) {
                setState(() {
                  _filtroAccion = v;
                  _aplicarFiltros();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          // Filtro por tabla
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filtroTabla,
              decoration: const InputDecoration(
                labelText: 'Tabla',
                prefixIcon: Icon(Icons.table_chart, size: 20),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas')),
                ..._tablas.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t),
                    )),
              ],
              onChanged: (v) {
                setState(() {
                  _filtroTabla = v;
                  _aplicarFiltros();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
