-- =============================================
-- GMU Doulos - Database Schema (PostgreSQL)
-- Backend para la aplicación móvil
-- =============================================

-- Tabla de miembros
CREATE TABLE IF NOT EXISTS miembros (
  id VARCHAR(36) PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  fecha_nacimiento TEXT,
  telefono VARCHAR(20),
  email VARCHAR(150),
  foto_url TEXT,
  clase VARCHAR(50) DEFAULT 'Guía Mayor Aspirante',
  rol VARCHAR(50) DEFAULT 'Miembro',
  activo INTEGER DEFAULT 1,
  fecha_registro TEXT NOT NULL,
  usuario VARCHAR(50),
  password_hash TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de eventos
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
);

-- Tabla de unidades
CREATE TABLE IF NOT EXISTS unidades (
  id VARCHAR(36) PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  activo INTEGER DEFAULT 1,
  fecha_creacion TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de asignación miembro-unidad
CREATE TABLE IF NOT EXISTS unidad_miembros (
  id VARCHAR(36) PRIMARY KEY,
  unidad_id VARCHAR(36) NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
  miembro_id VARCHAR(36) NOT NULL REFERENCES miembros(id) ON DELETE CASCADE,
  rol_en_unidad VARCHAR(50) DEFAULT 'miembro',
  fecha_asignacion TEXT NOT NULL,
  UNIQUE(unidad_id, miembro_id)
);

-- Tabla de asistencia
CREATE TABLE IF NOT EXISTS asistencia (
  id VARCHAR(36) PRIMARY KEY,
  unidad_id VARCHAR(36) NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
  miembro_id VARCHAR(36) NOT NULL REFERENCES miembros(id) ON DELETE CASCADE,
  fecha TEXT NOT NULL,
  dia_semana TEXT,
  puntualidad INTEGER DEFAULT 0,
  panoleta INTEGER DEFAULT 0,
  biblia INTEGER DEFAULT 0,
  cuota INTEGER DEFAULT 0,
  registrado_por VARCHAR(36),
  fecha_registro TEXT,
  UNIQUE(unidad_id, miembro_id, fecha)
);

-- Tabla de especialidades
CREATE TABLE IF NOT EXISTS especialidades (
  id VARCHAR(36) PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  categoria VARCHAR(100),
  nivel VARCHAR(50),
  requisitos TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de progreso de especialidades por miembro
CREATE TABLE IF NOT EXISTS miembro_especialidad (
  id VARCHAR(36) PRIMARY KEY,
  miembro_id VARCHAR(36) NOT NULL REFERENCES miembros(id) ON DELETE CASCADE,
  especialidad_id VARCHAR(36) NOT NULL REFERENCES especialidades(id) ON DELETE CASCADE,
  fecha_inicio TEXT,
  requisitos_completados TEXT DEFAULT '[]',
  completado INTEGER DEFAULT 0,
  fecha_completado TEXT,
  UNIQUE(miembro_id, especialidad_id)
);

-- Carpeta de investidura - secciones
CREATE TABLE IF NOT EXISTS carpeta_secciones (
  id VARCHAR(36) PRIMARY KEY,
  numero INTEGER NOT NULL,
  nombre VARCHAR(200) NOT NULL,
  descripcion TEXT
);

-- Carpeta de investidura - requisitos
CREATE TABLE IF NOT EXISTS carpeta_requisitos (
  id VARCHAR(36) PRIMARY KEY,
  seccion_id VARCHAR(36) NOT NULL REFERENCES carpeta_secciones(id) ON DELETE CASCADE,
  nombre VARCHAR(300) NOT NULL,
  descripcion TEXT,
  orden INTEGER DEFAULT 0
);

-- Carpeta de investidura - progreso
CREATE TABLE IF NOT EXISTS carpeta_progreso (
  id VARCHAR(36) PRIMARY KEY,
  miembro_id VARCHAR(36) NOT NULL REFERENCES miembros(id) ON DELETE CASCADE,
  requisito_id VARCHAR(36) NOT NULL REFERENCES carpeta_requisitos(id) ON DELETE CASCADE,
  completado INTEGER DEFAULT 0,
  fecha_completado TEXT,
  completado_por VARCHAR(36),
  aprobado INTEGER DEFAULT 0,
  fecha_aprobado TEXT,
  aprobado_por VARCHAR(36),
  estado VARCHAR(20) DEFAULT 'pendiente',
  notas TEXT,
  evidencia_path TEXT,
  comentario_devolucion TEXT,
  fecha_envio TEXT,
  UNIQUE(miembro_id, requisito_id)
);

-- Tabla de audit log
CREATE TABLE IF NOT EXISTS audit_log (
  id VARCHAR(36) PRIMARY KEY,
  accion VARCHAR(50) NOT NULL,
  tabla VARCHAR(50),
  registro_id VARCHAR(36),
  descripcion TEXT,
  usuario_id VARCHAR(36),
  usuario_nombre VARCHAR(100),
  fecha TEXT NOT NULL
);

-- Tabla de configuración
CREATE TABLE IF NOT EXISTS configuracion (
  clave VARCHAR(100) PRIMARY KEY,
  valor TEXT
);

-- Índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_asistencia_fecha ON asistencia(fecha);
CREATE INDEX IF NOT EXISTS idx_asistencia_miembro ON asistencia(miembro_id);
CREATE INDEX IF NOT EXISTS idx_asistencia_unidad ON asistencia(unidad_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_fecha ON audit_log(fecha);
CREATE INDEX IF NOT EXISTS idx_carpeta_progreso_miembro ON carpeta_progreso(miembro_id);
CREATE INDEX IF NOT EXISTS idx_miembros_rol ON miembros(rol);
CREATE INDEX IF NOT EXISTS idx_miembros_activo ON miembros(activo);
