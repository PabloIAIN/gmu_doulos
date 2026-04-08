import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class AnunciosScreen extends StatefulWidget {
  const AnunciosScreen({super.key});

  @override
  State<AnunciosScreen> createState() => _AnunciosScreenState();
}

class _AnunciosScreenState extends State<AnunciosScreen> {
  final _db = DatabaseService();
  final _auth = AuthService();
  List<Map<String, dynamic>> _anuncios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    try {
      _anuncios = await _db.getAnuncios(clubId: _auth.clubId);
    } catch (_) {
      _anuncios = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _crear() async {
    final tituloCtl = TextEditingController();
    final contenidoCtl = TextEditingController();
    String tipo = 'general';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Nuevo Anuncio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: tituloCtl,
                  decoration: const InputDecoration(labelText: 'Titulo', prefixIcon: Icon(Icons.title)),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contenidoCtl,
                  decoration: const InputDecoration(labelText: 'Contenido', alignLabelWithHint: true, border: OutlineInputBorder()),
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tipo,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: const [
                    DropdownMenuItem(value: 'general', child: Text('General')),
                    DropdownMenuItem(value: 'urgente', child: Text('Urgente')),
                    DropdownMenuItem(value: 'evento', child: Text('Evento')),
                    DropdownMenuItem(value: 'devocional', child: Text('Devocional')),
                  ],
                  onChanged: (v) => setSt(() => tipo = v ?? 'general'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || tituloCtl.text.trim().isEmpty || contenidoCtl.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _db.insertAnuncio({
      'id': id,
      'club_id': _auth.clubId ?? 'doulos-montemorelos',
      'ministerio': _auth.ministerioActivo,
      'titulo': tituloCtl.text.trim(),
      'contenido': contenidoCtl.text.trim(),
      'autor_id': user?.id,
      'autor_nombre': user?.nombreCompleto ?? 'Director',
      'tipo': tipo,
      'fecha_publicacion': DateTime.now().toIso8601String(),
      'activo': 1,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anuncio publicado'), backgroundColor: AppTheme.successGreen),
      );
    }
    _cargar();
  }

  Future<void> _eliminar(Map<String, dynamic> a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar anuncio'),
        content: Text('Â¿Eliminar "${a['titulo']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _db.deleteAnuncio(a['id'] as String);
      _cargar();
    }
  }

  void _compartir(Map<String, dynamic> a) {
    final texto = '${a['titulo']}\n\n${a['contenido']}\n\n- ${a['autor_nombre'] ?? 'GMU Doulos'}';
    Share.share(texto, subject: a['titulo'] as String?);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anuncios'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar),
        ],
      ),
      floatingActionButton: _auth.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _crear,
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Publicar'),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _anuncios.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No hay anuncios todavia', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      if (_auth.isAdmin) ...[
                        const SizedBox(height: 8),
                        Text('Toca "Publicar" para crear el primero', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _anuncios.length,
                    itemBuilder: (_, i) => _buildCard(_anuncios[i]),
                  ),
                ),
    );
  }

  Widget _buildCard(Map<String, dynamic> a) {
    final tipo = a['tipo'] as String? ?? 'general';
    final color = _colorPorTipo(tipo);
    final icon = _iconPorTipo(tipo);
    final fecha = DateTime.tryParse(a['fecha_publicacion']?.toString() ?? '') ?? DateTime.now();
    final diff = DateTime.now().difference(fecha);
    final tiempo = diff.inDays > 0
        ? 'hace ${diff.inDays}d'
        : diff.inHours > 0
            ? 'hace ${diff.inHours}h'
            : diff.inMinutes > 0
                ? 'hace ${diff.inMinutes}m'
                : 'ahora';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a['titulo'] as String? ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${a['autor_nombre'] ?? 'Director'} Â· $tiempo',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (_auth.isAdmin)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (v) {
                      if (v == 'eliminar') _eliminar(a);
                      if (v == 'compartir') _compartir(a);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'compartir', child: Row(children: [Icon(Icons.share, size: 18), SizedBox(width: 8), Text('Compartir')])),
                      const PopupMenuItem(value: 'eliminar', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: Colors.red))])),
                    ],
                  )
                else
                  IconButton(
                    icon: Icon(Icons.share_outlined, color: Colors.grey[600], size: 20),
                    onPressed: () => _compartir(a),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              a['contenido'] as String? ?? '',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'urgente': return AppTheme.errorRed;
      case 'evento': return AppTheme.infoBlue;
      case 'devocional': return Colors.purple;
      default: return AppTheme.primaryGreen;
    }
  }

  IconData _iconPorTipo(String tipo) {
    switch (tipo) {
      case 'urgente': return Icons.priority_high;
      case 'evento': return Icons.event;
      case 'devocional': return Icons.menu_book;
      default: return Icons.campaign;
    }
  }
}
