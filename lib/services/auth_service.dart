import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/miembro.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _db = DatabaseService();
  Miembro? _currentUser;

  Miembro? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ── Roles ──
  static const List<String> rolesAdmin = [
    'Director',
    'Director Asociado',
    'Secretario',
    'Tesorero',
  ];

  static const List<String> rolesConsejero = [
    'Consejero',
    'Instructor',
  ];

  bool get isAdmin =>
      _currentUser != null && rolesAdmin.contains(_currentUser!.rol);

  bool get isConsejero =>
      _currentUser != null && rolesConsejero.contains(_currentUser!.rol);

  bool get isAspirante =>
      _currentUser != null && _currentUser!.rol == 'Miembro';

  // ── Hash ──
  String hashPassword(String plain) {
    final bytes = utf8.encode('gmu_doulos_salt_2025_$plain');
    return sha256.convert(bytes).toString();
  }

  // ── Login ──
  Future<Miembro?> login(String usuario, String password) async {
    final miembro = await _db.getMiembroPorUsuario(usuario);
    if (miembro == null) return null;

    final hash = hashPassword(password);
    if (miembro.passwordHash != hash) return null;

    _currentUser = miembro;
    await _db.setConfig('session_user_id', miembro.id);
    return miembro;
  }

  // ── Logout ──
  Future<void> logout() async {
    _currentUser = null;
    await _db.setConfig('session_user_id', '');
  }

  // ── Restaurar sesión ──
  Future<bool> tryRestoreSession() async {
    final userId = await _db.getConfig('session_user_id');
    if (userId == null || userId.isEmpty) return false;

    final miembro = await _db.getMiembro(userId);
    if (miembro == null || miembro.passwordHash == null) {
      await _db.setConfig('session_user_id', '');
      return false;
    }

    _currentUser = miembro;
    return true;
  }

  // ── Primera ejecución ──
  Future<bool> isFirstRun() async {
    final db = await _db.database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM miembros WHERE usuario IS NOT NULL');
    return (result.first['count'] as int) == 0;
  }

  // ── Crear cuenta admin inicial ──
  Future<Miembro> crearAdminInicial({
    required String nombre,
    required String apellido,
    required String usuario,
    required String password,
  }) async {
    final hash = hashPassword(password);
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final miembro = Miembro(
      id: id,
      nombre: nombre,
      apellido: apellido,
      fechaNacimiento: DateTime(1990, 1, 1),
      telefono: '',
      email: '',
      clase: 'Guía Mayor Avanzado',
      rol: 'Director',
      activo: true,
      fechaRegistro: DateTime.now(),
      usuario: usuario,
      passwordHash: hash,
    );

    await _db.insertMiembro(miembro);
    _currentUser = miembro;
    await _db.setConfig('session_user_id', miembro.id);
    return miembro;
  }

  // ── Refrescar usuario actual ──
  Future<void> refreshCurrentUser() async {
    if (_currentUser == null) return;
    final updated = await _db.getMiembro(_currentUser!.id);
    if (updated != null) _currentUser = updated;
  }
}
