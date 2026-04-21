import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/miembro.dart';
import '../models/club.dart';
import 'database_service.dart';
import 'api_service.dart';
import 'notification_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _db = DatabaseService();
  Miembro? _currentUser;
  Club? currentClub;
  String? clubId;

  Miembro? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String get rol => _currentUser?.rol ?? '';

  // ── Roles por ministerio ──
  bool get isDirectorGM => rol == 'Director GM' || rol == 'Director Asociado GM';
  bool get isDirectorConq => rol == 'Director Conq' || rol == 'Director Asociado Conq';
  bool get isDirectorAv => rol == 'Director Aventureros' || rol == 'Director Asociado Aventureros';

  bool get isConsejeroGM => rol == 'Consejero GM' || rol == 'Secretario GM';
  bool get isConsejeroConq => rol == 'Consejero Conq' || rol == 'Secretario Conq';
  bool get isConsejeroAv => rol == 'Consejero Aventureros';

  bool get isCoordinador => rol == 'Coordinador General';
  bool get isAspirante => ['Aspirante GM', 'Conquistador', 'Aventurero'].contains(rol);

  // ── Compatibilidad con roles legacy ──
  static const List<String> rolesAdmin = [
    'Director', 'Director Asociado', 'Secretario', 'Tesorero',
    'Director GM', 'Director Asociado GM', 'Secretario GM', 'Tesorero GM',
    'Director Conq', 'Director Asociado Conq', 'Secretario Conq',
    'Director Aventureros', 'Director Asociado Aventureros',
  ];

  static const List<String> rolesConsejero = [
    'Consejero', 'Instructor',
    'Consejero GM', 'Consejero Conq', 'Consejero Aventureros',
  ];

  bool get isAdmin =>
      _currentUser != null && (rolesAdmin.contains(rol) || isDirectorGM || isDirectorConq || isDirectorAv || isCoordinador);

  bool get isConsejero =>
      _currentUser != null && (rolesConsejero.contains(rol) || isConsejeroGM || isConsejeroConq || isConsejeroAv);

  bool get hasClub => clubId != null;
  bool get isPlanPro => currentClub?.esPro ?? false;

  String get ministerioActivo {
    if (rol.contains('GM') || rol == 'Aspirante GM') return 'gm';
    if (rol.contains('Conq') || rol == 'Conquistador') return 'conq';
    if (rol.contains('Aventureros') || rol == 'Aventurero') return 'av';
    // Roles legacy sin ministerio específico
    if (rolesAdmin.sublist(0, 4).contains(rol)) return 'gm';
    if (rolesConsejero.sublist(0, 2).contains(rol)) return 'gm';
    if (rol == 'Miembro') return 'gm';
    return 'todos'; // Coordinador General
  }

  // ── Hash ──
  String hashPassword(String plain) {
    final bytes = utf8.encode('gmu_doulos_salt_2025_$plain');
    return sha256.convert(bytes).toString();
  }

  // ── Login ──
  Future<Miembro?> login(String usuario, String password) async {
    // 1. Intentar login local (SHA-256)
    final miembroLocal = await _db.getMiembroPorUsuario(usuario);
    if (miembroLocal != null) {
      final hash = hashPassword(password);
      if (miembroLocal.passwordHash == hash) {
        _currentUser = miembroLocal;
        await _db.setConfig('session_user_id', miembroLocal.id);
        await _cargarClub();
        await _suscribirTopics();
        return miembroLocal;
      }
    }

    // 2. Intentar login contra el backend (bcrypt)
    try {
      final data = await ApiService().login(usuario, password);
      if (data != null) {
        // Guardar/actualizar miembro en BD local
        final miembro = Miembro(
          id: data['id'] as String,
          nombre: data['nombre'] as String? ?? '',
          apellido: data['apellido'] as String? ?? '',
          fechaNacimiento: DateTime.tryParse(data['fecha_nacimiento']?.toString() ?? '') ?? DateTime(2000, 1, 1),
          telefono: data['telefono'] as String? ?? '',
          email: data['email'] as String? ?? '',
          fotoUrl: data['foto_url'] as String?,
          clase: data['clase'] as String? ?? '',
          rol: data['rol'] as String? ?? 'Miembro',
          activo: true,
          fechaRegistro: DateTime.now(),
          usuario: usuario,
          passwordHash: hashPassword(password),
        );
        await _db.insertMiembro(miembro);

        // Guardar club_id si viene
        if (data['club_id'] != null) {
          await _db.setConfig('current_club_id', data['club_id'] as String);
        }

        _currentUser = miembro;
        await _db.setConfig('session_user_id', miembro.id);
        await _cargarClub();
        await _suscribirTopics();
        return miembro;
      }
    } catch (_) {
      // Sin internet o error de API, solo falla silenciosamente
    }

    return null;
  }

  // ── Logout ──
  Future<void> logout() async {
    await _desuscribirTopics();
    _currentUser = null;
    currentClub = null;
    clubId = null;
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
    await _cargarClub();
    await _suscribirTopics();
    return true;
  }

  // ── Cargar club del usuario ──
  Future<void> _cargarClub() async {
    // Intentar cargar club_id guardado
    clubId = await _db.getConfig('current_club_id');
    if (clubId != null && clubId!.isNotEmpty) {
      try {
        final clubData = await _db.getClub(clubId!);
        if (clubData != null) {
          currentClub = Club.fromMap(clubData);
        }
      } catch (_) {}
    }
    // Fallback al club por defecto
    if (currentClub == null) {
      clubId = 'doulos-montemorelos';
      await _db.setConfig('current_club_id', clubId!);
    }
  }

  // ── Establecer club actual ──
  Future<void> setClub(Club club) async {
    currentClub = club;
    clubId = club.id;
    await _db.setConfig('current_club_id', club.id);
    // Guardar club en BD local
    await _db.insertClub(club.toMap());
  }

  // ── FCM Topics ──
  Future<void> _suscribirTopics() async {
    if (_currentUser == null) return;
    final ns = NotificationService();
    await ns.suscribirseATopic('todos');
    if (isAdmin) {
      await ns.suscribirseATopic('admin');
    } else if (isConsejero) {
      await ns.suscribirseATopic('consejero');
    } else if (isAspirante) {
      await ns.suscribirseATopic('aspirante');
    }
  }

  Future<void> _desuscribirTopics() async {
    final ns = NotificationService();
    await ns.desuscribirseDeTopic('todos');
    await ns.desuscribirseDeTopic('admin');
    await ns.desuscribirseDeTopic('consejero');
    await ns.desuscribirseDeTopic('aspirante');
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

    // Asignar club por defecto
    clubId = 'doulos-montemorelos';
    await _db.setConfig('current_club_id', clubId!);

    await _suscribirTopics();
    return miembro;
  }

  // ── Refrescar usuario actual ──
  Future<void> refreshCurrentUser() async {
    if (_currentUser == null) return;
    final updated = await _db.getMiembro(_currentUser!.id);
    if (updated != null) _currentUser = updated;
  }
}
