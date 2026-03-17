const { sql } = require('./_db');
const { handleOptions } = require('./_auth');
const crypto = require('crypto');

const SALT = 'gmu_doulos_salt_2025_';

function hashPassword(password) {
  return crypto.createHash('sha256').update(SALT + password).digest('hex');
}

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;

  try {
    if (req.method === 'POST') {
      const { usuario, password } = req.body;
      if (!usuario || !password) return res.status(400).json({ error: 'usuario y password son requeridos' });
      const passwordHash = hashPassword(password);
      const rows = await sql`SELECT id, nombre, apellido, rol, clase, email, telefono, foto_url FROM miembros WHERE usuario=${usuario} AND password_hash=${passwordHash} AND activo=1`;
      if (rows.length === 0) return res.status(401).json({ error: 'Credenciales inválidas' });
      return res.status(200).json({ ok: true, data: rows[0] });
    }

    if (req.method === 'GET') {
      return res.status(200).json({ status: 'ok', endpoint: 'auth' });
    }

    return res.status(405).json({ error: 'Método no permitido' });
  } catch (error) {
    console.error('Error en /api/auth:', error);
    return res.status(500).json({ error: error.message });
  }
};
