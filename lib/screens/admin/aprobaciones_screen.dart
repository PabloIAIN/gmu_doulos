import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../config/app_config.dart';

class AprobacionesScreen extends StatefulWidget {
  const AprobacionesScreen({super.key});

  @override
  State<AprobacionesScreen> createState() => _AprobacionesScreenState();
}

class _AprobacionesScreenState extends State<AprobacionesScreen> {
  final _api = ApiService();
  final _auth = AuthService();
  List<Map<String, dynamic>> _pendientes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final clubId = _auth.clubId ?? 'doulos-montemorelos';
      final ministerio = _auth.ministerioActivo;
      _pendientes = await _api.getPendientes(clubId, ministerio: ministerio == 'todos' ? null : ministerio);
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _aprobar(Map<String, dynamic> m) async {
    try {
      await _api.aprobarMiembro(
        clubId: _auth.clubId ?? 'doulos-montemorelos',
        miembroId: m['id'] as String,
        accion: 'aprobar',
        rol: m['rol'] as String?,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${m['nombre']} aprobado'), backgroundColor: AppTheme.successGreen),
        );
      }
      _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  Future<void> _rechazar(Map<String, dynamic> m) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rechazar solicitud'),
        content: Text('¿Rechazar a ${m['nombre']} ${m['apellido']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await _api.aprobarMiembro(
        clubId: _auth.clubId ?? 'doulos-montemorelos',
        miembroId: m['id'] as String,
        accion: 'rechazar',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud rechazada')),
        );
      }
      _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes Pendientes')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('Error al cargar', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    FilledButton.icon(onPressed: _cargar, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
                  ],
                ))
              : _pendientes.isEmpty
                  ? Center(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: AppTheme.successGreen.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text('No hay solicitudes pendientes', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      ],
                    ))
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pendientes.length,
                        itemBuilder: (_, i) => _buildCard(_pendientes[i]),
                      ),
                    ),
    );
  }

  Widget _buildCard(Map<String, dynamic> m) {
    final nombre = '${m['nombre'] ?? ''} ${m['apellido'] ?? ''}'.trim();
    final rol = m['rol'] as String? ?? 'Miembro';
    final ministerio = m['ministerio'] as String? ?? 'gm';
    final ministerioNombre = AppConfig.ministeriosNombres[ministerio] ?? ministerio;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  child: const Icon(Icons.person_add, color: AppTheme.primaryGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('$rol · $ministerioNombre', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rechazar(m),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorRed),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _aprobar(m),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Aprobar'),
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
