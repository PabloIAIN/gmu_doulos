import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/miembro.dart';
import '../models/evento.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'gmu_doulos.db');
    return await openDatabase(
      path,
      version: 8,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de miembros (con campos auth)
    await db.execute('''
      CREATE TABLE miembros(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        apellido TEXT NOT NULL,
        fecha_nacimiento TEXT NOT NULL,
        telefono TEXT,
        email TEXT,
        foto_url TEXT,
        clase TEXT NOT NULL,
        rol TEXT NOT NULL,
        activo INTEGER DEFAULT 1,
        fecha_registro TEXT,
        usuario TEXT,
        password_hash TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE eventos(
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        fecha TEXT NOT NULL,
        hora TEXT,
        ubicacion TEXT,
        tipo TEXT NOT NULL,
        latitud REAL,
        longitud REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE asistencia(
        id TEXT PRIMARY KEY,
        unidad_id TEXT NOT NULL,
        miembro_id TEXT NOT NULL,
        fecha TEXT NOT NULL,
        dia_semana TEXT NOT NULL,
        puntualidad TEXT NOT NULL DEFAULT 'ausente',
        panoleta INTEGER DEFAULT 0,
        biblia INTEGER DEFAULT 0,
        cuota INTEGER DEFAULT 0,
        registrado_por TEXT,
        fecha_registro TEXT,
        FOREIGN KEY (unidad_id) REFERENCES unidades(id),
        FOREIGN KEY (miembro_id) REFERENCES miembros(id)
      )
    ''');

    await db.execute(
      'CREATE UNIQUE INDEX idx_asistencia_unique ON asistencia(unidad_id, miembro_id, fecha)'
    );

    await db.execute('''
      CREATE TABLE especialidades(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        categoria TEXT NOT NULL,
        nivel TEXT,
        requisitos INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE evidencias(
        id TEXT PRIMARY KEY,
        titulo TEXT,
        descripcion TEXT,
        categoria TEXT NOT NULL,
        foto_path TEXT NOT NULL,
        fecha TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE configuracion(
        clave TEXT PRIMARY KEY,
        valor TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ubicaciones(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        categoria TEXT NOT NULL,
        latitud REAL,
        longitud REAL,
        fecha TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notificaciones(
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        mensaje TEXT,
        tipo TEXT NOT NULL,
        fecha_programada TEXT NOT NULL,
        evento_id TEXT,
        leida INTEGER DEFAULT 0,
        enviada INTEGER DEFAULT 0,
        fecha_creacion TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE miembro_especialidad(
        id TEXT PRIMARY KEY,
        miembro_id TEXT NOT NULL,
        especialidad_id TEXT NOT NULL,
        fecha_inicio TEXT,
        fecha_completado TEXT,
        requisitos_completados INTEGER DEFAULT 0,
        completado INTEGER DEFAULT 0,
        FOREIGN KEY (miembro_id) REFERENCES miembros (id),
        FOREIGN KEY (especialidad_id) REFERENCES especialidades (id)
      )
    ''');

    // ── Tablas v6: Unidades ──
    await db.execute('''
      CREATE TABLE unidades(
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        activo INTEGER DEFAULT 1,
        fecha_creacion TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE unidad_miembros(
        id TEXT PRIMARY KEY,
        unidad_id TEXT NOT NULL,
        miembro_id TEXT NOT NULL,
        rol_en_unidad TEXT NOT NULL,
        fecha_asignacion TEXT NOT NULL,
        FOREIGN KEY (unidad_id) REFERENCES unidades(id),
        FOREIGN KEY (miembro_id) REFERENCES miembros(id)
      )
    ''');

    // ── Tablas v6: Carpeta de Investidura ──
    await db.execute('''
      CREATE TABLE carpeta_secciones(
        id TEXT PRIMARY KEY,
        numero INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        descripcion TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE carpeta_requisitos(
        id TEXT PRIMARY KEY,
        seccion_id TEXT NOT NULL,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        orden INTEGER NOT NULL,
        FOREIGN KEY (seccion_id) REFERENCES carpeta_secciones(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE carpeta_progreso(
        id TEXT PRIMARY KEY,
        miembro_id TEXT NOT NULL,
        requisito_id TEXT NOT NULL,
        completado INTEGER DEFAULT 0,
        fecha_completado TEXT,
        completado_por TEXT,
        aprobado INTEGER DEFAULT 0,
        fecha_aprobado TEXT,
        aprobado_por TEXT,
        notas TEXT,
        evidencia_path TEXT,
        estado TEXT DEFAULT 'pendiente',
        comentario_devolucion TEXT,
        fecha_envio TEXT,
        FOREIGN KEY (miembro_id) REFERENCES miembros(id),
        FOREIGN KEY (requisito_id) REFERENCES carpeta_requisitos(id)
      )
    ''');

    await _insertarDatosEjemplo(db);
    await _insertarDatosCarpeta(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS evidencias(
          id TEXT PRIMARY KEY, titulo TEXT, descripcion TEXT,
          categoria TEXT NOT NULL, foto_path TEXT NOT NULL, fecha TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS configuracion(
          clave TEXT PRIMARY KEY, valor TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ubicaciones(
          id TEXT PRIMARY KEY, nombre TEXT NOT NULL, descripcion TEXT,
          categoria TEXT NOT NULL, latitud REAL, longitud REAL, fecha TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notificaciones(
          id TEXT PRIMARY KEY, titulo TEXT NOT NULL, mensaje TEXT,
          tipo TEXT NOT NULL, fecha_programada TEXT NOT NULL, evento_id TEXT,
          leida INTEGER DEFAULT 0, enviada INTEGER DEFAULT 0, fecha_creacion TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 6) {
      // Columnas auth en miembros
      await db.execute('ALTER TABLE miembros ADD COLUMN usuario TEXT');
      await db.execute('ALTER TABLE miembros ADD COLUMN password_hash TEXT');

      // Unidades
      await db.execute('''
        CREATE TABLE IF NOT EXISTS unidades(
          id TEXT PRIMARY KEY, nombre TEXT NOT NULL, descripcion TEXT,
          activo INTEGER DEFAULT 1, fecha_creacion TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS unidad_miembros(
          id TEXT PRIMARY KEY, unidad_id TEXT NOT NULL, miembro_id TEXT NOT NULL,
          rol_en_unidad TEXT NOT NULL, fecha_asignacion TEXT NOT NULL,
          FOREIGN KEY (unidad_id) REFERENCES unidades(id),
          FOREIGN KEY (miembro_id) REFERENCES miembros(id)
        )
      ''');

      // Carpeta de Investidura
      await db.execute('''
        CREATE TABLE IF NOT EXISTS carpeta_secciones(
          id TEXT PRIMARY KEY, numero INTEGER NOT NULL, nombre TEXT NOT NULL, descripcion TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS carpeta_requisitos(
          id TEXT PRIMARY KEY, seccion_id TEXT NOT NULL, nombre TEXT NOT NULL,
          descripcion TEXT, orden INTEGER NOT NULL,
          FOREIGN KEY (seccion_id) REFERENCES carpeta_secciones(id)
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS carpeta_progreso(
          id TEXT PRIMARY KEY, miembro_id TEXT NOT NULL, requisito_id TEXT NOT NULL,
          completado INTEGER DEFAULT 0, fecha_completado TEXT, completado_por TEXT,
          aprobado INTEGER DEFAULT 0, fecha_aprobado TEXT, aprobado_por TEXT,
          notas TEXT, evidencia_path TEXT,
          FOREIGN KEY (miembro_id) REFERENCES miembros(id),
          FOREIGN KEY (requisito_id) REFERENCES carpeta_requisitos(id)
        )
      ''');

      await _insertarDatosCarpeta(db);
    }
    if (oldVersion < 7) {
      await db.execute("ALTER TABLE carpeta_progreso ADD COLUMN estado TEXT DEFAULT 'pendiente'");
      await db.execute('ALTER TABLE carpeta_progreso ADD COLUMN comentario_devolucion TEXT');
      await db.execute('ALTER TABLE carpeta_progreso ADD COLUMN fecha_envio TEXT');
      // Migrar datos existentes
      await db.execute("UPDATE carpeta_progreso SET estado = 'aprobado' WHERE completado = 1 AND aprobado = 1");
      await db.execute("UPDATE carpeta_progreso SET estado = 'preaprobado' WHERE completado = 1 AND aprobado = 0");
    }
    if (oldVersion < 8) {
      // Migrar tabla asistencia: de evento-based a unidad+fecha-based
      await db.execute('ALTER TABLE asistencia RENAME TO asistencia_old');

      await db.execute('''
        CREATE TABLE asistencia(
          id TEXT PRIMARY KEY,
          unidad_id TEXT NOT NULL,
          miembro_id TEXT NOT NULL,
          fecha TEXT NOT NULL,
          dia_semana TEXT NOT NULL,
          puntualidad TEXT NOT NULL DEFAULT 'ausente',
          panoleta INTEGER DEFAULT 0,
          biblia INTEGER DEFAULT 0,
          cuota INTEGER DEFAULT 0,
          registrado_por TEXT,
          fecha_registro TEXT,
          FOREIGN KEY (unidad_id) REFERENCES unidades(id),
          FOREIGN KEY (miembro_id) REFERENCES miembros(id)
        )
      ''');

      await db.execute(
        'CREATE UNIQUE INDEX idx_asistencia_unique ON asistencia(unidad_id, miembro_id, fecha)'
      );

      // Migrar datos existentes con best-effort
      await db.execute('''
        INSERT OR IGNORE INTO asistencia (id, unidad_id, miembro_id, fecha, dia_semana, puntualidad, panoleta, biblia, cuota, fecha_registro)
        SELECT
          um.unidad_id || '_' || ao.miembro_id || '_' || substr(ao.fecha, 1, 10),
          um.unidad_id,
          ao.miembro_id,
          substr(ao.fecha, 1, 10),
          'sabado',
          CASE WHEN ao.presente = 1 THEN 'presente' ELSE 'ausente' END,
          0, 0, 0,
          ao.fecha
        FROM asistencia_old ao
        JOIN unidad_miembros um ON ao.miembro_id = um.miembro_id
      ''');

      await db.execute('DROP TABLE IF EXISTS asistencia_old');
    }
  }

  // ─── Seed Data ───

  Future<void> _insertarDatosEjemplo(Database db) async {
    // Hash SHA-256 de "gmu_doulos_salt_2025_1234" = contraseña "1234" para todos
    const hash1234 = 'ee2330ae4474eb97f01a06ee56f302d4db561fc0615b4e2329b73c256a403c24';
    final now = DateTime.now().toIso8601String();

    // ── 10 Miembros con cuentas ──
    final miembros = [
      {'id': '1', 'nombre': 'Juan', 'apellido': 'Pérez García', 'fecha_nacimiento': '2005-05-15', 'telefono': '8121234567', 'email': 'juan@email.com', 'clase': 'Guía Mayor Aspirante', 'rol': 'Miembro', 'activo': 1, 'fecha_registro': now, 'usuario': 'juan', 'password_hash': hash1234},
      {'id': '2', 'nombre': 'María', 'apellido': 'López Hernández', 'fecha_nacimiento': '2004-08-22', 'telefono': '8127654321', 'email': 'maria@email.com', 'clase': 'Guía Mayor Aspirante', 'rol': 'Miembro', 'activo': 1, 'fecha_registro': now, 'usuario': 'maria', 'password_hash': hash1234},
      {'id': '3', 'nombre': 'Carlos', 'apellido': 'Martínez Ruiz', 'fecha_nacimiento': '2006-02-10', 'telefono': '8129876543', 'email': 'carlos@email.com', 'clase': 'Guía Mayor Aspirante', 'rol': 'Miembro', 'activo': 1, 'fecha_registro': now, 'usuario': 'carlos', 'password_hash': hash1234},
      {'id': '4', 'nombre': 'Ana', 'apellido': 'González Soto', 'fecha_nacimiento': '1995-11-08', 'telefono': '8125551234', 'email': 'ana@email.com', 'clase': 'Guía Mayor Avanzado', 'rol': 'Consejero', 'activo': 1, 'fecha_registro': now, 'usuario': 'ana', 'password_hash': hash1234},
      {'id': '5', 'nombre': 'Roberto', 'apellido': 'Sánchez Villa', 'fecha_nacimiento': '1990-03-25', 'telefono': '8124445678', 'email': 'roberto@email.com', 'clase': 'Guía Mayor Avanzado', 'rol': 'Director', 'activo': 1, 'fecha_registro': now, 'usuario': 'roberto', 'password_hash': hash1234},
      {'id': '6', 'nombre': 'Luis', 'apellido': 'Torres Mendoza', 'fecha_nacimiento': '1993-07-12', 'telefono': '8126667890', 'email': 'luis@email.com', 'clase': 'Guía Mayor Avanzado', 'rol': 'Instructor', 'activo': 1, 'fecha_registro': now, 'usuario': 'luis', 'password_hash': hash1234},
      {'id': '7', 'nombre': 'Sofía', 'apellido': 'Ramírez Díaz', 'fecha_nacimiento': '2005-09-03', 'telefono': '8127778901', 'email': 'sofia@email.com', 'clase': 'Guía Mayor Aspirante', 'rol': 'Miembro', 'activo': 1, 'fecha_registro': now, 'usuario': 'sofia', 'password_hash': hash1234},
      {'id': '8', 'nombre': 'Daniel', 'apellido': 'Flores Castro', 'fecha_nacimiento': '2006-01-20', 'telefono': '8128889012', 'email': 'daniel@email.com', 'clase': 'Guía Mayor Aspirante', 'rol': 'Miembro', 'activo': 1, 'fecha_registro': now, 'usuario': 'daniel', 'password_hash': hash1234},
      {'id': '9', 'nombre': 'Elena', 'apellido': 'Cruz Moreno', 'fecha_nacimiento': '1992-04-18', 'telefono': '8129990123', 'email': 'elena@email.com', 'clase': 'Guía Mayor Avanzado', 'rol': 'Secretario', 'activo': 1, 'fecha_registro': now, 'usuario': 'elena', 'password_hash': hash1234},
      {'id': '10', 'nombre': 'Pedro', 'apellido': 'Morales Ríos', 'fecha_nacimiento': '2005-12-05', 'telefono': '8120001234', 'email': 'pedro@email.com', 'clase': 'Guía Mayor Aspirante', 'rol': 'Miembro', 'activo': 1, 'fecha_registro': now, 'usuario': 'pedro', 'password_hash': hash1234},
    ];
    for (var m in miembros) {
      await db.insert('miembros', m);
    }

    // ── 5 Eventos ──
    final eventos = [
      {'id': '1', 'titulo': 'Reunión Semanal', 'descripcion': 'Reunión regular del club', 'fecha': DateTime.now().add(const Duration(days: 2)).toIso8601String(), 'hora': '8:00 AM', 'ubicacion': 'Iglesia Central', 'tipo': 'reunion'},
      {'id': '2', 'titulo': 'Campamento Regional', 'descripcion': 'Campamento de verano en el Parque Nacional', 'fecha': DateTime.now().add(const Duration(days: 15)).toIso8601String(), 'hora': '6:00 AM', 'ubicacion': 'Parque Nacional Cumbres', 'tipo': 'campamento'},
      {'id': '3', 'titulo': 'Clase de Especialidad: Nudos', 'descripcion': 'Aprender diferentes tipos de nudos', 'fecha': DateTime.now().add(const Duration(days: 5)).toIso8601String(), 'hora': '3:00 PM', 'ubicacion': 'Salón de actividades', 'tipo': 'clase'},
      {'id': '4', 'titulo': 'Servicio Comunitario', 'descripcion': 'Limpieza del parque local', 'fecha': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(), 'hora': '9:00 AM', 'ubicacion': 'Parque Municipal', 'tipo': 'servicio'},
      {'id': '5', 'titulo': 'Ceremonia de Investidura', 'descripcion': 'Ceremonia trimestral', 'fecha': DateTime.now().add(const Duration(days: 30)).toIso8601String(), 'hora': '10:00 AM', 'ubicacion': 'Iglesia Central', 'tipo': 'ceremonia'},
    ];
    for (var e in eventos) {
      await db.insert('eventos', e);
    }

    // ── Asistencia (nuevo formato: por unidad y fecha) ──
    // Encontrar sábado pasado
    var pastSat = DateTime.now();
    while (pastSat.weekday != DateTime.saturday) {
      pastSat = pastSat.subtract(const Duration(days: 1));
    }
    final pastSatStr = pastSat.toIso8601String().substring(0, 10);
    final pastSunStr = pastSat.add(const Duration(days: 1)).toIso8601String().substring(0, 10);

    // Unidad Alfa - sábado
    final asistenciaAlfaSab = [
      {'id': 'u1_1_$pastSatStr', 'unidad_id': 'u1', 'miembro_id': '1', 'fecha': pastSatStr, 'dia_semana': 'sabado', 'puntualidad': 'presente', 'panoleta': 1, 'biblia': 1, 'cuota': 0, 'registrado_por': '4', 'fecha_registro': now},
      {'id': 'u1_2_$pastSatStr', 'unidad_id': 'u1', 'miembro_id': '2', 'fecha': pastSatStr, 'dia_semana': 'sabado', 'puntualidad': 'presente', 'panoleta': 1, 'biblia': 0, 'cuota': 0, 'registrado_por': '4', 'fecha_registro': now},
      {'id': 'u1_3_$pastSatStr', 'unidad_id': 'u1', 'miembro_id': '3', 'fecha': pastSatStr, 'dia_semana': 'sabado', 'puntualidad': 'ausente', 'panoleta': 0, 'biblia': 0, 'cuota': 0, 'registrado_por': '4', 'fecha_registro': now},
      {'id': 'u1_7_$pastSatStr', 'unidad_id': 'u1', 'miembro_id': '7', 'fecha': pastSatStr, 'dia_semana': 'sabado', 'puntualidad': 'tardanza', 'panoleta': 1, 'biblia': 1, 'cuota': 0, 'registrado_por': '4', 'fecha_registro': now},
    ];

    // Unidad Beta - sábado
    final asistenciaBetaSab = [
      {'id': 'u2_8_$pastSatStr', 'unidad_id': 'u2', 'miembro_id': '8', 'fecha': pastSatStr, 'dia_semana': 'sabado', 'puntualidad': 'presente', 'panoleta': 0, 'biblia': 1, 'cuota': 0, 'registrado_por': '6', 'fecha_registro': now},
      {'id': 'u2_10_$pastSatStr', 'unidad_id': 'u2', 'miembro_id': '10', 'fecha': pastSatStr, 'dia_semana': 'sabado', 'puntualidad': 'presente', 'panoleta': 1, 'biblia': 1, 'cuota': 0, 'registrado_por': '6', 'fecha_registro': now},
    ];

    // Unidad Alfa - domingo (con cuota)
    final asistenciaAlfaDom = [
      {'id': 'u1_1_$pastSunStr', 'unidad_id': 'u1', 'miembro_id': '1', 'fecha': pastSunStr, 'dia_semana': 'domingo', 'puntualidad': 'presente', 'panoleta': 1, 'biblia': 1, 'cuota': 1, 'registrado_por': '4', 'fecha_registro': now},
      {'id': 'u1_2_$pastSunStr', 'unidad_id': 'u1', 'miembro_id': '2', 'fecha': pastSunStr, 'dia_semana': 'domingo', 'puntualidad': 'tardanza', 'panoleta': 1, 'biblia': 1, 'cuota': 1, 'registrado_por': '4', 'fecha_registro': now},
    ];

    for (var a in [...asistenciaAlfaSab, ...asistenciaBetaSab, ...asistenciaAlfaDom]) {
      await db.insert('asistencia', a);
    }

    // ── Especialidades ──
    final especialidades = [
      {'id': '1', 'nombre': 'Primeros Auxilios', 'categoria': 'Actividades Misioneras', 'nivel': 'Básico', 'requisitos': 8},
      {'id': '2', 'nombre': 'Nudos', 'categoria': 'Actividades Recreativas', 'nivel': 'Básico', 'requisitos': 10},
      {'id': '3', 'nombre': 'Aves', 'categoria': 'Naturaleza', 'nivel': 'Básico', 'requisitos': 7},
      {'id': '4', 'nombre': 'Cocina al Aire Libre', 'categoria': 'Hogar', 'nivel': 'Básico', 'requisitos': 6},
      {'id': '5', 'nombre': 'Excursionismo', 'categoria': 'Actividades Recreativas', 'nivel': 'Básico', 'requisitos': 9},
      {'id': '6', 'nombre': 'Arte de Acampar', 'categoria': 'Actividades Recreativas', 'nivel': 'Básico', 'requisitos': 12},
      {'id': '7', 'nombre': 'Fotografía', 'categoria': 'Artes y Habilidades', 'nivel': 'Básico', 'requisitos': 8},
      {'id': '8', 'nombre': 'Liderazgo al Aire Libre', 'categoria': 'Actividades Misioneras', 'nivel': 'Avanzado', 'requisitos': 10},
      {'id': '9', 'nombre': 'Árboles', 'categoria': 'Naturaleza', 'nivel': 'Básico', 'requisitos': 6},
      {'id': '10', 'nombre': 'Vida Primitiva', 'categoria': 'Actividades Recreativas', 'nivel': 'Avanzado', 'requisitos': 11},
    ];
    for (var esp in especialidades) {
      await db.insert('especialidades', esp);
    }

    // ── Ubicaciones ──
    final ubicaciones = [
      {'id': '1', 'nombre': 'Punto de Reunión', 'descripcion': 'Iglesia Adventista Central', 'categoria': 'Reunión', 'latitud': 25.1897, 'longitud': -99.8266, 'fecha': now},
      {'id': '2', 'nombre': 'Campamento Base', 'descripcion': 'Parque Nacional Cumbres de Monterrey', 'categoria': 'Campamento', 'latitud': 25.3667, 'longitud': -100.2167, 'fecha': now},
      {'id': '3', 'nombre': 'Hospital Regional', 'descripcion': 'Hospital más cercano para emergencias', 'categoria': 'Emergencia', 'latitud': 25.1891, 'longitud': -99.8305, 'fecha': now},
    ];
    for (var ub in ubicaciones) {
      await db.insert('ubicaciones', ub);
    }

    // ── 2 Unidades ──
    await db.insert('unidades', {'id': 'u1', 'nombre': 'Unidad Alfa', 'descripcion': 'Primera unidad del club', 'activo': 1, 'fecha_creacion': now});
    await db.insert('unidades', {'id': 'u2', 'nombre': 'Unidad Beta', 'descripcion': 'Segunda unidad del club', 'activo': 1, 'fecha_creacion': now});

    // Unidad Alfa: Ana(consejero) + Juan, María, Carlos, Sofía (aspirantes)
    await db.insert('unidad_miembros', {'id': 'u1_4', 'unidad_id': 'u1', 'miembro_id': '4', 'rol_en_unidad': 'consejero', 'fecha_asignacion': now});
    await db.insert('unidad_miembros', {'id': 'u1_1', 'unidad_id': 'u1', 'miembro_id': '1', 'rol_en_unidad': 'aspirante', 'fecha_asignacion': now});
    await db.insert('unidad_miembros', {'id': 'u1_2', 'unidad_id': 'u1', 'miembro_id': '2', 'rol_en_unidad': 'aspirante', 'fecha_asignacion': now});
    await db.insert('unidad_miembros', {'id': 'u1_3', 'unidad_id': 'u1', 'miembro_id': '3', 'rol_en_unidad': 'aspirante', 'fecha_asignacion': now});
    await db.insert('unidad_miembros', {'id': 'u1_7', 'unidad_id': 'u1', 'miembro_id': '7', 'rol_en_unidad': 'aspirante', 'fecha_asignacion': now});

    // Unidad Beta: Luis(consejero) + Daniel, Pedro (aspirantes)
    await db.insert('unidad_miembros', {'id': 'u2_6', 'unidad_id': 'u2', 'miembro_id': '6', 'rol_en_unidad': 'consejero', 'fecha_asignacion': now});
    await db.insert('unidad_miembros', {'id': 'u2_8', 'unidad_id': 'u2', 'miembro_id': '8', 'rol_en_unidad': 'aspirante', 'fecha_asignacion': now});
    await db.insert('unidad_miembros', {'id': 'u2_10', 'unidad_id': 'u2', 'miembro_id': '10', 'rol_en_unidad': 'aspirante', 'fecha_asignacion': now});

    // ── Carpeta progreso de Juan (id=1): 8 requisitos con avance ──
    // Sección 1: 3 aprobados, 1 preaprobado, 1 pendiente
    await db.insert('carpeta_progreso', {'id': '1_r01', 'miembro_id': '1', 'requisito_id': 'r01', 'completado': 1, 'fecha_completado': now, 'completado_por': '4', 'aprobado': 1, 'fecha_aprobado': now, 'aprobado_por': '5', 'notas': 'Cumple con la edad', 'evidencia_path': null, 'estado': 'aprobado', 'fecha_envio': now});
    await db.insert('carpeta_progreso', {'id': '1_r02', 'miembro_id': '1', 'requisito_id': 'r02', 'completado': 1, 'fecha_completado': now, 'completado_por': '4', 'aprobado': 1, 'fecha_aprobado': now, 'aprobado_por': '5', 'notas': 'Bautizado el 15/03/2023', 'evidencia_path': null, 'estado': 'aprobado', 'fecha_envio': now});
    await db.insert('carpeta_progreso', {'id': '1_r03', 'miembro_id': '1', 'requisito_id': 'r03', 'completado': 1, 'fecha_completado': now, 'completado_por': '4', 'aprobado': 1, 'fecha_aprobado': now, 'aprobado_por': '5', 'notas': 'Curso completado en enero', 'evidencia_path': null, 'estado': 'aprobado', 'fecha_envio': now});
    await db.insert('carpeta_progreso', {'id': '1_r04', 'miembro_id': '1', 'requisito_id': 'r04', 'completado': 1, 'fecha_completado': now, 'completado_por': '4', 'aprobado': 0, 'notas': 'Pendiente de firma del pastor', 'evidencia_path': null, 'estado': 'preaprobado', 'fecha_envio': now});
    // Sección 2: 1 preaprobado, 1 enviado esperando revisión
    await db.insert('carpeta_progreso', {'id': '1_r06', 'miembro_id': '1', 'requisito_id': 'r06', 'completado': 1, 'fecha_completado': now, 'completado_por': '4', 'aprobado': 0, 'notas': '6 meses de devoción cumplidos', 'evidencia_path': null, 'estado': 'preaprobado', 'fecha_envio': now});
    await db.insert('carpeta_progreso', {'id': '1_r07', 'miembro_id': '1', 'requisito_id': 'r07', 'completado': 0, 'aprobado': 0, 'notas': 'Lectura completada plan cronológico', 'evidencia_path': null, 'estado': 'enviado', 'fecha_envio': now});
    // Sección 3: 1 enviado esperando revisión
    await db.insert('carpeta_progreso', {'id': '1_r11', 'miembro_id': '1', 'requisito_id': 'r11', 'completado': 0, 'aprobado': 0, 'notas': 'Limpieza de parque y visita a asilo', 'evidencia_path': null, 'estado': 'enviado', 'fecha_envio': now});
    // Sección 5: 1 aprobado
    await db.insert('carpeta_progreso', {'id': '1_r19', 'miembro_id': '1', 'requisito_id': 'r19', 'completado': 1, 'fecha_completado': now, 'completado_por': '4', 'aprobado': 1, 'fecha_aprobado': now, 'aprobado_por': '5', 'notas': 'Campamento regional, zonal y local', 'evidencia_path': null, 'estado': 'aprobado', 'fecha_envio': now});

    // ── Carpeta progreso de María (id=2): 3 requisitos ──
    await db.insert('carpeta_progreso', {'id': '2_r01', 'miembro_id': '2', 'requisito_id': 'r01', 'completado': 1, 'fecha_completado': now, 'completado_por': '4', 'aprobado': 1, 'fecha_aprobado': now, 'aprobado_por': '5', 'notas': null, 'evidencia_path': null, 'estado': 'aprobado', 'fecha_envio': now});
    await db.insert('carpeta_progreso', {'id': '2_r02', 'miembro_id': '2', 'requisito_id': 'r02', 'completado': 1, 'fecha_completado': now, 'completado_por': '4', 'aprobado': 1, 'fecha_aprobado': now, 'aprobado_por': '5', 'notas': null, 'evidencia_path': null, 'estado': 'aprobado', 'fecha_envio': now});
    await db.insert('carpeta_progreso', {'id': '2_r03', 'miembro_id': '2', 'requisito_id': 'r03', 'completado': 1, 'fecha_completado': now, 'completado_por': '4', 'aprobado': 0, 'notas': 'Esperando aprobación', 'evidencia_path': null, 'estado': 'preaprobado', 'fecha_envio': now});

    // ── Carpeta progreso de Carlos (id=3): 1 requisito ──
    await db.insert('carpeta_progreso', {'id': '3_r01', 'miembro_id': '3', 'requisito_id': 'r01', 'completado': 1, 'fecha_completado': now, 'completado_por': '4', 'aprobado': 1, 'fecha_aprobado': now, 'aprobado_por': '5', 'notas': null, 'evidencia_path': null, 'estado': 'aprobado', 'fecha_envio': now});

    // ── Especialidades asignadas ──
    await db.insert('miembro_especialidad', {'id': '1_1', 'miembro_id': '1', 'especialidad_id': '1', 'fecha_inicio': now, 'requisitos_completados': 6, 'completado': 0});
    await db.insert('miembro_especialidad', {'id': '1_2', 'miembro_id': '1', 'especialidad_id': '2', 'fecha_inicio': now, 'requisitos_completados': 10, 'completado': 1, 'fecha_completado': now});
    await db.insert('miembro_especialidad', {'id': '2_3', 'miembro_id': '2', 'especialidad_id': '3', 'fecha_inicio': now, 'requisitos_completados': 3, 'completado': 0});
  }

  Future<void> _insertarDatosCarpeta(Database db) async {
    // 7 Secciones
    final secciones = [
      {'id': 's1', 'numero': 1, 'nombre': 'Requisitos Generales', 'descripcion': 'Requisitos básicos de elegibilidad y membresía'},
      {'id': 's2', 'numero': 2, 'nombre': 'Desarrollo Espiritual', 'descripcion': 'Crecimiento en la vida devocional y conocimiento bíblico'},
      {'id': 's3', 'numero': 3, 'nombre': 'Servicio', 'descripcion': 'Proyectos de servicio a la comunidad e iglesia'},
      {'id': 's4', 'numero': 4, 'nombre': 'Liderazgo', 'descripcion': 'Desarrollo de habilidades de liderazgo y mentoría'},
      {'id': 's5', 'numero': 5, 'nombre': 'Vida al Aire Libre', 'descripcion': 'Campamentos, naturaleza y habilidades de campo'},
      {'id': 's6', 'numero': 6, 'nombre': 'Estilo de Vida', 'descripcion': 'Salud, temperancia y bienestar integral'},
      {'id': 's7', 'numero': 7, 'nombre': 'Especialidades', 'descripcion': 'Completar especialidades requeridas del club'},
    ];
    for (var s in secciones) {
      await db.insert('carpeta_secciones', s);
    }

    // 29 Requisitos
    final requisitos = [
      // Sección 1: Requisitos Generales
      {'id': 'r01', 'seccion_id': 's1', 'nombre': 'Tener al menos 16 años de edad', 'descripcion': 'Cumplir con la edad mínima requerida para el programa de Guía Mayor', 'orden': 1},
      {'id': 'r02', 'seccion_id': 's1', 'nombre': 'Ser miembro bautizado y activo de la IASD', 'descripcion': 'Estar bautizado y participar activamente en la iglesia local', 'orden': 2},
      {'id': 'r03', 'seccion_id': 's1', 'nombre': 'Completar curso básico de liderazgo juvenil', 'descripcion': 'Aprobar el curso de capacitación para líderes juveniles', 'orden': 3},
      {'id': 'r04', 'seccion_id': 's1', 'nombre': 'Tener recomendación de la Junta de Iglesia', 'descripcion': 'Obtener aprobación de la junta directiva de la iglesia local', 'orden': 4},
      {'id': 'r05', 'seccion_id': 's1', 'nombre': 'Ser miembro activo del Club por al menos 1 año', 'descripcion': 'Demostrar participación constante en las actividades del club', 'orden': 5},

      // Sección 2: Desarrollo Espiritual
      {'id': 'r06', 'seccion_id': 's2', 'nombre': 'Completar plan de devoción matutina por 6 meses', 'descripcion': 'Mantener un registro de devoción matutina diaria durante 6 meses consecutivos', 'orden': 1},
      {'id': 'r07', 'seccion_id': 's2', 'nombre': 'Leer la Biblia en 1 año', 'descripcion': 'Completar un plan de lectura bíblica anual o equivalente', 'orden': 2},
      {'id': 'r08', 'seccion_id': 's2', 'nombre': 'Dar al menos 3 estudios bíblicos', 'descripcion': 'Impartir estudios bíblicos a personas interesadas en la fe', 'orden': 3},
      {'id': 'r09', 'seccion_id': 's2', 'nombre': 'Completar un libro de Elena de White', 'descripcion': 'Leer y hacer un resumen del libro del año del espíritu de profecía', 'orden': 4},
      {'id': 'r10', 'seccion_id': 's2', 'nombre': 'Participar en Semana de Oración o retiro espiritual', 'descripcion': 'Asistir y participar activamente en al menos una semana de oración o retiro', 'orden': 5},

      // Sección 3: Servicio
      {'id': 'r11', 'seccion_id': 's3', 'nombre': 'Participar en al menos 2 proyectos de servicio comunitario', 'descripcion': 'Colaborar en proyectos que beneficien a la comunidad local', 'orden': 1},
      {'id': 'r12', 'seccion_id': 's3', 'nombre': 'Servir activamente en un departamento de la iglesia', 'descripcion': 'Participar como voluntario en un ministerio o departamento de la iglesia', 'orden': 2},
      {'id': 'r13', 'seccion_id': 's3', 'nombre': 'Participar en actividad de evangelismo', 'descripcion': 'Colaborar en campañas evangelísticas, semanas de cosecha o actividades misioneras', 'orden': 3},
      {'id': 'r14', 'seccion_id': 's3', 'nombre': 'Completar un proyecto de servicio personal', 'descripcion': 'Diseñar y ejecutar un proyecto individual de servicio a la comunidad', 'orden': 4},

      // Sección 4: Liderazgo
      {'id': 'r15', 'seccion_id': 's4', 'nombre': 'Dirigir al menos 2 actividades o dinámicas del club', 'descripcion': 'Planificar y ejecutar actividades recreativas o educativas del club', 'orden': 1},
      {'id': 'r16', 'seccion_id': 's4', 'nombre': 'Capacitar a un grupo en una habilidad específica', 'descripcion': 'Enseñar una habilidad (nudos, primeros auxilios, etc.) a un grupo de miembros', 'orden': 2},
      {'id': 'r17', 'seccion_id': 's4', 'nombre': 'Servir como mentor de un miembro menor', 'descripcion': 'Acompañar y guiar a un Conquistador o miembro nuevo en su crecimiento', 'orden': 3},
      {'id': 'r18', 'seccion_id': 's4', 'nombre': 'Organizar y dirigir una fogata o actividad al aire libre', 'descripcion': 'Planificar una fogata con programa cultural, espiritual y recreativo', 'orden': 4},

      // Sección 5: Vida al Aire Libre
      {'id': 'r19', 'seccion_id': 's5', 'nombre': 'Participar en al menos 3 campamentos', 'descripcion': 'Asistir a campamentos del club (pueden ser locales, regionales o nacionales)', 'orden': 1},
      {'id': 'r20', 'seccion_id': 's5', 'nombre': 'Completar 2 especialidades de naturaleza', 'descripcion': 'Terminar dos especialidades relacionadas con la naturaleza (Aves, Árboles, etc.)', 'orden': 2},
      {'id': 'r21', 'seccion_id': 's5', 'nombre': 'Organizar y dirigir una fogata programada', 'descripcion': 'Planificar el programa de una fogata incluyendo cantos, historias y devocional', 'orden': 3},
      {'id': 'r22', 'seccion_id': 's5', 'nombre': 'Conocer técnicas de orientación y supervivencia', 'descripcion': 'Demostrar habilidades de orientación con brújula, mapas y métodos naturales', 'orden': 4},
      {'id': 'r23', 'seccion_id': 's5', 'nombre': 'Construir un refugio temporal', 'descripcion': 'Construir un refugio funcional usando materiales naturales o disponibles', 'orden': 5},

      // Sección 6: Estilo de Vida
      {'id': 'r24', 'seccion_id': 's6', 'nombre': 'Completar programa de salud y temperancia', 'descripcion': 'Estudiar y aplicar principios de vida saludable y temperancia cristiana', 'orden': 1},
      {'id': 'r25', 'seccion_id': 's6', 'nombre': 'Conocer los 8 remedios naturales', 'descripcion': 'Estudiar y poder explicar: aire puro, luz solar, agua, descanso, ejercicio, nutrición, temperancia y confianza en Dios', 'orden': 2},
      {'id': 'r26', 'seccion_id': 's6', 'nombre': 'Participar en actividad de aptitud física', 'descripcion': 'Completar una prueba o programa de actividad física (caminata, carrera, etc.)', 'orden': 3},

      // Sección 7: Especialidades
      {'id': 'r27', 'seccion_id': 's7', 'nombre': 'Completar al menos 5 especialidades en total', 'descripcion': 'Obtener la insignia de al menos 5 especialidades del programa', 'orden': 1},
      {'id': 'r28', 'seccion_id': 's7', 'nombre': 'Tener al menos 1 especialidad de cada área principal', 'descripcion': 'Completar una especialidad de: Naturaleza, Recreativas, Misioneras, Artes y Hogar', 'orden': 2},
      {'id': 'r29', 'seccion_id': 's7', 'nombre': 'Completar la especialidad de Primeros Auxilios', 'descripcion': 'Es requisito obligatorio tener la especialidad de Primeros Auxilios completada', 'orden': 3},
    ];
    for (var r in requisitos) {
      await db.insert('carpeta_requisitos', r);
    }
  }

  // ==================== MIEMBROS ====================

  Future<List<Miembro>> getMiembros() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'miembros',
      orderBy: 'nombre ASC',
    );
    return List.generate(maps.length, (i) => Miembro.fromMap(maps[i]));
  }

  Future<Miembro?> getMiembro(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'miembros',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Miembro.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertMiembro(Miembro miembro) async {
    final db = await database;
    return await db.insert(
      'miembros',
      miembro.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateMiembro(Miembro miembro) async {
    final db = await database;
    return await db.update(
      'miembros',
      miembro.toMap(),
      where: 'id = ?',
      whereArgs: [miembro.id],
    );
  }

  Future<int> deleteMiembro(String id) async {
    final db = await database;
    return await db.delete(
      'miembros',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> countMiembros() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM miembros WHERE activo = 1');
    return result.first['count'] as int;
  }

  // ==================== AUTENTICACIÓN ====================

  Future<Miembro?> getMiembroPorUsuario(String usuario) async {
    final db = await database;
    final maps = await db.query('miembros',
        where: 'usuario = ?', whereArgs: [usuario]);
    if (maps.isNotEmpty) return Miembro.fromMap(maps.first);
    return null;
  }

  Future<void> setCredenciales(String miembroId, String usuario, String passwordHash) async {
    final db = await database;
    await db.update('miembros',
        {'usuario': usuario, 'password_hash': passwordHash},
        where: 'id = ?', whereArgs: [miembroId]);
  }

  // ==================== EVENTOS ====================

  Future<List<Evento>> getEventos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'eventos',
      orderBy: 'fecha ASC',
    );
    return List.generate(maps.length, (i) => Evento.fromMap(maps[i]));
  }

  Future<int> insertEvento(Evento evento) async {
    final db = await database;
    return await db.insert('eventos', evento.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateEvento(Evento evento) async {
    final db = await database;
    return await db.update('eventos', evento.toMap(),
        where: 'id = ?', whereArgs: [evento.id]);
  }

  Future<int> deleteEvento(String id) async {
    final db = await database;
    return await db.delete('eventos', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countEventos() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM eventos');
    return result.first['count'] as int;
  }

  // ==================== ASISTENCIA ====================

  Future<List<Map<String, dynamic>>> getAsistenciaPorUnidadFecha(
      String unidadId, String fecha) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT a.*, m.nombre, m.apellido
      FROM asistencia a
      JOIN miembros m ON a.miembro_id = m.id
      WHERE a.unidad_id = ? AND a.fecha = ?
      ORDER BY m.nombre ASC
    ''', [unidadId, fecha]);
  }

  Future<List<Map<String, dynamic>>> getHistorialAsistenciaMiembro(
      String miembroId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT a.*, u.nombre as unidad_nombre
      FROM asistencia a
      JOIN unidades u ON a.unidad_id = u.id
      WHERE a.miembro_id = ?
      ORDER BY a.fecha DESC
    ''', [miembroId]);
  }

  Future<void> registrarAsistenciaUnidad({
    required String unidadId,
    required String fecha,
    required String diaSemana,
    required List<Map<String, dynamic>> registros,
    required String registradoPor,
  }) async {
    final db = await database;
    final batch = db.batch();
    for (final r in registros) {
      final miembroId = r['miembroId'] as String;
      final id = '${unidadId}_${miembroId}_$fecha';
      batch.insert('asistencia', {
        'id': id,
        'unidad_id': unidadId,
        'miembro_id': miembroId,
        'fecha': fecha,
        'dia_semana': diaSemana,
        'puntualidad': r['puntualidad'] as String,
        'panoleta': (r['panoleta'] as bool) ? 1 : 0,
        'biblia': (r['biblia'] as bool) ? 1 : 0,
        'cuota': (r['cuota'] as bool) ? 1 : 0,
        'registrado_por': registradoPor,
        'fecha_registro': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<double> getPorcentajeAsistencia() async {
    final db = await database;
    final total = await db.rawQuery('SELECT COUNT(*) as count FROM asistencia');
    final asistieron = await db.rawQuery(
        "SELECT COUNT(*) as count FROM asistencia WHERE puntualidad IN ('presente', 'tardanza')");
    final totalCount = total.first['count'] as int;
    final asistieronCount = asistieron.first['count'] as int;
    if (totalCount == 0) return 0.0;
    return (asistieronCount / totalCount) * 100;
  }

  Future<double> getPorcentajeAsistenciaMiembro(String miembroId) async {
    final db = await database;
    final total = await db.rawQuery(
        'SELECT COUNT(*) as count FROM asistencia WHERE miembro_id = ?', [miembroId]);
    final asistieron = await db.rawQuery(
        "SELECT COUNT(*) as count FROM asistencia WHERE miembro_id = ? AND puntualidad IN ('presente', 'tardanza')",
        [miembroId]);
    final totalCount = total.first['count'] as int;
    final asistieronCount = asistieron.first['count'] as int;
    if (totalCount == 0) return 0.0;
    return (asistieronCount / totalCount) * 100;
  }

  Future<double> getPorcentajeAsistenciaUnidad(String unidadId) async {
    final db = await database;
    final total = await db.rawQuery(
        'SELECT COUNT(*) as count FROM asistencia WHERE unidad_id = ?', [unidadId]);
    final asistieron = await db.rawQuery(
        "SELECT COUNT(*) as count FROM asistencia WHERE unidad_id = ? AND puntualidad IN ('presente', 'tardanza')",
        [unidadId]);
    final totalCount = total.first['count'] as int;
    final asistieronCount = asistieron.first['count'] as int;
    if (totalCount == 0) return 0.0;
    return (asistieronCount / totalCount) * 100;
  }

  Future<List<String>> getFechasConAsistencia(String unidadId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT DISTINCT fecha FROM asistencia WHERE unidad_id = ? ORDER BY fecha DESC',
        [unidadId]);
    return result.map((r) => r['fecha'] as String).toList();
  }

  // ── Estadisticas para graficas ──

  /// Asistencia por fecha (ultimas N fechas) - para grafica de linea
  Future<List<Map<String, dynamic>>> getAsistenciaPorFechas({int limit = 10}) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT fecha,
        COUNT(*) as total,
        SUM(CASE WHEN puntualidad = 'presente' THEN 1 ELSE 0 END) as presentes,
        SUM(CASE WHEN puntualidad = 'tardanza' THEN 1 ELSE 0 END) as tardanzas,
        SUM(CASE WHEN puntualidad = 'ausente' THEN 1 ELSE 0 END) as ausentes
      FROM asistencia
      GROUP BY fecha
      ORDER BY fecha DESC
      LIMIT ?
    ''', [limit]);
  }

  /// Distribucion de roles - para grafica de pie
  Future<List<Map<String, dynamic>>> getDistribucionRoles() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT rol, COUNT(*) as count
      FROM miembros
      WHERE activo = 1
      GROUP BY rol
      ORDER BY count DESC
    ''');
  }

  /// Asistencia por unidad - para grafica de barras
  Future<List<Map<String, dynamic>>> getAsistenciaPorUnidad() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT u.nombre as unidad,
        COUNT(*) as total,
        SUM(CASE WHEN a.puntualidad IN ('presente', 'tardanza') THEN 1 ELSE 0 END) as asistieron
      FROM asistencia a
      JOIN unidades u ON a.unidad_id = u.id
      GROUP BY a.unidad_id
      ORDER BY u.nombre ASC
    ''');
  }

  /// Miembros por clase - para grafica de pie
  Future<List<Map<String, dynamic>>> getDistribucionClases() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT clase, COUNT(*) as count
      FROM miembros
      WHERE activo = 1
      GROUP BY clase
      ORDER BY count DESC
    ''');
  }

  // ==================== ESPECIALIDADES ====================

  Future<List<Map<String, dynamic>>> getEspecialidades() async {
    final db = await database;
    return await db.query('especialidades', orderBy: 'categoria ASC, nombre ASC');
  }

  Future<int> insertEspecialidad(Map<String, dynamic> especialidad) async {
    final db = await database;
    return await db.insert('especialidades', especialidad,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateEspecialidad(Map<String, dynamic> especialidad) async {
    final db = await database;
    return await db.update('especialidades', especialidad,
        where: 'id = ?', whereArgs: [especialidad['id']]);
  }

  Future<int> deleteEspecialidad(String id) async {
    final db = await database;
    await db.delete('miembro_especialidad',
        where: 'especialidad_id = ?', whereArgs: [id]);
    return await db.delete('especialidades', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countEspecialidades() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM especialidades');
    return result.first['count'] as int;
  }

  // ==================== MIEMBRO-ESPECIALIDAD ====================

  Future<List<Map<String, dynamic>>> getMiembrosDeEspecialidad(String especialidadId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT me.*, m.nombre, m.apellido
      FROM miembro_especialidad me
      JOIN miembros m ON me.miembro_id = m.id
      WHERE me.especialidad_id = ?
      ORDER BY m.nombre ASC
    ''', [especialidadId]);
  }

  Future<void> asignarEspecialidad({
    required String miembroId,
    required String especialidadId,
  }) async {
    final db = await database;
    final id = '${miembroId}_$especialidadId';
    await db.insert(
      'miembro_especialidad',
      {
        'id': id,
        'miembro_id': miembroId,
        'especialidad_id': especialidadId,
        'fecha_inicio': DateTime.now().toIso8601String(),
        'requisitos_completados': 0,
        'completado': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> actualizarProgresoEspecialidad({
    required String miembroId,
    required String especialidadId,
    required int requisitosCompletados,
    required int totalRequisitos,
  }) async {
    final db = await database;
    final id = '${miembroId}_$especialidadId';
    final completado = requisitosCompletados >= totalRequisitos ? 1 : 0;
    await db.update(
      'miembro_especialidad',
      {
        'requisitos_completados': requisitosCompletados,
        'completado': completado,
        'fecha_completado':
            completado == 1 ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> desasignarEspecialidad({
    required String miembroId,
    required String especialidadId,
  }) async {
    final db = await database;
    final id = '${miembroId}_$especialidadId';
    await db.delete('miembro_especialidad', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== EVIDENCIAS ====================

  Future<List<Map<String, dynamic>>> getEvidencias() async {
    final db = await database;
    return await db.query('evidencias', orderBy: 'fecha DESC');
  }

  Future<int> insertEvidencia(Map<String, dynamic> evidencia) async {
    final db = await database;
    return await db.insert('evidencias', evidencia,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteEvidencia(String id) async {
    final db = await database;
    return await db.delete('evidencias', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countEvidencias() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM evidencias');
    return result.first['count'] as int;
  }

  // ==================== UBICACIONES ====================

  Future<List<Map<String, dynamic>>> getUbicaciones() async {
    final db = await database;
    return await db.query('ubicaciones', orderBy: 'nombre ASC');
  }

  Future<int> insertUbicacion(Map<String, dynamic> ubicacion) async {
    final db = await database;
    return await db.insert('ubicaciones', ubicacion,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateUbicacion(Map<String, dynamic> ubicacion) async {
    final db = await database;
    return await db.update('ubicaciones', ubicacion,
        where: 'id = ?', whereArgs: [ubicacion['id']]);
  }

  Future<int> deleteUbicacion(String id) async {
    final db = await database;
    return await db.delete('ubicaciones', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== NOTIFICACIONES ====================

  Future<List<Map<String, dynamic>>> getNotificaciones() async {
    final db = await database;
    return await db.query('notificaciones', orderBy: 'fecha_programada DESC');
  }

  Future<List<Map<String, dynamic>>> getNotificacionesPendientes() async {
    final db = await database;
    return await db.query('notificaciones',
        where: 'leida = 0', orderBy: 'fecha_programada ASC');
  }

  Future<int> countNotificacionesNoLeidas() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notificaciones WHERE leida = 0');
    return result.first['count'] as int;
  }

  Future<int> insertNotificacion(Map<String, dynamic> notificacion) async {
    final db = await database;
    return await db.insert('notificaciones', notificacion,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> marcarNotificacionLeida(String id) async {
    final db = await database;
    return await db.update('notificaciones', {'leida': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> marcarTodasLeidas() async {
    final db = await database;
    await db.update('notificaciones', {'leida': 1});
  }

  Future<int> deleteNotificacion(String id) async {
    final db = await database;
    return await db.delete('notificaciones', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteNotificacionesLeidas() async {
    final db = await database;
    await db.delete('notificaciones', where: 'leida = 1');
  }

  // ==================== UNIDADES ====================

  Future<List<Map<String, dynamic>>> getUnidades() async {
    final db = await database;
    return await db.query('unidades', orderBy: 'nombre ASC');
  }

  Future<Map<String, dynamic>?> getUnidad(String id) async {
    final db = await database;
    final result = await db.query('unidades', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertUnidad(Map<String, dynamic> unidad) async {
    final db = await database;
    return await db.insert('unidades', unidad,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateUnidad(Map<String, dynamic> unidad) async {
    final db = await database;
    return await db.update('unidades', unidad,
        where: 'id = ?', whereArgs: [unidad['id']]);
  }

  Future<int> deleteUnidad(String id) async {
    final db = await database;
    await db.delete('unidad_miembros', where: 'unidad_id = ?', whereArgs: [id]);
    return await db.delete('unidades', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getMiembrosDeUnidad(String unidadId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT um.*, m.nombre, m.apellido, m.clase, m.rol, m.foto_url
      FROM unidad_miembros um
      JOIN miembros m ON um.miembro_id = m.id
      WHERE um.unidad_id = ?
      ORDER BY um.rol_en_unidad ASC, m.nombre ASC
    ''', [unidadId]);
  }

  Future<void> asignarMiembroAUnidad({
    required String unidadId,
    required String miembroId,
    required String rolEnUnidad,
  }) async {
    final db = await database;
    final id = '${unidadId}_$miembroId';
    await db.insert('unidad_miembros', {
      'id': id,
      'unidad_id': unidadId,
      'miembro_id': miembroId,
      'rol_en_unidad': rolEnUnidad,
      'fecha_asignacion': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> desasignarMiembroDeUnidad({
    required String unidadId,
    required String miembroId,
  }) async {
    final db = await database;
    final id = '${unidadId}_$miembroId';
    await db.delete('unidad_miembros', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getUnidadDeConsejero(String consejeroId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT u.* FROM unidades u
      JOIN unidad_miembros um ON u.id = um.unidad_id
      WHERE um.miembro_id = ? AND um.rol_en_unidad = 'consejero'
      LIMIT 1
    ''', [consejeroId]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUnidadDeAspirante(String aspiranteId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT u.* FROM unidades u
      JOIN unidad_miembros um ON u.id = um.unidad_id
      WHERE um.miembro_id = ? AND um.rol_en_unidad = 'aspirante'
      LIMIT 1
    ''', [aspiranteId]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> countConsejeros(String unidadId) async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT COUNT(*) as c FROM unidad_miembros WHERE unidad_id = ? AND rol_en_unidad = 'consejero'",
        [unidadId]);
    return result.first['c'] as int;
  }

  Future<int> countAspirantes(String unidadId) async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT COUNT(*) as c FROM unidad_miembros WHERE unidad_id = ? AND rol_en_unidad = 'aspirante'",
        [unidadId]);
    return result.first['c'] as int;
  }

  // ==================== CARPETA DE INVESTIDURA ====================

  Future<List<Map<String, dynamic>>> getCarpetaSecciones() async {
    final db = await database;
    return await db.query('carpeta_secciones', orderBy: 'numero ASC');
  }

  Future<List<Map<String, dynamic>>> getCarpetaRequisitos(String seccionId) async {
    final db = await database;
    return await db.query('carpeta_requisitos',
        where: 'seccion_id = ?', whereArgs: [seccionId], orderBy: 'orden ASC');
  }

  Future<List<Map<String, dynamic>>> getTodosLosRequisitos() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT r.*, s.nombre as seccion_nombre, s.numero as seccion_numero
      FROM carpeta_requisitos r
      JOIN carpeta_secciones s ON r.seccion_id = s.id
      ORDER BY s.numero ASC, r.orden ASC
    ''');
  }

  // ── CRUD Secciones ──

  Future<int> insertSeccion(Map<String, dynamic> seccion) async {
    final db = await database;
    return await db.insert('carpeta_secciones', seccion,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateSeccion(Map<String, dynamic> seccion) async {
    final db = await database;
    return await db.update('carpeta_secciones', seccion,
        where: 'id = ?', whereArgs: [seccion['id']]);
  }

  Future<int> deleteSeccion(String id) async {
    final db = await database;
    final requisitos = await db.query('carpeta_requisitos',
        where: 'seccion_id = ?', whereArgs: [id]);
    for (final r in requisitos) {
      await db.delete('carpeta_progreso',
          where: 'requisito_id = ?', whereArgs: [r['id']]);
    }
    await db.delete('carpeta_requisitos',
        where: 'seccion_id = ?', whereArgs: [id]);
    return await db.delete('carpeta_secciones',
        where: 'id = ?', whereArgs: [id]);
  }

  // ── CRUD Requisitos ──

  Future<int> insertRequisito(Map<String, dynamic> requisito) async {
    final db = await database;
    return await db.insert('carpeta_requisitos', requisito,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateRequisito(Map<String, dynamic> requisito) async {
    final db = await database;
    return await db.update('carpeta_requisitos', requisito,
        where: 'id = ?', whereArgs: [requisito['id']]);
  }

  Future<int> deleteRequisito(String id) async {
    final db = await database;
    await db.delete('carpeta_progreso',
        where: 'requisito_id = ?', whereArgs: [id]);
    return await db.delete('carpeta_requisitos',
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getCarpetaProgresoMiembro(String miembroId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT r.*, s.nombre as seccion_nombre, s.numero as seccion_numero,
             p.completado, p.fecha_completado, p.completado_por,
             p.aprobado, p.fecha_aprobado, p.aprobado_por,
             p.notas, p.evidencia_path,
             p.estado, p.comentario_devolucion, p.fecha_envio
      FROM carpeta_requisitos r
      JOIN carpeta_secciones s ON r.seccion_id = s.id
      LEFT JOIN carpeta_progreso p ON r.id = p.requisito_id AND p.miembro_id = ?
      ORDER BY s.numero ASC, r.orden ASC
    ''', [miembroId]);
  }

  Future<Map<String, int>> getCarpetaResumen(String miembroId) async {
    final db = await database;
    final total = await db.rawQuery('SELECT COUNT(*) as c FROM carpeta_requisitos');
    final enviados = await db.rawQuery(
        "SELECT COUNT(*) as c FROM carpeta_progreso WHERE miembro_id = ? AND estado = 'enviado'",
        [miembroId]);
    final preaprobados = await db.rawQuery(
        "SELECT COUNT(*) as c FROM carpeta_progreso WHERE miembro_id = ? AND estado = 'preaprobado'",
        [miembroId]);
    final aprobados = await db.rawQuery(
        "SELECT COUNT(*) as c FROM carpeta_progreso WHERE miembro_id = ? AND estado = 'aprobado'",
        [miembroId]);
    final devueltos = await db.rawQuery(
        "SELECT COUNT(*) as c FROM carpeta_progreso WHERE miembro_id = ? AND estado = 'devuelto'",
        [miembroId]);
    final completados = await db.rawQuery(
        "SELECT COUNT(*) as c FROM carpeta_progreso WHERE miembro_id = ? AND estado IN ('enviado','preaprobado','aprobado')",
        [miembroId]);
    return {
      'total': total.first['c'] as int,
      'completados': completados.first['c'] as int,
      'aprobados': aprobados.first['c'] as int,
      'enviados': enviados.first['c'] as int,
      'preaprobados': preaprobados.first['c'] as int,
      'devueltos': devueltos.first['c'] as int,
    };
  }

  Future<void> marcarRequisitoCompletado({
    required String miembroId,
    required String requisitoId,
    required String completadoPor,
    String? notas,
    String? evidenciaPath,
  }) async {
    final db = await database;
    final id = '${miembroId}_$requisitoId';
    await db.insert('carpeta_progreso', {
      'id': id,
      'miembro_id': miembroId,
      'requisito_id': requisitoId,
      'completado': 1,
      'fecha_completado': DateTime.now().toIso8601String(),
      'completado_por': completadoPor,
      'aprobado': 0,
      'notas': notas,
      'evidencia_path': evidenciaPath,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> aprobarRequisito({
    required String miembroId,
    required String requisitoId,
    required String aprobadoPor,
  }) async {
    final db = await database;
    final id = '${miembroId}_$requisitoId';
    await db.update('carpeta_progreso', {
      'aprobado': 1,
      'fecha_aprobado': DateTime.now().toIso8601String(),
      'aprobado_por': aprobadoPor,
      'estado': 'aprobado',
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> desmarcarRequisito({
    required String miembroId,
    required String requisitoId,
  }) async {
    final db = await database;
    final id = '${miembroId}_$requisitoId';
    await db.delete('carpeta_progreso', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getRequisitosPendientesAprobacion() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT p.*, r.nombre as requisito_nombre, r.seccion_id,
             s.nombre as seccion_nombre,
             m.nombre as miembro_nombre, m.apellido as miembro_apellido
      FROM carpeta_progreso p
      JOIN carpeta_requisitos r ON p.requisito_id = r.id
      JOIN carpeta_secciones s ON r.seccion_id = s.id
      JOIN miembros m ON p.miembro_id = m.id
      WHERE p.estado = 'preaprobado'
      ORDER BY p.fecha_completado ASC
    ''');
  }

  Future<void> enviarEvidencia({
    required String miembroId,
    required String requisitoId,
    String? evidenciaPath,
    String? notas,
  }) async {
    final db = await database;
    final id = '${miembroId}_$requisitoId';
    final now = DateTime.now().toIso8601String();
    final existing = await db.query('carpeta_progreso', where: 'id = ?', whereArgs: [id]);
    if (existing.isNotEmpty) {
      await db.update('carpeta_progreso', {
        'estado': 'enviado',
        'evidencia_path': evidenciaPath,
        'notas': notas,
        'fecha_envio': now,
        'comentario_devolucion': null,
      }, where: 'id = ?', whereArgs: [id]);
    } else {
      await db.insert('carpeta_progreso', {
        'id': id,
        'miembro_id': miembroId,
        'requisito_id': requisitoId,
        'completado': 0,
        'aprobado': 0,
        'estado': 'enviado',
        'evidencia_path': evidenciaPath,
        'notas': notas,
        'fecha_envio': now,
      });
    }
  }

  Future<void> preAprobarRequisito({
    required String miembroId,
    required String requisitoId,
    required String completadoPor,
  }) async {
    final db = await database;
    final id = '${miembroId}_$requisitoId';
    await db.update('carpeta_progreso', {
      'estado': 'preaprobado',
      'completado': 1,
      'fecha_completado': DateTime.now().toIso8601String(),
      'completado_por': completadoPor,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> devolverRequisito({
    required String miembroId,
    required String requisitoId,
    required String comentario,
  }) async {
    final db = await database;
    final id = '${miembroId}_$requisitoId';
    await db.update('carpeta_progreso', {
      'estado': 'devuelto',
      'comentario_devolucion': comentario,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<String?> getConsejeroDeAspirante(String aspiranteId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT um_c.miembro_id as consejero_id
      FROM unidad_miembros um_a
      JOIN unidad_miembros um_c ON um_a.unidad_id = um_c.unidad_id
      WHERE um_a.miembro_id = ? AND um_a.rol_en_unidad = 'aspirante'
        AND um_c.rol_en_unidad = 'consejero'
      LIMIT 1
    ''', [aspiranteId]);
    return result.isNotEmpty ? result.first['consejero_id'] as String : null;
  }

  // ==================== CONFIGURACIÓN ====================

  Future<String?> getConfig(String clave) async {
    final db = await database;
    final result = await db.query('configuracion',
        where: 'clave = ?', whereArgs: [clave]);
    if (result.isNotEmpty) {
      return result.first['valor'] as String;
    }
    return null;
  }

  Future<void> setConfig(String clave, String valor) async {
    final db = await database;
    await db.insert(
      'configuracion',
      {'clave': clave, 'valor': valor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>> getAllConfig() async {
    final db = await database;
    final result = await db.query('configuracion');
    return {for (var r in result) r['clave'] as String: r['valor'] as String};
  }

  // ==================== EXPORTAR DATOS ====================

  Future<String> exportarDatosJson() async {
    final db = await database;
    // Excluir password_hash del export
    final miembros = await db.query('miembros');
    final miembrosSafe = miembros.map((m) {
      final safe = Map<String, dynamic>.from(m);
      safe.remove('password_hash');
      return safe;
    }).toList();

    final data = {
      'exportado_en': DateTime.now().toIso8601String(),
      'version': 'GMU Doulos v1.0.0',
      'miembros': miembrosSafe,
      'eventos': await db.query('eventos'),
      'asistencia': await db.query('asistencia'),
      'especialidades': await db.query('especialidades'),
      'miembro_especialidad': await db.query('miembro_especialidad'),
      'unidades': await db.query('unidades'),
      'unidad_miembros': await db.query('unidad_miembros'),
      'carpeta_progreso': await db.query('carpeta_progreso'),
      'configuracion': await db.query('configuracion'),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<Map<String, int>> getResumenDatos() async {
    final db = await database;
    final miembros = await db.rawQuery('SELECT COUNT(*) as c FROM miembros');
    final eventos = await db.rawQuery('SELECT COUNT(*) as c FROM eventos');
    final asistencia = await db.rawQuery('SELECT COUNT(*) as c FROM asistencia');
    final especialidades = await db.rawQuery('SELECT COUNT(*) as c FROM especialidades');
    final evidencias = await db.rawQuery('SELECT COUNT(*) as c FROM evidencias');
    final unidades = await db.rawQuery('SELECT COUNT(*) as c FROM unidades');
    return {
      'miembros': miembros.first['c'] as int,
      'eventos': eventos.first['c'] as int,
      'asistencia': asistencia.first['c'] as int,
      'especialidades': especialidades.first['c'] as int,
      'evidencias': evidencias.first['c'] as int,
      'unidades': unidades.first['c'] as int,
    };
  }

  // ==================== IMPORTAR DATOS ====================

  Future<Map<String, int>> importarDatosJson(String jsonString) async {
    final db = await database;
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final counts = <String, int>{};

    // Tablas en orden para respetar foreign keys
    final tablas = [
      'miembros',
      'eventos',
      'especialidades',
      'unidades',
      'unidad_miembros',
      'asistencia',
      'miembro_especialidad',
      'carpeta_progreso',
      'configuracion',
    ];

    for (final tabla in tablas) {
      final registros = data[tabla] as List<dynamic>?;
      if (registros == null || registros.isEmpty) continue;
      int insertados = 0;
      for (final r in registros) {
        try {
          await db.insert(
            tabla,
            Map<String, dynamic>.from(r as Map),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
          insertados++;
        } catch (_) {
          // Ignorar registros con conflictos
        }
      }
      counts[tabla] = insertados;
    }
    return counts;
  }

  // ==================== UTILIDADES ====================

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('carpeta_progreso');
    await db.delete('unidad_miembros');
    await db.delete('asistencia');
    await db.delete('miembro_especialidad');
    await db.delete('evidencias');
    await db.delete('ubicaciones');
    await db.delete('notificaciones');
    await db.delete('eventos');
    await db.delete('miembros');
    await db.delete('especialidades');
    await db.delete('unidades');
    await _insertarDatosEjemplo(db);
  }
}
