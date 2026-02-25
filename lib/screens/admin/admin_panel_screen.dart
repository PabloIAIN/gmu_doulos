import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../unidades/unidades_screen.dart';
import '../miembros/miembros_screen.dart';
import '../calendario/calendario_screen.dart';
import '../asistencia/asistencia_screen.dart';
import '../carpeta/carpeta_manage_screen.dart';
import '../carpeta/carpeta_approve_screen.dart';
import 'gestion_cuentas_screen.dart';

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
              // Stats rápidos
              if (!_isLoading) ...[
                Row(
                  children: [
                    _buildMiniStat('Miembros', _stats['miembros'] ?? 0,
                        Icons.people, Colors.blue),
                    const SizedBox(width: 12),
                    _buildMiniStat('Eventos', _stats['eventos'] ?? 0,
                        Icons.event, Colors.green),
                    const SizedBox(width: 12),
                    _buildMiniStat('Unidades', _stats['unidades'] ?? 0,
                        Icons.group_work, Colors.orange),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              const Text(
                'Gestion',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.people,
                    label: 'Miembros',
                    color: Colors.blue,
                    onTap: () => _navTo(const MiembrosScreen()),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.group_work,
                    label: 'Unidades',
                    color: Colors.orange,
                    onTap: () => _navTo(const UnidadesScreen()),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.calendar_month,
                    label: 'Eventos',
                    color: Colors.green,
                    onTap: () => _navTo(const CalendarioScreen()),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.fact_check,
                    label: 'Asistencia',
                    color: Colors.purple,
                    onTap: () => _navTo(const AsistenciaScreen()),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.folder_copy,
                    label: 'Gestionar\nCarpeta',
                    color: Colors.teal,
                    onTap: () => _navTo(const CarpetaManageScreen()),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.approval,
                    label: 'Aprobar\nCarpetas',
                    color: Colors.amber,
                    onTap: () => _navTo(const CarpetaApproveScreen()),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.manage_accounts,
                    label: 'Cuentas',
                    color: Colors.indigo,
                    onTap: () => _navTo(const GestionCuentasScreen()),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.campaign,
                    label: 'Enviar\nAviso',
                    color: Colors.red,
                    onTap: _mostrarDialogoAviso,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(
      String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
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
          title: const Text('Enviar Aviso Push'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Titulo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mensajeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: topicSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Enviar a',
                    border: OutlineInputBorder(),
                  ),
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
                    backgroundColor: ok ? Colors.green : Colors.red,
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
