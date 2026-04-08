const { neon } = require('@neondatabase/serverless');

// ── Detectar la URL de conexión ──
const connectionString = process.env.POSTGRES_URL
  || process.env.POSTGRES_DATABASE_URL
  || process.env.DATABASE_URL
  || process.env.STORAGE_URL;

// Crear cliente SQL de forma segura
let sql = null;
try {
  if (connectionString) {
    sql = neon(connectionString);
  }
} catch (e) {
  console.error('Error creating neon client:', e.message);
}

// ── Inicializar tablas ──
async function initDatabase() {
  if (!sql) throw new Error('No database URL found. Set POSTGRES_URL in Vercel env vars.');

  // Borrar tablas existentes para recrear con tipos correctos
  await sql`DROP TABLE IF EXISTS audit_log CASCADE`;
  await sql`DROP TABLE IF EXISTS asistencia CASCADE`;
  await sql`DROP TABLE IF EXISTS unidad_miembros CASCADE`;
  await sql`DROP TABLE IF EXISTS unidades CASCADE`;
  await sql`DROP TABLE IF EXISTS eventos CASCADE`;
  await sql`DROP TABLE IF EXISTS miembros CASCADE`;

  await sql`
    CREATE TABLE miembros (
      id TEXT PRIMARY KEY,
      nombre TEXT NOT NULL,
      apellido TEXT NOT NULL,
      fecha_nacimiento TEXT,
      telefono TEXT,
      email TEXT,
      foto_url TEXT,
      clase TEXT DEFAULT 'Guia Mayor Aspirante',
      rol TEXT DEFAULT 'Miembro',
      activo INTEGER DEFAULT 1,
      fecha_registro TEXT NOT NULL,
      usuario TEXT,
      password_hash TEXT,
      club_id TEXT,
      ministerio TEXT DEFAULT 'gm',
      clase_ministerio TEXT,
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW()
    )
  `;

  await sql`
    CREATE TABLE eventos (
      id TEXT PRIMARY KEY,
      titulo TEXT NOT NULL,
      descripcion TEXT,
      fecha TEXT NOT NULL,
      hora TEXT,
      ubicacion TEXT,
      tipo TEXT DEFAULT 'reunion',
      latitud DOUBLE PRECISION,
      longitud DOUBLE PRECISION,
      club_id TEXT,
      ministerio TEXT DEFAULT 'todos',
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW()
    )
  `;

  await sql`
    CREATE TABLE unidades (
      id TEXT PRIMARY KEY,
      nombre TEXT NOT NULL,
      descripcion TEXT,
      activo INTEGER DEFAULT 1,
      fecha_creacion TEXT NOT NULL,
      club_id TEXT,
      ministerio TEXT DEFAULT 'gm',
      created_at TIMESTAMP DEFAULT NOW()
    )
  `;

  await sql`
    CREATE TABLE unidad_miembros (
      id TEXT PRIMARY KEY,
      unidad_id TEXT NOT NULL,
      miembro_id TEXT NOT NULL,
      rol_en_unidad TEXT DEFAULT 'miembro',
      fecha_asignacion TEXT NOT NULL
    )
  `;

  await sql`
    CREATE TABLE asistencia (
      id TEXT PRIMARY KEY,
      unidad_id TEXT NOT NULL,
      miembro_id TEXT NOT NULL,
      fecha TEXT NOT NULL,
      dia_semana TEXT,
      puntualidad TEXT DEFAULT '0',
      panoleta TEXT DEFAULT '0',
      biblia TEXT DEFAULT '0',
      cuota TEXT DEFAULT '0',
      registrado_por TEXT,
      fecha_registro TEXT,
      club_id TEXT
    )
  `;

  await sql`
    CREATE TABLE audit_log (
      id TEXT PRIMARY KEY,
      accion TEXT NOT NULL,
      tabla TEXT,
      registro_id TEXT,
      descripcion TEXT,
      usuario_id TEXT,
      usuario_nombre TEXT,
      fecha TEXT NOT NULL
    )
  `;

  // ── Tabla anuncios (comunicacion) ──
  await sql`
    CREATE TABLE IF NOT EXISTS anuncios (
      id TEXT PRIMARY KEY,
      club_id TEXT NOT NULL,
      ministerio TEXT DEFAULT 'todos',
      titulo TEXT NOT NULL,
      contenido TEXT NOT NULL,
      autor_id TEXT,
      autor_nombre TEXT,
      tipo TEXT DEFAULT 'general',
      fecha_publicacion TEXT NOT NULL,
      activo INTEGER DEFAULT 1
    )
  `;
  await sql`CREATE INDEX IF NOT EXISTS idx_anuncios_club ON anuncios(club_id)`;
  await sql`CREATE INDEX IF NOT EXISTS idx_anuncios_fecha ON anuncios(fecha_publicacion DESC)`;

  // ── Tabla clubes ──
  await sql`
    CREATE TABLE IF NOT EXISTS clubes (
      id TEXT PRIMARY KEY,
      nombre TEXT NOT NULL,
      iglesia TEXT NOT NULL,
      ciudad TEXT NOT NULL,
      pais TEXT NOT NULL DEFAULT 'México',
      asociacion TEXT,
      union_campo TEXT,
      division TEXT DEFAULT 'División Interamericana',
      codigo_acceso TEXT UNIQUE NOT NULL,
      ministerios TEXT DEFAULT 'gm',
      plan TEXT DEFAULT 'gratis',
      max_miembros INTEGER DEFAULT 20,
      plan_expira TIMESTAMP,
      activo INTEGER DEFAULT 1,
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW()
    )
  `;

  // ── Tablas de plantillas DIA ──
  await sql`
    CREATE TABLE IF NOT EXISTS carpeta_secciones (
      id TEXT PRIMARY KEY,
      nombre TEXT NOT NULL,
      orden INTEGER DEFAULT 0,
      club_id TEXT
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS carpeta_requisitos (
      id TEXT PRIMARY KEY,
      seccion_id TEXT NOT NULL,
      nombre TEXT NOT NULL,
      orden INTEGER DEFAULT 0,
      club_id TEXT
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS carpeta_progreso (
      id TEXT PRIMARY KEY,
      requisito_id TEXT NOT NULL,
      miembro_id TEXT NOT NULL,
      estado TEXT DEFAULT 'pendiente',
      fecha_completado TEXT,
      aprobado_por TEXT,
      observaciones TEXT,
      club_id TEXT
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS especialidades (
      id TEXT PRIMARY KEY,
      nombre TEXT NOT NULL,
      categoria TEXT,
      nivel TEXT,
      club_id TEXT
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS miembro_especialidad (
      id TEXT PRIMARY KEY,
      miembro_id TEXT NOT NULL,
      especialidad_id TEXT NOT NULL,
      estado TEXT DEFAULT 'en_progreso',
      fecha_inicio TEXT,
      fecha_completado TEXT,
      club_id TEXT
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS configuracion (
      clave TEXT PRIMARY KEY,
      valor TEXT
    )
  `;

  // ── Índices ──
  await sql`CREATE INDEX IF NOT EXISTS idx_clubes_codigo ON clubes(codigo_acceso)`;
  await sql`CREATE INDEX IF NOT EXISTS idx_asistencia_fecha ON asistencia(fecha)`;
  await sql`CREATE INDEX IF NOT EXISTS idx_asistencia_miembro ON asistencia(miembro_id)`;
  await sql`CREATE INDEX IF NOT EXISTS idx_miembros_rol ON miembros(rol)`;
  await sql`CREATE INDEX IF NOT EXISTS idx_miembros_club ON miembros(club_id)`;
  await sql`CREATE INDEX IF NOT EXISTS idx_miembros_ministerio ON miembros(ministerio)`;
  await sql`CREATE INDEX IF NOT EXISTS idx_eventos_club ON eventos(club_id)`;
  await sql`CREATE INDEX IF NOT EXISTS idx_unidades_club ON unidades(club_id)`;
  await sql`CREATE INDEX IF NOT EXISTS idx_asistencia_club ON asistencia(club_id)`;

  // ── Migrar club existente "Doulos" ──
  await sql`
    INSERT INTO clubes (id, nombre, iglesia, ciudad, pais, codigo_acceso, ministerios, plan)
    VALUES ('doulos-montemorelos', 'Doulos', 'Iglesia Adventista Central', 'Montemorelos, NL', 'México', 'DOULOS2026', 'gm', 'gratis')
    ON CONFLICT (id) DO NOTHING
  `;

  return { ok: true };
}

module.exports = { sql, initDatabase };
