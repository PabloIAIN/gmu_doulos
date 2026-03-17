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

  await sql`
    CREATE TABLE IF NOT EXISTS miembros (
      id VARCHAR(36) PRIMARY KEY,
      nombre VARCHAR(100) NOT NULL,
      apellido VARCHAR(100) NOT NULL,
      fecha_nacimiento TEXT,
      telefono VARCHAR(20),
      email VARCHAR(150),
      foto_url TEXT,
      clase VARCHAR(50) DEFAULT 'Guia Mayor Aspirante',
      rol VARCHAR(50) DEFAULT 'Miembro',
      activo INTEGER DEFAULT 1,
      fecha_registro TEXT NOT NULL,
      usuario VARCHAR(50),
      password_hash TEXT,
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW()
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS eventos (
      id VARCHAR(36) PRIMARY KEY,
      titulo VARCHAR(200) NOT NULL,
      descripcion TEXT,
      fecha TEXT NOT NULL,
      hora TEXT,
      ubicacion VARCHAR(200),
      tipo VARCHAR(50) DEFAULT 'reunion',
      latitud DOUBLE PRECISION,
      longitud DOUBLE PRECISION,
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW()
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS unidades (
      id VARCHAR(36) PRIMARY KEY,
      nombre VARCHAR(100) NOT NULL,
      descripcion TEXT,
      activo INTEGER DEFAULT 1,
      fecha_creacion TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT NOW()
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS unidad_miembros (
      id VARCHAR(36) PRIMARY KEY,
      unidad_id VARCHAR(36) NOT NULL,
      miembro_id VARCHAR(36) NOT NULL,
      rol_en_unidad VARCHAR(50) DEFAULT 'miembro',
      fecha_asignacion TEXT NOT NULL
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS asistencia (
      id VARCHAR(36) PRIMARY KEY,
      unidad_id VARCHAR(36) NOT NULL,
      miembro_id VARCHAR(36) NOT NULL,
      fecha TEXT NOT NULL,
      dia_semana TEXT,
      puntualidad INTEGER DEFAULT 0,
      panoleta INTEGER DEFAULT 0,
      biblia INTEGER DEFAULT 0,
      cuota INTEGER DEFAULT 0,
      registrado_por VARCHAR(36),
      fecha_registro TEXT
    )
  `;

  await sql`
    CREATE TABLE IF NOT EXISTS audit_log (
      id VARCHAR(36) PRIMARY KEY,
      accion VARCHAR(50) NOT NULL,
      tabla VARCHAR(50),
      registro_id VARCHAR(36),
      descripcion TEXT,
      usuario_id VARCHAR(36),
      usuario_nombre VARCHAR(100),
      fecha TEXT NOT NULL
    )
  `;

  return { ok: true };
}

module.exports = { sql, initDatabase };
