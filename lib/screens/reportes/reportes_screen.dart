import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../../services/pdf_service.dart';
import '../../services/database_service.dart';
import '../../models/miembro.dart';
import '../../theme/app_theme.dart';
import '../../widgets/user_avatar.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final PdfService _pdf = PdfService();
  final DatabaseService _db = DatabaseService();
  bool _generando = false;
  String? _generandoTipo;

  Future<void> _generarReporte(String tipo) async {
    setState(() {
      _generando = true;
      _generandoTipo = tipo;
    });

    try {
      File archivo;
      if (tipo == 'miembros') {
        archivo = await _pdf.generarReporteMiembros();
      } else if (tipo == 'asistencia') {
        archivo = await _pdf.generarReporteAsistenciaGeneral();
      } else {
        // carpeta: no deberia llegar aqui
        return;
      }

      if (!mounted) return;

      _mostrarResultado(archivo, tipo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar reporte: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _generando = false;
        _generandoTipo = null;
      });
    }
  }

  Future<void> _generarReporteCarpeta() async {
    // Mostrar dialogo para seleccionar miembro
    final miembros = await _db.getMiembros();
    final aspirantes = miembros.where((m) => m.rol == 'Miembro').toList();

    if (!mounted) return;

    final seleccionado = await showDialog<Miembro>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Seleccionar aspirante'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: aspirantes.isEmpty
              ? const Center(child: Text('No hay aspirantes registrados'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: aspirantes.length,
                  itemBuilder: (ctx, i) {
                    final m = aspirantes[i];
                    return ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      leading: UserAvatar(
                        fotoUrl: m.fotoUrl,
                        iniciales: m.iniciales,
                        radius: 20,
                      ),
                      title: Text(m.nombreCompleto),
                      subtitle: Text(m.clase, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      onTap: () => Navigator.pop(ctx, m),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ],
      ),
    );

    if (seleccionado == null || !mounted) return;

    setState(() {
      _generando = true;
      _generandoTipo = 'carpeta';
    });

    try {
      final archivo = await _pdf.generarReporteCarpeta(seleccionado.id);
      if (!mounted) return;
      _mostrarResultado(archivo, 'Carpeta - ${seleccionado.nombreCompleto}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }

    if (mounted) {
      setState(() {
        _generando = false;
        _generandoTipo = null;
      });
    }
  }

  void _mostrarResultado(File archivo, String tipo) {
    final nombre = tipo == 'miembros' ? 'Miembros' : 'Asistencia';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'Reporte de $nombre generado',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                archivo.path.split('/').last,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        OpenFilex.open(archivo.path);
                      },
                      icon: const Icon(Icons.visibility_rounded),
                      label: const Text('Abrir'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Share.shareXFiles(
                          [XFile(archivo.path)],
                          text: 'Reporte de $nombre - GMU Doulos',
                        );
                      },
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Compartir'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generar Reportes',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Genera reportes en PDF para imprimir o compartir',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildReporteCard(
              icon: Icons.people_rounded,
              color: const Color(0xFF1565C0),
              titulo: 'Lista de Miembros',
              descripcion: 'Nombre, email, telefono, rol y clase de todos los miembros activos',
              tipo: 'miembros',
            ),
            const SizedBox(height: 14),
            _buildReporteCard(
              icon: Icons.fact_check_rounded,
              color: AppTheme.primaryGreen,
              titulo: 'Reporte de Asistencia',
              descripcion: 'Resumen de asistencia por fecha y por unidad con porcentajes',
              tipo: 'asistencia',
            ),
            const SizedBox(height: 14),
            _buildReporteCard(
              icon: Icons.folder_special_rounded,
              color: const Color(0xFF6A1B9A),
              titulo: 'Carpeta de Investidura',
              descripcion: 'Progreso individual de un aspirante con todas sus secciones y requisitos',
              tipo: 'carpeta',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReporteCard({
    required IconData icon,
    required Color color,
    required String titulo,
    required String descripcion,
    required String tipo,
  }) {
    final isGenerating = _generando && _generandoTipo == tipo;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _generando ? null : () {
            if (tipo == 'carpeta') {
              _generarReporteCarpeta();
            } else {
              _generarReporte(tipo);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descripcion,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isGenerating)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.picture_as_pdf_rounded, color: color, size: 20),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
