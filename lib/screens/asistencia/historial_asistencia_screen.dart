import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/user_avatar.dart';

class HistorialAsistenciaScreen extends StatefulWidget {
  final String miembroId;
  final String nombreCompleto;
  final String? fotoUrl;
  final String iniciales;

  const HistorialAsistenciaScreen({
    super.key,
    required this.miembroId,
    required this.nombreCompleto,
    this.fotoUrl,
    required this.iniciales,
  });

  @override
  State<HistorialAsistenciaScreen> createState() =>
      _HistorialAsistenciaScreenState();
}

class _HistorialAsistenciaScreenState extends State<HistorialAsistenciaScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _historial = [];
  bool _isLoading = true;
  double _porcentaje = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    try {
      final historial =
          await _db.getHistorialAsistenciaMiembro(widget.miembroId);
      final porcentaje =
          await _db.getPorcentajeAsistenciaMiembro(widget.miembroId);
      setState(() {
        _historial = historial;
        _porcentaje = porcentaje;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  int get _presentes =>
      _historial.where((r) => r['puntualidad'] == 'presente').length;
  int get _tardanzas =>
      _historial.where((r) => r['puntualidad'] == 'tardanza').length;
  int get _ausentes =>
      _historial.where((r) => r['puntualidad'] == 'ausente').length;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Asistencia')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historial.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildEstadisticas(),
                      const SizedBox(height: 20),
                      Text(
                        'Registros (${_historial.length})',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._historial.map(_buildRegistroCard),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fact_check_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Sin registros de asistencia',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            UserAvatar(
              fotoUrl: widget.fotoUrl,
              iniciales: widget.iniciales,
              radius: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.percent, size: 16, color: AppTheme.primaryGreen),
                      const SizedBox(width: 4),
                      Text(
                        '${_porcentaje.toStringAsFixed(1)}% asistencia',
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildEstadisticas() {
    return Row(
      children: [
        _buildStatCard('Presente', _presentes, AppTheme.successGreen),
        const SizedBox(width: 8),
        _buildStatCard('Tardanza', _tardanzas, Colors.amber),
        const SizedBox(width: 8),
        _buildStatCard('Ausente', _ausentes, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistroCard(Map<String, dynamic> r) {
    final puntualidad = r['puntualidad'] as String;
    final fecha = r['fecha'] as String;
    final diaSemana = r['dia_semana'] as String;
    final unidad = r['unidad_nombre'] as String? ?? '';
    final panoleta = r['panoleta'] == 1;
    final biblia = r['biblia'] == 1;
    final cuota = r['cuota'] == 1;

    Color statusColor;
    IconData statusIcon;
    String statusLabel;
    if (puntualidad == 'presente') {
      statusColor = AppTheme.successGreen;
      statusIcon = Icons.check_circle;
      statusLabel = 'Presente';
    } else if (puntualidad == 'tardanza') {
      statusColor = Colors.amber;
      statusIcon = Icons.schedule;
      statusLabel = 'Tardanza';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusLabel = 'Ausente';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Fecha
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    fecha.substring(8, 10),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    _getMesCorto(fecha),
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Detalles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${diaSemana[0].toUpperCase()}${diaSemana.substring(1)} - $unidad',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Badges
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (panoleta)
                  _buildBadge(Icons.dry_cleaning, Colors.indigo),
                if (biblia)
                  _buildBadge(Icons.menu_book, Colors.brown),
                if (cuota)
                  _buildBadge(Icons.payments, AppTheme.successGreen),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Icon(icon, size: 16, color: color),
    );
  }

  String _getMesCorto(String fecha) {
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final mes = int.tryParse(fecha.substring(5, 7)) ?? 1;
    return meses[mes - 1];
  }
}
