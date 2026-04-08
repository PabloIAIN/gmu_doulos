import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

/// Widget reutilizable con botones de contacto rapido (llamar, WhatsApp, email).
class ContactoRapido extends StatelessWidget {
  final String? telefono;
  final String? email;
  final String? nombre;

  const ContactoRapido({
    super.key,
    this.telefono,
    this.email,
    this.nombre,
  });

  Future<void> _launch(BuildContext context, Uri uri, String error) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppTheme.errorRed),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  String _limpiarTelefono(String tel) {
    return tel.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  void _llamar(BuildContext context) {
    if (telefono == null || telefono!.isEmpty) return;
    _launch(context, Uri(scheme: 'tel', path: _limpiarTelefono(telefono!)), 'No se pudo abrir el marcador');
  }

  void _whatsapp(BuildContext context) {
    if (telefono == null || telefono!.isEmpty) return;
    final tel = _limpiarTelefono(telefono!).replaceAll('+', '');
    final mensaje = nombre != null ? Uri.encodeComponent('Hola $nombre,') : '';
    _launch(context, Uri.parse('https://wa.me/$tel?text=$mensaje'), 'No se pudo abrir WhatsApp');
  }

  void _email(BuildContext context) {
    if (email == null || email!.isEmpty) return;
    _launch(context, Uri(scheme: 'mailto', path: email), 'No se pudo abrir el correo');
  }

  @override
  Widget build(BuildContext context) {
    final tienePhone = telefono != null && telefono!.isNotEmpty;
    final tieneEmail = email != null && email!.isNotEmpty;
    if (!tienePhone && !tieneEmail) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (tienePhone)
            _BotonContacto(
              icon: Icons.phone,
              label: 'Llamar',
              color: AppTheme.successGreen,
              onTap: () => _llamar(context),
            ),
          if (tienePhone)
            _BotonContacto(
              icon: Icons.chat,
              label: 'WhatsApp',
              color: const Color(0xFF25D366),
              onTap: () => _whatsapp(context),
            ),
          if (tieneEmail)
            _BotonContacto(
              icon: Icons.mail_outline,
              label: 'Email',
              color: AppTheme.infoBlue,
              onTap: () => _email(context),
            ),
        ],
      ),
    );
  }
}

class _BotonContacto extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BotonContacto({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
