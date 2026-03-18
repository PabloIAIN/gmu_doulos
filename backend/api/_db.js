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
      fecha_registro TEXT
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

  // Índices
  await sql`CREATE INDEX IF NOT EXISTS idx_asistencia_fecha ON asistencia(fecha)`;
  await sql`CREATE INDEX IF NOT EXISTS idx_asistencia_miembro ON asistencia(miembro_id)`;
  await sql`CREATE INDEX IF NOT EXISTS idx_miembros_rol ON miembros(rol)`;

  return { ok: true };
}

module.exports = { sql, initDatabase };
