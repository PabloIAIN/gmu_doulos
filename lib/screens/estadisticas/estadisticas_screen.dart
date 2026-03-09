import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;

  List<Map<String, dynamic>> _asistenciaPorFecha = [];
  List<Map<String, dynamic>> _distribucionRoles = [];
  List<Map<String, dynamic>> _asistenciaPorUnidad = [];
  List<Map<String, dynamic>> _distribucionClases = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _db.getAsistenciaPorFechas(limit: 8),
        _db.getDistribucionRoles(),
        _db.getAsistenciaPorUnidad(),
        _db.getDistribucionClases(),
      ]);
      setState(() {
        _asistenciaPorFecha = futures[0].reversed.toList();
        _distribucionRoles = futures[1];
        _asistenciaPorUnidad = futures[2];
        _distribucionClases = futures[3];
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
        title: const Text('Estadisticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Grafica de linea: Asistencia semanal ──
                    _buildSectionTitle('Tendencia de Asistencia'),
                    const SizedBox(height: 8),
                    _buildAsistenciaLineChart(),
                    const SizedBox(height: 28),

                    // ── Grafica de pie: Distribucion de roles ──
                    _buildSectionTitle('Distribucion por Rol'),
                    const SizedBox(height: 8),
                    _buildRolesPieChart(),
                    const SizedBox(height: 28),

                    // ── Grafica de barras: Asistencia por unidad ──
                    _buildSectionTitle('Asistencia por Unidad'),
                    const SizedBox(height: 8),
                    _buildUnidadBarChart(),
                    const SizedBox(height: 28),

                    // ── Grafica de pie: Distribucion de clases ──
                    _buildSectionTitle('Distribucion por Clase'),
                    const SizedBox(height: 8),
                    _buildClasesPieChart(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ── GRAFICA DE LINEA: Tendencia de asistencia ──
  Widget _buildAsistenciaLineChart() {
    if (_asistenciaPorFecha.isEmpty) {
      return _buildEmptyChart('No hay datos de asistencia');
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 25,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}%',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= _asistenciaPorFecha.length) return const SizedBox();
                  final fecha = _asistenciaPorFecha[i]['fecha'] as String;
                  // Mostrar solo dia/mes
                  final parts = fecha.split('-');
                  return Text(
                    '${parts[2]}/${parts[1]}',
                    style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            // Linea de asistencia (presentes + tardanzas)
            LineChartBarData(
              spots: _asistenciaPorFecha.asMap().entries.map((e) {
                final d = e.value;
                final total = (d['total'] as int);
                final asistieron = (d['presentes'] as int) + (d['tardanzas'] as int);
                final pct = total > 0 ? (asistieron / total) * 100 : 0.0;
                return FlSpot(e.key.toDouble(), pct);
              }).toList(),
              isCurved: true,
              color: AppTheme.primaryGreen,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2.5,
                  strokeColor: AppTheme.primaryGreen,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryGreen.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── GRAFICA DE PIE: Roles ──
  Widget _buildRolesPieChart() {
    if (_distribucionRoles.isEmpty) {
      return _buildEmptyChart('No hay miembros registrados');
    }

    final colors = [
      const Color(0xFF2E7D32), // verde
      const Color(0xFF1565C0), // azul
      const Color(0xFFF57F17), // amarillo
      const Color(0xFFE65100), // naranja
      const Color(0xFF6A1B9A), // morado
      const Color(0xFF00838F), // teal
      const Color(0xFFC62828), // rojo
    ];

    final total = _distribucionRoles.fold<int>(0, (sum, r) => sum + (r['count'] as int));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Pie chart
          SizedBox(
            height: 160,
            width: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: _distribucionRoles.asMap().entries.map((e) {
                  final count = e.value['count'] as int;
                  final pct = total > 0 ? (count / total) * 100 : 0.0;
                  return PieChartSectionData(
                    value: count.toDouble(),
                    color: colors[e.key % colors.length],
                    radius: 50,
                    title: '${pct.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Leyenda
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _distribucionRoles.asMap().entries.map((e) {
                final rol = e.value['rol'] as String;
                final count = e.value['count'] as int;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[e.key % colors.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rol,
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ),
                      Text(
                        '$count',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── GRAFICA DE BARRAS: Asistencia por unidad ──
  Widget _buildUnidadBarChart() {
    if (_asistenciaPorUnidad.isEmpty) {
      return _buildEmptyChart('No hay datos de asistencia por unidad');
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 25,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}%',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= _asistenciaPorUnidad.length) return const SizedBox();
                  final nombre = _asistenciaPorUnidad[i]['unidad'] as String;
                  return Text(
                    nombre.length > 8 ? '${nombre.substring(0, 8)}.' : nombre,
                    style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _asistenciaPorUnidad.asMap().entries.map((e) {
            final d = e.value;
            final total = d['total'] as int;
            final asistieron = d['asistieron'] as int;
            final pct = total > 0 ? (asistieron / total) * 100 : 0.0;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: pct,
                  color: AppTheme.primaryGreen,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: AppTheme.primaryGreen.withValues(alpha: 0.06),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── GRAFICA DE PIE: Clases ──
  Widget _buildClasesPieChart() {
    if (_distribucionClases.isEmpty) {
      return _buildEmptyChart('No hay miembros registrados');
    }

    final colors = [
      const Color(0xFF1565C0),
      const Color(0xFF2E7D32),
      const Color(0xFFF57F17),
      const Color(0xFF6A1B9A),
      const Color(0xFFE65100),
    ];

    final total = _distribucionClases.fold<int>(0, (sum, r) => sum + (r['count'] as int));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 160,
            width: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: _distribucionClases.asMap().entries.map((e) {
                  final count = e.value['count'] as int;
                  final pct = total > 0 ? (count / total) * 100 : 0.0;
                  return PieChartSectionData(
                    value: count.toDouble(),
                    color: colors[e.key % colors.length],
                    radius: 50,
                    title: '${pct.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _distribucionClases.asMap().entries.map((e) {
                final clase = e.value['clase'] as String;
                final count = e.value['count'] as int;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[e.key % colors.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          clase,
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$count',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, size: 40, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
