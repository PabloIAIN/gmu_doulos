const { sql } = require('./_db');
const { verificarApiKey, handleOptions } = require('./_auth');

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;

  try {
    if (req.method === 'GET') {
      const { codigo, id } = req.query;

      // Verificar código de acceso (sin auth) - para onboarding
      if (codigo) {
        const rows = await sql`SELECT id, nombre, iglesia, ciudad, pais, ministerios, plan, max_miembros, activo FROM clubes WHERE codigo_acceso = ${codigo} AND activo = 1`;
        if (rows.length === 0) return res.status(404).json({ error: 'Código de acceso inválido' });
        return res.status(200).json({ ok: true, data: rows[0] });
      }

      // Obtener datos del club por ID (con auth)
      if (id) {
        if (!verificarApiKey(req, res)) return;
        const rows = await sql`SELECT * FROM clubes WHERE id = ${id}`;
        if (rows.length === 0) return res.status(404).json({ error: 'Club no encontrado' });
        return res.status(200).json({ ok: true, data: rows[0] });
      }

      return res.status(400).json({ error: 'Se requiere codigo o id' });
    }

    if (req.method === 'POST') {
      // Crear club - requiere SuperAdmin key
      const superKey = req.headers['x-superadmin-key'];
      if (!superKey || superKey !== process.env.SUPER_ADMIN_KEY) {
        return res.status(403).json({ error: 'Se requiere clave de super administrador' });
      }

      const { id, nombre, iglesia, ciudad, pais, asociacion, union_campo, codigo_acceso, ministerios, plan, max_miembros } = req.body;
      if (!id || !nombre || !iglesia || !ciudad || !codigo_acceso) {
        return res.status(400).json({ error: 'id, nombre, iglesia, ciudad y codigo_acceso son requeridos' });
      }

      await sql`
        INSERT INTO clubes (id, nombre, iglesia, ciudad, pais, asociacion, union_campo, codigo_acceso, ministerios, plan, max_miembros)
        VALUES (${id}, ${nombre}, ${iglesia}, ${ciudad}, ${pais||'México'}, ${asociacion||null}, ${union_campo||null}, ${codigo_acceso}, ${ministerios||'gm'}, ${plan||'gratis'}, ${max_miembros||20})
        ON CONFLICT (id) DO UPDATE SET nombre=EXCLUDED.nombre, iglesia=EXCLUDED.iglesia, ciudad=EXCLUDED.ciudad, ministerios=EXCLUDED.ministerios, plan=EXCLUDED.plan, max_miembros=EXCLUDED.max_miembros, updated_at=NOW()`;

      return res.status(201).json({ ok: true, id });
    }

    if (req.method === 'PUT') {
      if (!verificarApiKey(req, res)) return;
      const { id } = req.query;
      if (!id) return res.status(400).json({ error: 'id es requerido' });
      const { nombre, iglesia, ciudad, ministerios, plan, max_miembros } = req.body;
      await sql`UPDATE clubes SET nombre=COALESCE(${nombre||null},nombre), iglesia=COALESCE(${iglesia||null},iglesia), ciudad=COALESCE(${ciudad||null},ciudad), ministerios=COALESCE(${ministerios||null},ministerios), plan=COALESCE(${plan||null},plan), max_miembros=COALESCE(${max_miembros||null},max_miembros), updated_at=NOW() WHERE id=${id}`;
      return res.status(200).json({ ok: true, id });
    }

    return res.status(405).json({ error: 'Método no permitido' });
  } catch (error) {
    console.error('Error en /api/clubes:', error);
    return res.status(500).json({ error: error.message });
  }
};
