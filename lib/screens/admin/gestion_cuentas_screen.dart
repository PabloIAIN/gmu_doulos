import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/miembro.dart';
import '../../theme/app_theme.dart';

class GestionCuentasScreen extends StatefulWidget {
  const GestionCuentasScreen({super.key});

  @override
  State<GestionCuentasScreen> createState() => _GestionCuentasScreenState();
}

class _GestionCuentasScreenState extends State<GestionCuentasScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  List<Miembro> _miembros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    try {
      final miembros = await _db.getMiembros();
      setState(() {
        _miembros = miembros;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _crearCuenta(Miembro miembro) {
    final usuarioCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Crear cuenta: ${miembro.nombreCompleto}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usuarioCtrl,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(
                labelText: 'Contrasena',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final usuario = usuarioCtrl.text.trim();
              final password = passwordCtrl.text;

              if (usuario.isEmpty || password.length < 4) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Usuario requerido y contrasena min 4 caracteres')),
                );
                return;
              }

              final hash = _auth.hashPassword(password);
              await _db.setCredenciales(miembro.id, usuario, hash);

              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              _cargar();

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Cuenta creada para ${miembro.nombreCompleto}'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _resetearContrasena(Miembro miembro) {
    final passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resetear Contrasena'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Miembro: ${miembro.nombreCompleto}'),
            const SizedBox(height: 12),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(
                labelText: 'Nueva contrasena',
                prefixIcon: Icon(Icons.lock_reset),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final password = passwordCtrl.text;
              if (password.length < 4) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                      content: Text('Contrasena min 4 caracteres')),
                );
                return;
              }

              final hash = _auth.hashPassword(password);
              await _db.setCredenciales(miembro.id, miembro.usuario!, hash);

              if (!ctx.mounted) return;
              Navigator.pop(ctx);

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contrasena reseteada'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Resetear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion de Cuentas')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _miembros.length,
                itemBuilder: (ctx, i) {
                  final m = _miembros[i];
                  final tieneCuenta = m.tieneCuenta;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: tieneCuenta
                            ? AppTheme.successGreen.withValues(alpha:0.1)
                            : Colors.grey[200],
                        child: Icon(
                          tieneCuenta
                              ? Icons.person
                              : Icons.person_outline,
                          color: tieneCuenta
                              ? AppTheme.successGreen
                              : Colors.grey,
                        ),
                      ),
                      title: Text(m.nombreCompleto,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        tieneCuenta
                            ? 'Usuario: ${m.usuario} - ${m.rol}'
                            : 'Sin cuenta - ${m.rol}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: tieneCuenta
                          ? PopupMenuButton<String>(
                              onSelected: (action) {
                                if (action == 'reset') {
                                  _resetearContrasena(m);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'reset',
                                  child: Row(
                                    children: [
                                      Icon(Icons.lock_reset, size: 18),
                                      SizedBox(width: 8),
                                      Text('Resetear contrasena'),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : TextButton(
                              onPressed: () => _crearCuenta(m),
                              child: const Text('Crear cuenta'),
                            ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
