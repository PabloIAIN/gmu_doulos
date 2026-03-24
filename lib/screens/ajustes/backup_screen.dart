import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import '../../config/app_config.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final DatabaseService _db = DatabaseService();
  Map<String, int>? _resumen;
  bool _isLoading = true;
  bool _exportando = false;
  bool _importando = false;

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    final resumen = await _db.getResumenDatos();
    setState(() {
      _resumen = resumen;
      _isLoading = false;
    });
  }

  Future<void> _exportar() async {
    setState(() => _exportando = true);
    try {
      final jsonStr = await _db.exportarDatosJson();
      final dir = await getApplicationDocumentsDirectory();
      final fecha = DateTime.now().toIso8601String().substring(0, 10);
      final file = File('${dir.path}/gmu_doulos_backup_$fecha.json');
      await file.writeAsString(jsonStr);

      // Compartir el archivo
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '${AppConfig.appName} - Backup $fecha',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup exportado exitosamente'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
    setState(() => _exportando = false);
  }

  Future<void> _importar() async {
    // Confirmar antes de importar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importar datos'),
        content: const Text(
          'Se importaran los datos del backup. Los registros existentes '
          'no seran reemplazados (solo se agregan nuevos).\n\n'
          '¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Importar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    setState(() => _importando = true);
    try {
      // Buscar archivos de backup en el directorio de documentos
      final dir = await getApplicationDocumentsDirectory();
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json') && f.path.contains('gmu_doulos_backup'))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path));

      if (files.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se encontraron archivos de backup'),
            ),
          );
        }
        setState(() => _importando = false);
        return;
      }

      // Mostrar lista de backups disponibles
      if (!mounted) return;
      final selectedFile = await showModalBottomSheet<File>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Seleccionar backup',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            const Divider(height: 0),
            ...files.map((f) {
              final name = f.path.split('/').last.split('\\').last;
              return ListTile(
                leading: const Icon(Icons.file_present, color: AppTheme.primaryGreen),
                title: Text(name),
                subtitle: Text(
                  'Tamaño: ${(f.lengthSync() / 1024).toStringAsFixed(1)} KB',
                ),
                onTap: () => Navigator.pop(ctx, f),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      );

      if (selectedFile == null) {
        setState(() => _importando = false);
        return;
      }

      final jsonStr = await selectedFile.readAsString();
      final counts = await _db.importarDatosJson(jsonStr);

      await _cargarResumen();

      if (mounted) {
        final total = counts.values.fold<int>(0, (a, b) => a + b);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Importados $total registros exitosamente'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar: $e')),
        );
      }
    }
    setState(() => _importando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup de Datos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Resumen de datos
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Datos en la app',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_resumen != null) ...[
                            _buildResumenRow(
                                Icons.people, 'Miembros', _resumen!['miembros'] ?? 0),
                            _buildResumenRow(
                                Icons.event, 'Eventos', _resumen!['eventos'] ?? 0),
                            _buildResumenRow(Icons.fact_check, 'Registros de asistencia',
                                _resumen!['asistencia'] ?? 0),
                            _buildResumenRow(Icons.workspace_premium, 'Especialidades',
                                _resumen!['especialidades'] ?? 0),
                            _buildResumenRow(Icons.group_work, 'Unidades',
                                _resumen!['unidades'] ?? 0),
                            _buildResumenRow(Icons.photo_library, 'Evidencias',
                                _resumen!['evidencias'] ?? 0),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Exportar
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.upload_file,
                                  color: AppTheme.primaryGreen),
                              const SizedBox(width: 8),
                              Text(
                                'Exportar Backup',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Genera un archivo JSON con todos los datos del club. '
                            'Puedes guardarlo o compartirlo.',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _exportando ? null : _exportar,
                              icon: _exportando
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.download),
                              label: Text(
                                  _exportando ? 'Exportando...' : 'Exportar Datos'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Importar
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.download_for_offline,
                                  color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Importar Backup',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Restaura datos desde un backup previo. Solo se agregan '
                            'registros nuevos, los existentes no se modifican.',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _importando ? null : _importar,
                              icon: _importando
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.upload),
                              label: Text(
                                  _importando ? 'Importando...' : 'Importar Datos'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Nota
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.amber, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Recomendamos hacer backups regularmente para '
                            'proteger los datos del club.',
                            style: TextStyle(
                                color: Colors.amber[800], fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildResumenRow(IconData icon, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
