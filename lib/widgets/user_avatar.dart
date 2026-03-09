import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Avatares predefinidos con iconos tematicos de scouts/Guias Mayores
class PredefinedAvatar {
  final String key;
  final IconData icon;
  final Color color;
  final String label;

  const PredefinedAvatar({
    required this.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  String get fotoUrlValue => 'avatar:$key';

  static const List<PredefinedAvatar> all = [
    PredefinedAvatar(key: 'shield', icon: Icons.shield, color: Color(0xFF2E7D32), label: 'Escudo'),
    PredefinedAvatar(key: 'hiking', icon: Icons.hiking, color: Color(0xFF1565C0), label: 'Excursionista'),
    PredefinedAvatar(key: 'terrain', icon: Icons.terrain, color: Color(0xFF2E7D32), label: 'Montana'),
    PredefinedAvatar(key: 'campfire', icon: Icons.local_fire_department, color: Color(0xFFE65100), label: 'Fogata'),
    PredefinedAvatar(key: 'compass', icon: Icons.explore, color: Color(0xFF00695C), label: 'Brujula'),
    PredefinedAvatar(key: 'star', icon: Icons.stars, color: Color(0xFFFFA000), label: 'Estrella'),
    PredefinedAvatar(key: 'nature', icon: Icons.park, color: Color(0xFF388E3C), label: 'Naturaleza'),
    PredefinedAvatar(key: 'eagle', icon: Icons.flight, color: Color(0xFF4527A0), label: 'Aguila'),
    PredefinedAvatar(key: 'flag', icon: Icons.flag, color: Color(0xFFC62828), label: 'Bandera'),
    PredefinedAvatar(key: 'book', icon: Icons.menu_book, color: Color(0xFF4E342E), label: 'Manual'),
    PredefinedAvatar(key: 'rope', icon: Icons.link, color: Color(0xFF795548), label: 'Nudos'),
    PredefinedAvatar(key: 'cross', icon: Icons.church, color: Color(0xFF1565C0), label: 'Fe'),
  ];

  static PredefinedAvatar? fromFotoUrl(String? fotoUrl) {
    if (fotoUrl == null || !fotoUrl.startsWith('avatar:')) return null;
    final key = fotoUrl.substring(7);
    for (final a in all) {
      if (a.key == key) return a;
    }
    return null;
  }
}

/// Widget reutilizable de avatar que maneja: foto, avatar predefinido, o iniciales
class UserAvatar extends StatelessWidget {
  final String? fotoUrl;
  final String iniciales;
  final double radius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.fotoUrl,
    required this.iniciales,
    this.radius = 30,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    final predefined = PredefinedAvatar.fromFotoUrl(fotoUrl);
    if (predefined != null) {
      // Avatar predefinido con icono
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: predefined.color,
        child: Icon(
          predefined.icon,
          size: radius * 0.9,
          color: Colors.white,
        ),
      );
    } else if (fotoUrl != null && fotoUrl!.isNotEmpty && File(fotoUrl!).existsSync()) {
      // Foto de archivo local
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(fotoUrl!)),
        backgroundColor: backgroundColor ?? Colors.grey[200],
      );
    } else {
      // Fallback: iniciales
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.white,
        child: Text(
          iniciales,
          style: TextStyle(
            fontSize: radius * 0.7,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryGreen,
          ),
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }
}
