import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final club = auth.currentClub;
    final planActual = club?.plan ?? 'gratis';
    final esPro = planActual == 'pro';
    final maxMiembros = club?.maxMiembros ?? 20;

    return Scaffold(
      appBar: AppBar(title: const Text('Plan del Club')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Plan actual
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: esPro
                      ? [const Color(0xFFFFC107), const Color(0xFFFF8F00)]
                      : [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(esPro ? Icons.workspace_premium : Icons.shield, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    esPro ? 'Plan Pro' : 'Plan Gratuito',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    esPro ? 'Miembros ilimitados' : 'Hasta $maxMiembros miembros',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tabla comparativa
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildRow(context, 'Característica', 'Gratis', 'Pro', isHeader: true),
                  _buildRow(context, 'Miembros', '20', 'Ilimitado'),
                  _buildRow(context, 'Asistencia', '✓', '✓'),
                  _buildRow(context, 'Calendario', '✓', '✓'),
                  _buildRow(context, 'Carpeta', '✓', '✓'),
                  _buildRow(context, 'Reportes PDF', '—', '✓'),
                  _buildRow(context, 'Estadísticas', '—', '✓'),
                  _buildRow(context, 'Importar Google Sheets', '—', '✓'),
                  _buildRow(context, 'Soporte prioritario', '—', '✓'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!esPro)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Actualizar a Pro'),
                        content: const Text(
                          'Para actualizar tu club al Plan Pro, contacta al administrador de GMU Doulos.\n\n'
                          'El Plan Pro incluye miembros ilimitados, reportes PDF, estadísticas avanzadas y más.',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido')),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.workspace_premium),
                  label: const Text('Actualizar a Pro'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String feature, String gratis, String pro, {bool isHeader = false}) {
    final style = isHeader
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
        : TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface);
    final bg = isHeader ? AppTheme.primaryGreen.withValues(alpha: 0.06) : null;

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(feature, style: style)),
          Expanded(flex: 2, child: Text(gratis, style: style, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(pro, style: style.copyWith(color: isHeader ? null : const Color(0xFFFF8F00), fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
