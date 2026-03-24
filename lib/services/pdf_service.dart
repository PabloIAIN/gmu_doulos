import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'database_service.dart';
import '../config/app_config.dart';

class PdfService {
  final DatabaseService _db = DatabaseService();

  /// Genera PDF de lista de miembros
  Future<File> generarReporteMiembros() async {
    final miembros = await _db.getMiembros();
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader('Reporte de Miembros', '${AppConfig.appName} - ${AppConfig.clubName}'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 12),
          pw.Text(
            'Total de miembros: ${miembros.length}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE8F5E9)),
            cellHeight: 28,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
            },
            headers: ['Nombre', 'Email', 'Telefono', 'Rol', 'Clase'],
            data: miembros.map((m) => [
              m.nombreCompleto,
              m.email.isNotEmpty ? m.email : '-',
              m.telefono.isNotEmpty ? m.telefono : '-',
              m.rol,
              m.clase,
            ]).toList(),
          ),
        ],
      ),
    );

    return _guardarPdf(doc, 'reporte_miembros');
  }

  /// Genera PDF de asistencia de una fecha especifica
  Future<File> generarReporteAsistenciaGeneral() async {
    final datos = await _db.getAsistenciaPorFechas(limit: 20);
    final unidades = await _db.getUnidades();
    final porcentajeGeneral = await _db.getPorcentajeAsistencia();
    final unidadWidgets = await _buildUnidadStats();
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader('Reporte de Asistencia', '${AppConfig.appName} - ${AppConfig.clubName}'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 12),

          // Resumen general
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFE8F5E9),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('Asistencia General', '${porcentajeGeneral.toStringAsFixed(1)}%'),
                _buildStatBox('Unidades', '${unidades.length}'),
                _buildStatBox('Registros', '${datos.length} fechas'),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Tabla de asistencia por fecha
          pw.Text('Asistencia por Fecha', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (datos.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE8F5E9)),
              cellHeight: 26,
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
              },
              headers: ['Fecha', 'Presentes', 'Tardanzas', 'Ausentes', '% Asistencia'],
              data: datos.map((d) {
                final total = d['total'] as int;
                final presentes = d['presentes'] as int;
                final tardanzas = d['tardanzas'] as int;
                final ausentes = d['ausentes'] as int;
                final pct = total > 0 ? ((presentes + tardanzas) / total * 100) : 0.0;
                return [
                  d['fecha'] as String,
                  '$presentes',
                  '$tardanzas',
                  '$ausentes',
                  '${pct.toStringAsFixed(1)}%',
                ];
              }).toList(),
            )
          else
            pw.Text('No hay datos de asistencia registrados.', style: const pw.TextStyle(fontSize: 11)),

          // Asistencia por unidad
          pw.SizedBox(height: 20),
          pw.Text('Asistencia por Unidad', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          ...unidadWidgets,
        ],
      ),
    );

    return _guardarPdf(doc, 'reporte_asistencia');
  }

  /// Genera PDF de carpeta de investidura de un miembro
  Future<File> generarReporteCarpeta(String miembroId) async {
    final miembro = await _db.getMiembro(miembroId);
    final secciones = await _db.getCarpetaSecciones();
    final progreso = await _db.getCarpetaProgresoMiembro(miembroId);
    final resumen = await _db.getCarpetaResumen(miembroId);

    // Pre-cargar requisitos de cada seccion
    final requisitosPorSeccion = <String, List<Map<String, dynamic>>>{};
    for (final seccion in secciones) {
      final seccionId = seccion['id'] as String? ?? '';
      if (seccionId.isNotEmpty) {
        requisitosPorSeccion[seccionId] = await _db.getCarpetaRequisitos(seccionId);
      }
    }

    final nombre = miembro != null ? miembro.nombreCompleto : 'Miembro';
    final clase = miembro?.clase ?? '';
    final total = resumen['total'] ?? 0;
    final aprobados = resumen['aprobados'] ?? 0;
    final enviados = resumen['enviados'] ?? 0;
    final preaprobados = resumen['preaprobados'] ?? 0;
    final devueltos = resumen['devueltos'] ?? 0;
    final pendientes = total - aprobados - enviados - preaprobados - devueltos;
    final pct = total > 0 ? (aprobados / total * 100) : 0.0;

    // Organizar progreso por requisito id (r.id de la query)
    final progresoMap = <String, Map<String, dynamic>>{};
    for (final p in progreso) {
      final id = p['id'] as String?;
      if (id != null) progresoMap[id] = p;
    }

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader('Carpeta de Investidura', nombre),
        footer: (context) => _buildFooter(context),
        build: (context) {
          final widgets = <pw.Widget>[];

          // Info del miembro
          widgets.add(pw.SizedBox(height: 8));
          widgets.add(pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFE8F5E9),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('Progreso', '${pct.toStringAsFixed(0)}%'),
                _buildStatBox('Aprobados', '$aprobados/$total'),
                _buildStatBox('Enviados', '$enviados'),
                _buildStatBox('Pendientes', '$pendientes'),
                _buildStatBox('Clase', clase),
              ],
            ),
          ));
          widgets.add(pw.SizedBox(height: 16));

          // Secciones con requisitos
          for (final seccion in secciones) {
            final seccionId = seccion['id'] as String? ?? '';
            final seccionNombre = seccion['nombre'] as String? ?? '';
            final seccionNumero = seccion['numero'] as int? ?? 0;
            final requisitos = requisitosPorSeccion[seccionId] ?? [];

            widgets.add(pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 4),
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFF2E7D32),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                '$seccionNumero. $seccionNombre',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ));

            // Tabla de requisitos para esta seccion
            final reqData = <List<String>>[];
            for (final req in requisitos) {
              final reqId = req['id'] as String? ?? '';
              final reqNombre = req['nombre'] as String? ?? '';
              final prog = progresoMap[reqId];
              String estado = 'Pendiente';
              if (prog != null) {
                final e = prog['estado'] as String? ?? 'pendiente';
                switch (e) {
                  case 'aprobado':
                    estado = 'Aprobado';
                    break;
                  case 'preaprobado':
                    estado = 'Pre-aprobado';
                    break;
                  case 'enviado':
                    estado = 'Enviado';
                    break;
                  case 'devuelto':
                    estado = 'Devuelto';
                    break;
                  default:
                    estado = prog['completado'] == 1 ? 'Completado' : 'Pendiente';
                }
              }
              reqData.add([reqNombre, estado]);
            }

            if (reqData.isNotEmpty) {
              widgets.add(pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE8F5E9)),
                cellHeight: 24,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                },
                headers: ['Requisito', 'Estado'],
                data: reqData,
              ));
            }
            widgets.add(pw.SizedBox(height: 12));
          }

          return widgets;
        },
      ),
    );

    return _guardarPdf(doc, 'carpeta_${nombre.replaceAll(' ', '_').toLowerCase()}');
  }

  Future<List<pw.Widget>> _buildUnidadStats() async {
    final unidadStats = await _db.getAsistenciaPorUnidad();
    if (unidadStats.isEmpty) {
      return [pw.Text('No hay datos por unidad.', style: const pw.TextStyle(fontSize: 11))];
    }

    return [
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE8F5E9)),
        cellHeight: 26,
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.center,
          2: pw.Alignment.center,
          3: pw.Alignment.center,
        },
        headers: ['Unidad', 'Total Registros', 'Asistieron', '% Asistencia'],
        data: unidadStats.map((d) {
          final total = d['total'] as int;
          final asistieron = d['asistieron'] as int;
          final pct = total > 0 ? (asistieron / total * 100) : 0.0;
          return [
            d['unidad'] as String,
            '$total',
            '$asistieron',
            '${pct.toStringAsFixed(1)}%',
          ];
        }).toList(),
      ),
    ];
  }

  pw.Widget _buildHeader(String title, String subtitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text(subtitle, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              ],
            ),
            pw.Text(
              'Generado: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
            ),
          ],
        ),
        pw.Divider(thickness: 1.5, color: const PdfColor.fromInt(0xFF2E7D32)),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          '${AppConfig.appName} - ${AppConfig.tagline}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        ),
        pw.Text(
          'Pagina ${context.pageNumber} de ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        ),
      ],
    );
  }

  pw.Widget _buildStatBox(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 2),
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
      ],
    );
  }

  Future<File> _guardarPdf(pw.Document doc, String nombre) async {
    final dir = await getApplicationDocumentsDirectory();
    final reportesDir = Directory('${dir.path}/reportes');
    if (!await reportesDir.exists()) {
      await reportesDir.create(recursive: true);
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${reportesDir.path}/${nombre}_$timestamp.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }
}
