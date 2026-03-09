import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../models/miembro.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/user_avatar.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();
  final ImagePicker _picker = ImagePicker();
  bool _isUpdating = false;

  Miembro? get _user => _auth.currentUser;

  Future<void> _savePhotoUrl(String? newFotoUrl, {bool clear = false}) async {
    if (_user == null) return;
    setState(() => _isUpdating = true);
    try {
      final updated = _user!.copyWith(
        fotoUrl: newFotoUrl,
        clearFotoUrl: clear,
      );
      await _db.updateMiembro(updated);
      await _auth.refreshCurrentUser();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar foto: $e')),
        );
      }
    }
    if (mounted) setState(() => _isUpdating = false);
  }

  Future<String?> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return null;

      // Copiar a directorio de la app
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDir.path}/profile_photos');
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }
      final ext = p.extension(image.path);
      final fileName = '${_user!.id}_${DateTime.now().millisecondsSinceEpoch}$ext';
      final newFile = await File(image.path).copy('${profileDir.path}/$fileName');
      return newFile.path;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener imagen: $e')),
        );
      }
      return null;
    }
  }

  void _showChangePhotoSheet() {
    final hasFoto = _user?.fotoUrl != null && _user!.fotoUrl!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cambiar foto de perfil',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.blue),
                ),
                title: const Text('Tomar foto'),
                subtitle: const Text('Usar la camara'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final path = await _pickImage(ImageSource.camera);
                  if (path != null) await _savePhotoUrl(path);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Colors.green),
                ),
                title: const Text('Elegir de galeria'),
                subtitle: const Text('Seleccionar una foto existente'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final path = await _pickImage(ImageSource.gallery);
                  if (path != null) await _savePhotoUrl(path);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.emoji_emotions_rounded, color: Colors.orange),
                ),
                title: const Text('Elegir avatar'),
                subtitle: const Text('Avatares tematicos de scouts'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAvatarPicker();
                },
              ),
              if (hasFoto)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_rounded, color: Colors.red),
                  ),
                  title: const Text('Quitar foto'),
                  subtitle: const Text('Volver a iniciales'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _savePhotoUrl(null, clear: true);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    final currentFotoUrl = _user?.fotoUrl;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Elegir avatar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: PredefinedAvatar.all.length,
            itemBuilder: (ctx, i) {
              final avatar = PredefinedAvatar.all[i];
              final isSelected = currentFotoUrl == avatar.fotoUrlValue;

              return GestureDetector(
                onTap: () async {
                  Navigator.pop(ctx);
                  await _savePhotoUrl(avatar.fotoUrlValue);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: AppTheme.primaryGreen, width: 3)
                            : null,
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: avatar.color,
                        child: Icon(avatar.icon, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      avatar.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppTheme.primaryGreen : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No hay usuario activo')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Header con avatar ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryGreenDark,
                    AppTheme.primaryGreen,
                    Color(0xFF43A047),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Circulos decorativos
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -10,
                    bottom: -10,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                  ),
                  // Contenido
                  Column(
                    children: [
                      // Avatar con badge de camara
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 3,
                              ),
                            ),
                            child: _isUpdating
                                ? CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                                    child: const CircularProgressIndicator(color: Colors.white),
                                  )
                                : UserAvatar(
                                    fotoUrl: user.fotoUrl,
                                    iniciales: user.iniciales,
                                    radius: 50,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isUpdating ? null : _showChangePhotoSheet,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 20,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.nombreCompleto,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Badges de rol y clase
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBadge(user.rol, Colors.white.withValues(alpha: 0.2)),
                          const SizedBox(width: 8),
                          _buildBadge(user.clase, Colors.white.withValues(alpha: 0.15)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Boton cambiar foto
                      OutlinedButton.icon(
                        onPressed: _isUpdating ? null : _showChangePhotoSheet,
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Cambiar foto'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Informacion personal ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informacion Personal',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.person_rounded, 'Nombre', user.nombreCompleto),
                  _buildInfoRow(Icons.email_rounded, 'Email', user.email.isNotEmpty ? user.email : 'No registrado'),
                  _buildInfoRow(Icons.phone_rounded, 'Telefono', user.telefono.isNotEmpty ? user.telefono : 'No registrado'),
                  _buildInfoRow(Icons.cake_rounded, 'Fecha de nacimiento',
                      '${user.fechaNacimiento.day}/${user.fechaNacimiento.month}/${user.fechaNacimiento.year} (${user.edad} anos)'),
                  _buildInfoRow(Icons.school_rounded, 'Clase', user.clase),
                  _buildInfoRow(Icons.badge_rounded, 'Rol', user.rol),
                  if (user.fechaRegistro != null)
                    _buildInfoRow(Icons.calendar_today_rounded, 'Miembro desde',
                        '${user.fechaRegistro!.day}/${user.fechaRegistro!.month}/${user.fechaRegistro!.year}'),
                  if (user.tieneCuenta)
                    _buildInfoRow(Icons.account_circle_rounded, 'Usuario', user.usuario ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.95),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
