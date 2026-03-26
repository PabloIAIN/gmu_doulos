const { sql } = require('./_db');
const { handleOptions, checkRateLimit } = require('./_auth');
const crypto = require('crypto');
const bcrypt = require('bcryptjs');

const SALT = 'gmu_doulos_salt_2025_';

function sha256Hash(password) {
  return crypto.createHash('sha256').update(SALT + password).digest('hex');
}

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;
  if (!checkRateLimit(req, res, 10)) return; // 10 login attempts per minute

  try {
    if (req.method === 'POST') {
      const { usuario, password } = req.body;
      if (!usuario || !password) return res.status(400).json({ error: 'usuario y password son requeridos' });

      const rows = await sql`SELECT id, nombre, apellido, rol, clase, email, telefono, foto_url, password_hash, club_id, ministerio FROM miembros WHERE usuario=${usuario} AND activo=1`;
      if (rows.length === 0) return res.status(401).json({ error: 'Credenciales inválidas' });

      const miembro = rows[0];
      const storedHash = miembro.password_hash;
      let authenticated = false;

      // Check if stored hash is SHA-256 (64 hex chars) or bcrypt ($2a$/$2b$)
      if (storedHash && storedHash.startsWith('$2')) {
        // bcrypt hash
        authenticated = await bcrypt.compare(password, storedHash);
      } else if (storedHash && storedHash.length === 64) {
        // Legacy SHA-256 hash - verify and migrate to bcrypt
        const sha256 = sha256Hash(password);
        if (sha256 === storedHash) {
          authenticated = true;
          // Migrate to bcrypt
          const bcryptHash = await bcrypt.hash(password, 10);
          await sql`UPDATE miembros SET password_hash = ${bcryptHash}, updated_at = NOW() WHERE id = ${miembro.id}`;
        }
      }

      if (!authenticated) return res.status(401).json({ error: 'Credenciales inválidas' });

      // Remove password_hash from response
      delete miembro.password_hash;
      return res.status(200).json({ ok: true, data: miembro });
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
