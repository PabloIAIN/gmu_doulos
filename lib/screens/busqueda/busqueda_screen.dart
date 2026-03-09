import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/miembro.dart';
import '../../models/evento.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/user_avatar.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Miembro> _miembros = [];
  List<Evento> _eventos = [];
  List<Map<String, dynamic>> _especialidades = [];
  List<Map<String, dynamic>> _unidades = [];

  // Resultados filtrados
  List<Miembro> _miembrosFiltrados = [];
  List<Evento> _eventosFiltrados = [];
  List<Map<String, dynamic>> _especialidadesFiltradas = [];
  List<Map<String, dynamic>> _unidadesFiltradas = [];

  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    // Auto-focus el campo de busqueda
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    try {
      final miembros = await _db.getMiembros();
      final eventos = await _db.getEventos();
      final especialidades = await _db.getEspecialidades();
      final unidades = await _db.getUnidades();
      setState(() {
        _miembros = miembros;
        _eventos = eventos;
        _especialidades = especialidades;
        _unidades = unidades;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _buscar(String query) {
    setState(() {
      _query = query.toLowerCase().trim();
      if (_query.isEmpty) {
        _miembrosFiltrados = [];
        _eventosFiltrados = [];
        _especialidadesFiltradas = [];
        _unidadesFiltradas = [];
        return;
      }

      _miembrosFiltrados = _miembros.where((m) {
        return m.nombreCompleto.toLowerCase().contains(_query) ||
            m.clase.toLowerCase().contains(_query) ||
            m.rol.toLowerCase().contains(_query) ||
            m.email.toLowerCase().contains(_query) ||
            m.telefono.contains(_query);
      }).toList();

      _eventosFiltrados = _eventos.where((e) {
        return e.titulo.toLowerCase().contains(_query) ||
            (e.descripcion.toLowerCase().contains(_query)) ||
            (e.ubicacion.toLowerCase().contains(_query)) ||
            e.tipo.toLowerCase().contains(_query);
      }).toList();

      _especialidadesFiltradas = _especialidades.where((e) {
        return (e['nombre'] as String).toLowerCase().contains(_query) ||
            (e['categoria'] as String).toLowerCase().contains(_query);
      }).toList();

      _unidadesFiltradas = _unidades.where((u) {
        return (u['nombre'] as String).toLowerCase().contains(_query) ||
            ((u['descripcion'] as String?) ?? '').toLowerCase().contains(_query);
      }).toList();
    });
  }

  int get _totalResultados =>
      _miembrosFiltrados.length +
      _eventosFiltrados.length +
      _especialidadesFiltradas.length +
      _unidadesFiltradas.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barra de busqueda
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchCtrl,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Buscar miembros, eventos, especialidades...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                _buscar('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _buscar,
                  ),
                ),

                // Resultados
                if (_query.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          '$_totalResultados resultado${_totalResultados != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: _query.isEmpty
                      ? _buildSugerencias()
                      : _totalResultados == 0
                          ? _buildSinResultados()
                          : _buildResultados(),
                ),
              ],
            ),
    );
  }

  Widget _buildSugerencias() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Busca en todo el club',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Miembros, eventos, especialidades y unidades',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildSinResultados() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Sin resultados para "$_query"',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildResultados() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Miembros
        if (_miembrosFiltrados.isNotEmpty) ...[
          _buildSeccionHeader('Miembros', Icons.people, _miembrosFiltrados.length),
          ..._miembrosFiltrados.map(_buildMiembroTile),
          const SizedBox(height: 16),
        ],

        // Eventos
        if (_eventosFiltrados.isNotEmpty) ...[
          _buildSeccionHeader('Eventos', Icons.event, _eventosFiltrados.length),
          ..._eventosFiltrados.map(_buildEventoTile),
          const SizedBox(height: 16),
        ],

        // Especialidades
        if (_especialidadesFiltradas.isNotEmpty) ...[
          _buildSeccionHeader(
              'Especialidades', Icons.workspace_premium, _especialidadesFiltradas.length),
          ..._especialidadesFiltradas.map(_buildEspecialidadTile),
          const SizedBox(height: 16),
        ],

        // Unidades
        if (_unidadesFiltradas.isNotEmpty) ...[
          _buildSeccionHeader('Unidades', Icons.group_work, _unidadesFiltradas.length),
          ..._unidadesFiltradas.map(_buildUnidadTile),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSeccionHeader(String titulo, IconData icon, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryGreen),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiembroTile(Miembro m) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: UserAvatar(
          fotoUrl: m.fotoUrl,
          iniciales: m.iniciales,
          radius: 20,
        ),
        title: Text(m.nombreCompleto,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${m.clase} - ${m.rol}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => Navigator.pop(context, {'type': 'miembro', 'data': m}),
      ),
    );
  }

  Widget _buildEventoTile(Evento e) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: _getEventoColor(e.tipo).withValues(alpha: 0.1),
          child: Icon(_getEventoIcon(e.tipo), color: _getEventoColor(e.tipo), size: 20),
        ),
        title: Text(e.titulo,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${e.fecha.day}/${e.fecha.month}/${e.fecha.year} - ${e.tipo}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => Navigator.pop(context, {'type': 'evento', 'data': e}),
      ),
    );
  }

  Widget _buildEspecialidadTile(Map<String, dynamic> e) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withValues(alpha: 0.1),
          child: const Icon(Icons.workspace_premium, color: Colors.purple, size: 20),
        ),
        title: Text(e['nombre'] as String,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(e['categoria'] as String),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => Navigator.pop(context, {'type': 'especialidad', 'data': e}),
      ),
    );
  }

  Widget _buildUnidadTile(Map<String, dynamic> u) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          child: const Icon(Icons.group_work, color: Colors.orange, size: 20),
        ),
        title: Text(u['nombre'] as String,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text((u['descripcion'] as String?) ?? 'Sin descripcion'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => Navigator.pop(context, {'type': 'unidad', 'data': u}),
      ),
    );
  }

  Color _getEventoColor(String tipo) {
    switch (tipo) {
      case 'Campamento':
        return Colors.green;
      case 'Caminata':
        return Colors.blue;
      case 'Investidura':
        return Colors.purple;
      case 'Servicio':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  IconData _getEventoIcon(String tipo) {
    switch (tipo) {
      case 'Campamento':
        return Icons.terrain;
      case 'Caminata':
        return Icons.hiking;
      case 'Investidura':
        return Icons.military_tech;
      case 'Servicio':
        return Icons.volunteer_activism;
      default:
        return Icons.event;
    }
  }
}
