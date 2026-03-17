import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/miembro.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';

class ImportarMiembrosScreen extends StatefulWidget {
  const ImportarMiembrosScreen({super.key});

  @override
  State<ImportarMiembrosScreen> createState() => _ImportarMiembrosScreenState();
}

class _ImportarMiembrosScreenState extends State<ImportarMiembrosScreen> {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _pasteController = TextEditingController();

  // Estado del flujo
  int _paso = 0; // 0: seleccionar, 1: mapear, 2: preview, 3: resultado

  // CSV data
  List<String> _csvHeaders = [];
  List<List<String>> _csvRows = [];
  String? _fileName;

  // Mapeo de columnas CSV → campos de Miembro
  final Map<String, String?> _columnMap = {
    'nombre': null,
    'apellido': null,
    'telefono': null,
    'email': null,
    'fecha_nacimiento': null,
  };

  // Valores por defecto para campos no mapeados
  String _defaultRol = 'Miembro';
  String _defaultClase = 'Guía Mayor Aspirante';
  bool _splitNombreCompleto = true;

  // Resultado de importacion
  int _importados = 0;
  int _errores = 0;
  int _duplicados = 0;
  bool _isImporting = false;
  final List<String> _errorDetails = [];

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }

  // ── Pegar desde portapapeles ──
  Future<void> _pegarDesdeClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _pasteController.text = data.text!;
      if (mounted) setState(() {});
    }
  }

  void _procesarTexto() {
    final text = _pasteController.text.trim();
    if (text.isEmpty) return;
    _parseCsv(text, 'datos_pegados.csv');
  }

  void _parseCsv(String content, String fileName) {
    // Detectar separador (coma o tab)
    final firstLine = content.split('\n').first;
    final separator = firstLine.contains('\t') ? '\t' : ',';

    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return;

    final headers = _parseCsvLine(lines.first, separator);
    final rows = <List<String>>[];
    for (int i = 1; i < lines.length; i++) {
      final row = _parseCsvLine(lines[i], separator);
      while (row.length < headers.length) {
        row.add('');
      }
      rows.add(row);
    }

    if (rows.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron datos en el archivo')),
        );
      }
      return;
    }

    setState(() {
      _csvHeaders = headers;
      _csvRows = rows;
      _fileName = fileName;
      _paso = 1;
      _autoMapColumns();
    });
  }

  List<String> _parseCsvLine(String line, String separator) {
    final result = <String>[];
    bool inQuotes = false;
    StringBuffer current = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == separator[0] && !inQuotes) {
        result.add(current.toString().trim());
        current = StringBuffer();
      } else if (char != '\r') {
        current.write(char);
      }
    }
    result.add(current.toString().trim());
    return result;
  }

  void _autoMapColumns() {
    for (int i = 0; i < _csvHeaders.length; i++) {
      final h = _csvHeaders[i].toLowerCase();
      if (h.contains('nombre') && h.contains('completo')) {
        _columnMap['nombre'] = _csvHeaders[i];
        _splitNombreCompleto = true;
      } else if (h.contains('nombre') && !h.contains('apellido') && _columnMap['nombre'] == null) {
        _columnMap['nombre'] = _csvHeaders[i];
      } else if (h.contains('apellido')) {
        _columnMap['apellido'] = _csvHeaders[i];
        _splitNombreCompleto = false;
      } else if (h.contains('tel') || h.contains('celular') || h.contains('phone')) {
        _columnMap['telefono'] ??= _csvHeaders[i];
      } else if (h.contains('email') || h.contains('correo') || h.contains('contacto')) {
        _columnMap['email'] ??= _csvHeaders[i];
      } else if (h.contains('nacimiento') || h.contains('birth')) {
        _columnMap['fecha_nacimiento'] ??= _csvHeaders[i];
      }
    }
  }

  List<Map<String, String>> _generatePreview() {
    final preview = <Map<String, String>>[];
    final limit = _csvRows.length > 10 ? 10 : _csvRows.length;
    for (int i = 0; i < limit; i++) {
      final data = _extractMemberData(_csvRows[i]);
      if (data != null) preview.add(data);
    }
    return preview;
  }

  Map<String, String>? _extractMemberData(List<String> row) {
    String nombre = '';
    String apellido = '';
    String telefono = '';
    String email = '';

    final colNombre = _columnMap['nombre'];
    final colApellido = _columnMap['apellido'];
    final colTelefono = _columnMap['telefono'];
    final colEmail = _columnMap['email'];

    if (colNombre != null) {
      final idx = _csvHeaders.indexOf(colNombre);
      if (idx >= 0 && idx < row.length) {
        final valor = row[idx].trim();
        if (_splitNombreCompleto) {
          final partes = valor.split(' ');
          if (partes.length >= 2) {
            nombre = partes.first;
            apellido = partes.sublist(1).join(' ');
          } else {
            nombre = valor;
          }
        } else {
          nombre = valor;
        }
      }
    }

    if (colApellido != null && !_splitNombreCompleto) {
      final idx = _csvHeaders.indexOf(colApellido);
      if (idx >= 0 && idx < row.length) apellido = row[idx].trim();
    }

    if (colTelefono != null) {
      final idx = _csvHeaders.indexOf(colTelefono);
      if (idx >= 0 && idx < row.length) telefono = row[idx].trim();
    }

    if (colEmail != null) {
      final idx = _csvHeaders.indexOf(colEmail);
      if (idx >= 0 && idx < row.length) email = row[idx].trim();
    }

    if (nombre.isEmpty) return null;

    return {
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'email': email,
    };
  }

  Future<void> _importar() async {
    setState(() {
      _isImporting = true;
      _importados = 0;
      _errores = 0;
      _duplicados = 0;
      _errorDetails.clear();
    });

    final existentes = await _db.getMiembros();
    final nombresExistentes = existentes.map((m) => m.nombreCompleto.toLowerCase()).toSet();

    for (final row in _csvRows) {
      try {
        final data = _extractMemberData(row);
        if (data == null || data['nombre']!.isEmpty) continue;

        final nombreCompleto = '${data['nombre']} ${data['apellido']}'.trim().toLowerCase();
        if (nombresExistentes.contains(nombreCompleto)) {
          _duplicados++;
          continue;
        }

        final miembro = Miembro(
          id: DateTime.now().millisecondsSinceEpoch.toString() +
              _importados.toString(),
          nombre: data['nombre']!,
          apellido: data['apellido']!,
          fechaNacimiento: DateTime(2000, 1, 1),
          telefono: data['telefono']!,
          email: data['email']!,
          clase: _defaultClase,
          rol: _defaultRol,
          activo: true,
          fechaRegistro: DateTime.now(),
        );

        await _db.insertMiembro(miembro);
        nombresExistentes.add(nombreCompleto);
        _importados++;
      } catch (e) {
        _errores++;
        _errorDetails.add('Fila: ${row.take(2).join(', ')} - $e');
      }
    }

    if (mounted) {
      setState(() {
        _isImporting = false;
        _paso = 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Miembros'),
        actions: [
          if (_paso > 0 && _paso < 3)
            TextButton(
              onPressed: () => setState(() {
                _paso = 0;
                _csvHeaders.clear();
                _csvRows.clear();
                _columnMap.updateAll((key, value) => null);
                _pasteController.clear();
              }),
              child: const Text('Reiniciar'),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_paso) {
      case 0:
        return _buildSeleccionarArchivo();
      case 1:
        return _buildMapearColumnas();
      case 2:
        return _buildPreview();
      case 3:
        return _buildResultado();
      default:
        return const SizedBox.shrink();
    }
  }

  // ══════════ PASO 0: Seleccionar archivo ══════════

  Widget _buildSeleccionarArchivo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.content_paste_go_rounded, size: 56, color: AppTheme.primaryGreen),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Importar Miembros',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Pega los datos de tu Google Sheet aqui',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),

          // Instrucciones
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.infoBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.infoBlue.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppTheme.infoBlue),
                    const SizedBox(width: 8),
                    Text('Como exportar', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.infoBlue)),
                  ],
                ),
                const SizedBox(height: 8),
                _buildStep('1', 'Abre tu Google Sheet en el celular'),
                _buildStep('2', 'Selecciona todas las celdas (con encabezados)'),
                _buildStep('3', 'Copia las celdas'),
                _buildStep('4', 'Toca "Pegar desde portapapeles" abajo'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pegar texto
          TextField(
            controller: _pasteController,
            maxLines: 6,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Copia las celdas de Google Sheets y pegalas aqui...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.content_paste_rounded),
                tooltip: 'Pegar',
                onPressed: _pegarDesdeClipboard,
              ),
            ),
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pasteController.text.trim().isNotEmpty ? _procesarTexto : null,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Procesar datos pegados'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.infoBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(num, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.infoBlue)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
        ],
      ),
    );
  }

  // ══════════ PASO 1: Mapear columnas ══════════

  Widget _buildMapearColumnas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_fileName ?? 'archivo.csv', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('${_csvRows.length} filas · ${_csvHeaders.length} columnas',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Mapear columnas', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Selecciona que columna del CSV corresponde a cada campo',
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Nombre completo en una columna', style: TextStyle(fontSize: 14)),
            subtitle: Text(
              _splitNombreCompleto
                  ? 'Se dividira automaticamente en nombre y apellido'
                  : 'Nombre y apellido en columnas separadas',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            value: _splitNombreCompleto,
            onChanged: (v) => setState(() => _splitNombreCompleto = v),
            activeTrackColor: AppTheme.primaryGreen,
          ),
          const SizedBox(height: 8),

          _buildColumnDropdown('Nombre${_splitNombreCompleto ? ' completo' : ''}', 'nombre', isRequired: true),
          if (!_splitNombreCompleto)
            _buildColumnDropdown('Apellido', 'apellido', isRequired: true),
          _buildColumnDropdown('Telefono', 'telefono'),
          _buildColumnDropdown('Email / Contacto', 'email'),
          _buildColumnDropdown('Fecha de nacimiento', 'fecha_nacimiento'),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          Text('Valores por defecto', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Se asignaran a todos los miembros importados',
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _defaultRol,
            decoration: const InputDecoration(
              labelText: 'Rol por defecto',
              prefixIcon: Icon(Icons.badge, size: 20),
            ),
            items: ClasesGuiasMayores.roles
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => _defaultRol = v!),
          ),
          const SizedBox(height: 14),

          DropdownButtonFormField<String>(
            initialValue: _defaultClase,
            decoration: const InputDecoration(
              labelText: 'Clase por defecto',
              prefixIcon: Icon(Icons.school, size: 20),
            ),
            items: ClasesGuiasMayores.clases
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _defaultClase = v!),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _columnMap['nombre'] != null
                  ? () => setState(() => _paso = 2)
                  : null,
              icon: const Icon(Icons.preview_rounded),
              label: const Text('Ver preview'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnDropdown(String label, String field, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: _columnMap[field],
        decoration: InputDecoration(
          labelText: '$label${isRequired ? ' *' : ''}',
          prefixIcon: Icon(_getFieldIcon(field), size: 20),
        ),
        isExpanded: true,
        items: [
          const DropdownMenuItem(value: null, child: Text('— No mapear —')),
          ..._csvHeaders.map((h) => DropdownMenuItem(value: h, child: Text(h, overflow: TextOverflow.ellipsis))),
        ],
        onChanged: (v) => setState(() => _columnMap[field] = v),
      ),
    );
  }

  IconData _getFieldIcon(String field) {
    switch (field) {
      case 'nombre': return Icons.person;
      case 'apellido': return Icons.person_outline;
      case 'telefono': return Icons.phone;
      case 'email': return Icons.email;
      case 'fecha_nacimiento': return Icons.cake;
      default: return Icons.text_fields;
    }
  }

  // ══════════ PASO 2: Preview ══════════

  Widget _buildPreview() {
    final preview = _generatePreview();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people, color: AppTheme.primaryGreen),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_csvRows.length} miembros a importar',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    Text('Rol: $_defaultRol · Clase: $_defaultClase',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: preview.length + (preview.length < _csvRows.length ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i >= preview.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    '... y ${_csvRows.length - preview.length} mas',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                  ),
                );
              }
              final data = preview[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    child: Text(
                      data['nombre']!.isNotEmpty ? data['nombre']![0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                    ),
                  ),
                  title: Text(
                    '${data['nombre']} ${data['apellido']}'.trim(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    [
                      if (data['telefono']!.isNotEmpty) data['telefono']!,
                      if (data['email']!.isNotEmpty) data['email']!,
                    ].join(' · '),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _paso = 1),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Atras'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _isImporting ? null : _importar,
                  icon: _isImporting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.download_rounded),
                  label: Text(_isImporting ? 'Importando...' : 'Importar ${_csvRows.length} miembros'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════ PASO 3: Resultado ══════════

  Widget _buildResultado() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _errores == 0 && _importados > 0
                  ? AppTheme.successGreen.withValues(alpha: 0.1)
                  : AppTheme.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _errores == 0 && _importados > 0 ? Icons.check_circle_rounded : Icons.info_rounded,
              size: 64,
              color: _errores == 0 && _importados > 0 ? AppTheme.successGreen : AppTheme.warningOrange,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Importacion completada',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildResultStat('Importados', '$_importados', AppTheme.successGreen),
              _buildResultStat('Duplicados', '$_duplicados', AppTheme.warningOrange),
              _buildResultStat('Errores', '$_errores', AppTheme.errorRed),
            ],
          ),
          if (_errorDetails.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView(
                children: _errorDetails
                    .map((e) => Text(e, style: TextStyle(fontSize: 12, color: Colors.grey[700])))
                    .toList(),
              ),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Listo'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }
}
