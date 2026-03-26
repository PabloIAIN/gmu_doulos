const { sql } = require('./_db');
const { verificarApiKey, handleOptions, checkRateLimit } = require('./_auth');
const crypto = require('crypto');

const SALT = 'gmu_doulos_salt_2025_';

function hashPassword(password) {
  return crypto.createHash('sha256').update(SALT + password).digest('hex');
}

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;
  if (!verificarApiKey(req, res)) return;
  if (!checkRateLimit(req, res, 10)) return;

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido' });
  }

  try {
    const { club_id, miembro_id, nueva_password, solicitante_id } = req.body;

    if (!club_id || !miembro_id || !nueva_password || !solicitante_id) {
      return res.status(400).json({ error: 'club_id, miembro_id, nueva_password y solicitante_id son requeridos' });
    }

    // Verificar que el solicitante es Director del club
    const solicitante = await sql`SELECT rol, club_id FROM miembros WHERE id = ${solicitante_id} AND club_id = ${club_id} AND activo = 1`;
    if (solicitante.length === 0) {
      return res.status(403).json({ error: 'Solicitante no encontrado en este club' });
    }

    const rolSolicitante = solicitante[0].rol;
    const esDirector = rolSolicitante.startsWith('Director');
    if (!esDirector) {
      return res.status(403).json({ error: 'Solo un Director puede resetear contraseñas' });
    }

    // Resetear contraseña
    const passwordHash = hashPassword(nueva_password);
    await sql`UPDATE miembros SET password_hash = ${passwordHash}, updated_at = NOW() WHERE id = ${miembro_id} AND club_id = ${club_id}`;

    return res.status(200).json({ ok: true, mensaje: 'Contraseña actualizada correctamente' });
  } catch (error) {
    console.error('Error en /api/reset-password:', error);
    return res.status(500).json({ error: error.message });
  }
};
