const { sql } = require('./_db');
const { handleOptions } = require('./_auth');
const crypto = require('crypto');

const SALT = 'gmu_doulos_salt_2025_';

function hashPassword(password) {
  return crypto.createHash('sha256').update(SALT + password).digest('hex');
}

// Mapea ministerio a rol de Director
function getRolDirector(ministerio) {
  switch (ministerio) {
    case 'gm': return 'Director GM';
    case 'conq': return 'Director Conq';
    case 'av': return 'Director Aventureros';
    case 'coordinador': return 'Coordinador General';
    default: return null;
  }
}

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido' });
  }

  try {
    const { codigo_acceso, ministerio, nombre, apellido, usuario, password } = req.body;

    if (!codigo_acceso || !ministerio || !nombre || !apellido || !usuario || !password) {
      return res.status(400).json({ error: 'Todos los campos son requeridos: codigo_acceso, ministerio, nombre, apellido, usuario, password' });
    }

    // 1. Verificar código de acceso
    const clubRows = await sql`SELECT * FROM clubes WHERE codigo_acceso = ${codigo_acceso} AND activo = 1`;
    if (clubRows.length === 0) {
      return res.status(404).json({ error: 'Código de acceso inválido o club inactivo' });
    }
    const club = clubRows[0];

    // 2. Verificar que el ministerio esté habilitado en el club
    if (ministerio !== 'coordinador') {
      const ministeriosClub = club.ministerios.split(',').map(m => m.trim());
      if (!ministeriosClub.includes(ministerio)) {
        return res.status(400).json({ error: `El ministerio "${ministerio}" no está habilitado en este club` });
      }
    }

    // 3. Determinar el rol
    const rol = getRolDirector(ministerio);
    if (!rol) {
      return res.status(400).json({ error: 'Ministerio inválido. Usa: gm, conq, av, o coordinador' });
    }

    // 4. Verificar que no exista ya un Director para ese ministerio (excepto Coordinador)
    if (ministerio !== 'coordinador') {
      const existente = await sql`SELECT id FROM miembros WHERE club_id = ${club.id} AND rol = ${rol} AND activo = 1`;
      if (existente.length > 0) {
        return res.status(409).json({ error: `Ya existe un ${rol} para este club` });
      }
    }

    // 5. Verificar que el usuario no exista
    const usuarioExiste = await sql`SELECT id FROM miembros WHERE usuario = ${usuario}`;
    if (usuarioExiste.length > 0) {
      return res.status(409).json({ error: 'El nombre de usuario ya está en uso' });
    }

    // 6. Crear el miembro Director
    const id = Date.now().toString() + Math.random().toString(36).substring(2, 8);
    const passwordHash = hashPassword(password);
    const claseDefault = ministerio === 'gm' ? 'Guía Mayor Avanzado' : '';

    await sql`
      INSERT INTO miembros (id, nombre, apellido, clase, rol, activo, fecha_registro, usuario, password_hash, club_id, ministerio)
      VALUES (${id}, ${nombre}, ${apellido}, ${claseDefault}, ${rol}, 1, ${new Date().toISOString()}, ${usuario}, ${passwordHash}, ${club.id}, ${ministerio === 'coordinador' ? 'todos' : ministerio})`;

    // 7. Retornar datos
    return res.status(201).json({
      ok: true,
      club: { id: club.id, nombre: club.nombre, iglesia: club.iglesia, ciudad: club.ciudad, ministerios: club.ministerios },
      miembro: { id, nombre, apellido, rol, ministerio },
      api_key: process.env.API_KEY,
    });
  } catch (error) {
    console.error('Error en /api/onboarding:', error);
    return res.status(500).json({ error: error.message });
  }
};
