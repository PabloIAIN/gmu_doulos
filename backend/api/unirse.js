const { sql } = require('./_db');
const { handleOptions } = require('./_auth');
const crypto = require('crypto');

const SALT = 'gmu_doulos_salt_2025_';

function hashPassword(password) {
  return crypto.createHash('sha256').update(SALT + password).digest('hex');
}

// Mapea ministerio + tipo a rol final
function getRolFinal(ministerio, tipoRol) {
  const mapa = {
    'gm-consejero': 'Consejero GM',
    'gm-miembro': 'Aspirante GM',
    'conq-consejero': 'Consejero Conq',
    'conq-miembro': 'Conquistador',
    'av-consejero': 'Consejero Aventureros',
    'av-miembro': 'Aventurero',
  };
  return mapa[`${ministerio}-${tipoRol}`] || null;
}

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido' });
  }

  try {
    const { club_id, ministerio, nombre, apellido, fecha_nacimiento, telefono, email, usuario, password, rol_solicitado, clase_ministerio } = req.body;

    if (!club_id || !ministerio || !nombre || !apellido || !usuario || !password || !rol_solicitado) {
      return res.status(400).json({ error: 'Campos requeridos: club_id, ministerio, nombre, apellido, usuario, password, rol_solicitado' });
    }

    // 1. Verificar club
    const clubRows = await sql`SELECT * FROM clubes WHERE id = ${club_id} AND activo = 1`;
    if (clubRows.length === 0) {
      return res.status(404).json({ error: 'Club no encontrado o inactivo' });
    }
    const club = clubRows[0];

    // 2. Verificar ministerio habilitado
    const ministeriosClub = club.ministerios.split(',').map(m => m.trim());
    if (!ministeriosClub.includes(ministerio)) {
      return res.status(400).json({ error: `El ministerio "${ministerio}" no está habilitado en este club` });
    }

    // 3. Verificar límite de miembros
    const countRows = await sql`SELECT COUNT(*) as total FROM miembros WHERE club_id = ${club_id} AND activo = 1`;
    const totalMiembros = parseInt(countRows[0].total);
    if (totalMiembros >= club.max_miembros) {
      return res.status(403).json({ error: `El club ha alcanzado el límite de ${club.max_miembros} miembros` });
    }

    // 4. Verificar usuario único
    const usuarioExiste = await sql`SELECT id FROM miembros WHERE usuario = ${usuario}`;
    if (usuarioExiste.length > 0) {
      return res.status(409).json({ error: 'El nombre de usuario ya está en uso' });
    }

    // 5. Determinar rol final
    const rol = getRolFinal(ministerio, rol_solicitado);
    if (!rol) {
      return res.status(400).json({ error: 'Combinación inválida de ministerio y rol' });
    }

    // 6. Crear miembro con activo = 0 (pendiente aprobación)
    const id = Date.now().toString() + Math.random().toString(36).substring(2, 8);
    const passwordHash = hashPassword(password);

    await sql`
      INSERT INTO miembros (id, nombre, apellido, fecha_nacimiento, telefono, email, clase, rol, activo, fecha_registro, usuario, password_hash, club_id, ministerio, clase_ministerio)
      VALUES (${id}, ${nombre}, ${apellido}, ${fecha_nacimiento||null}, ${telefono||null}, ${email||null}, ${clase_ministerio||''}, ${rol}, 0, ${new Date().toISOString()}, ${usuario}, ${passwordHash}, ${club_id}, ${ministerio}, ${clase_ministerio||null})`;

    return res.status(201).json({
      ok: true,
      mensaje: 'Solicitud enviada. El Director debe aprobarte.',
      miembro_id: id,
    });
  } catch (error) {
    console.error('Error en /api/unirse:', error);
    return res.status(500).json({ error: error.message });
  }
};
