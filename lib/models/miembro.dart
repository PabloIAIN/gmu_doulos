class Miembro {
  final String id;
  final String nombre;
  final String apellido;
  final DateTime fechaNacimiento;
  final String telefono;
  final String email;
  final String? fotoUrl;
  final String clase;
  final String rol;
  final bool activo;
  final DateTime? fechaRegistro;
  final String? usuario;
  final String? passwordHash;

  Miembro({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.fechaNacimiento,
    required this.telefono,
    required this.email,
    this.fotoUrl,
    required this.clase,
    required this.rol,
    this.activo = true,
    this.fechaRegistro,
    this.usuario,
    this.passwordHash,
  });

  String get nombreCompleto => '$nombre $apellido';

  String get iniciales {
    final partes = nombreCompleto.split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre[0].toUpperCase();
  }

  int get edad {
    final now = DateTime.now();
    int age = now.year - fechaNacimiento.year;
    if (now.month < fechaNacimiento.month ||
        (now.month == fechaNacimiento.month && now.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }

  bool get tieneCuenta => usuario != null && usuario!.isNotEmpty;

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'telefono': telefono,
      'email': email,
      'foto_url': fotoUrl,
      'clase': clase,
      'rol': rol,
      'activo': activo ? 1 : 0,
      'fecha_registro': (fechaRegistro ?? DateTime.now()).toIso8601String(),
      'usuario': usuario,
      'password_hash': passwordHash,
    };
  }

  // Crear desde Map de SQLite
  factory Miembro.fromMap(Map<String, dynamic> map) {
    return Miembro(
      id: map['id'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      fechaNacimiento: DateTime.parse(map['fecha_nacimiento']),
      telefono: map['telefono'] ?? '',
      email: map['email'] ?? '',
      fotoUrl: map['foto_url'],
      clase: map['clase'],
      rol: map['rol'],
      activo: map['activo'] == 1,
      fechaRegistro: map['fecha_registro'] != null
          ? DateTime.parse(map['fecha_registro'])
          : null,
      usuario: map['usuario'],
      passwordHash: map['password_hash'],
    );
  }

  // Copiar con modificaciones
  Miembro copyWith({
    String? id,
    String? nombre,
    String? apellido,
    DateTime? fechaNacimiento,
    String? telefono,
    String? email,
    String? fotoUrl,
    String? clase,
    String? rol,
    bool? activo,
    DateTime? fechaRegistro,
    String? usuario,
    String? passwordHash,
  }) {
    return Miembro(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      clase: clase ?? this.clase,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      usuario: usuario ?? this.usuario,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }
}

// Clases y roles disponibles para Guías Mayores
class ClasesGuiasMayores {
  static const List<String> clases = [
    'Guía Mayor Aspirante',
    'Guía Mayor',
    'Guía Mayor Avanzado',
  ];

  static const List<String> roles = [
    'Miembro',
    'Consejero',
    'Instructor',
    'Director',
    'Director Asociado',
    'Secretario',
    'Tesorero',
  ];

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

  static bool isAdminRole(String rol) => rolesAdmin.contains(rol);
  static bool isConsejeroRole(String rol) => rolesConsejero.contains(rol);
  static bool isAspiranteRole(String rol) => rol == 'Miembro';
}
