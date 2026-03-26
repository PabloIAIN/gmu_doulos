import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/section_header.dart';
import '../unidades/unidades_screen.dart';
import '../miembros/miembros_screen.dart';
import '../calendario/calendario_screen.dart';
import '../asistencia/asistencia_screen.dart';
import '../carpeta/carpeta_manage_screen.dart';
import '../carpeta/carpeta_approve_screen.dart';
import 'gestion_cuentas_screen.dart';
import 'importar_miembros_screen.dart';
import 'sync_screen.dart';
import 'aprobaciones_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const AdminPanelScreen({super.key, this.onOpenDrawer});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final DatabaseService _db = DatabaseService();
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarStats();
  }

  Future<void> _cargarStats() async {
    try {
      final resumen = await _db.getResumenDatos();
      setState(() {
        _stats = resumen;
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
        leading: widget.onOpenDrawer != null
            ? IconButton(icon: const Icon(Icons.menu), onPressed: widget.onOpenDrawer)
            : null,
        title: const Text('Panel de Admin'),
      ),
      body: RefreshIndicator(
        onRefresh: _cargarStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats rapidos
              if (!_isLoading) ...[
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.people,
                        title: 'Miembros',
                        value: '${_stats['miembros'] ?? 0}',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.event,
                        title: 'Eventos',
                        value: '${_stats['eventos'] ?? 0}',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.group_work,
                        title: 'Unidades',
                        value: '${_stats['unidades'] ?? 0}',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              const SectionHeader(title: 'Gestion'),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.85,
                children: [
                  _buildActionCard(icon: Icons.people, label: 'Miembros', color: Colors.blue, onTap: () => _navTo(const MiembrosScreen())),
                  _buildActionCard(icon: Icons.group_work, label: 'Unidades', color: Colors.orange, onTap: () => _navTo(const UnidadesScreen())),
                  _buildActionCard(icon: Icons.calendar_month, label: 'Eventos', color: Colors.green, onTap: () => _navTo(const CalendarioScreen())),
                  _buildActionCard(icon: Icons.fact_check, label: 'Asistencia', color: Colors.purple, onTap: () => _navTo(const AsistenciaScreen())),
                  _buildActionCard(icon: Icons.folder_copy, label: 'Gestionar\nCarpeta', color: Colors.teal, onTap: () => _navTo(const CarpetaManageScreen())),
                  _buildActionCard(icon: Icons.approval, label: 'Aprobar\nCarpetas', color: Colors.amber, onTap: () => _navTo(const CarpetaApproveScreen())),
                  _buildActionCard(icon: Icons.manage_accounts, label: 'Cuentas', color: Colors.indigo, onTap: () => _navTo(const GestionCuentasScreen())),
                  _buildActionCard(icon: Icons.upload_file, label: 'Importar\nMiembros', color: Colors.cyan, onTap: () => _navTo(const ImportarMiembrosScreen())),
                  _buildActionCard(icon: Icons.campaign, label: 'Enviar\nAviso', color: Colors.red, onTap: _mostrarDialogoAviso),
                  _buildActionCard(icon: Icons.how_to_reg, label: 'Solicitudes\nPendientes', color: Colors.pink, onTap: () => _navTo(const AprobacionesScreen())),
                  _buildActionCard(icon: Icons.cloud_sync, label: 'Sincronizar\nBackend', color: Colors.deepPurple, onTap: () => _navTo(const SyncScreen())),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.08),
                        color.withValues(alpha: 0.18),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoAviso() {
    final tituloCtrl = TextEditingController();
    final mensajeCtrl = TextEditingController();
    String topicSeleccionado = 'todos';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Enviar Aviso Push'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloCtrl,
                  decoration: const InputDecoration(labelText: 'Titulo'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: mensajeCtrl,
                  decoration: const InputDecoration(labelText: 'Mensaje'),
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: topicSeleccionado,
                  decoration: const InputDecoration(labelText: 'Enviar a'),
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'consejero', child: Text('Consejeros')),
                    DropdownMenuItem(value: 'aspirante', child: Text('Aspirantes')),
                    DropdownMenuItem(value: 'admin', child: Text('Admins')),
                  ],
                  onChanged: (v) => setDialogState(() => topicSeleccionado = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Enviar'),
              onPressed: () async {
                if (tituloCtrl.text.isEmpty || mensajeCtrl.text.isEmpty) return;
                Navigator.pop(ctx);
                final ok = await NotificationService().enviarPushNotification(
                  titulo: tituloCtrl.text,
                  mensaje: mensajeCtrl.text,
                  topic: topicSeleccionado,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Aviso enviado' : 'Error al enviar'),
                    backgroundColor: ok ? AppTheme.successGreen : AppTheme.errorRed,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((_) {
      if (mounted) _cargarStats();
    });
  }
}
