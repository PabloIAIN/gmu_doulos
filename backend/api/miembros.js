const { sql } = require('@vercel/postgres');
const { verificarApiKey, handleOptions } = require('../lib/auth');

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;
  if (!verificarApiKey(req, res)) return;

  try {
    switch (req.method) {
      // ── GET: Listar miembros o uno por ID ──
      case 'GET': {
        const { id, rol, activo } = req.query;

        if (id) {
          const result = await sql`
            SELECT * FROM miembros WHERE id = ${id}
          `;
          if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Miembro no encontrado' });
          }
          return res.status(200).json({ data: result.rows[0] });
        }

        // Filtros opcionales
        let result;
        if (rol && activo !== undefined) {
          result = await sql`
            SELECT * FROM miembros WHERE rol = ${rol} AND activo = ${parseInt(activo)} ORDER BY nombre
          `;
        } else if (rol) {
          result = await sql`
            SELECT * FROM miembros WHERE rol = ${rol} ORDER BY nombre
          `;
        } else if (activo !== undefined) {
          result = await sql`
            SELECT * FROM miembros WHERE activo = ${parseInt(activo)} ORDER BY nombre
          `;
        } else {
          result = await sql`
            SELECT * FROM miembros ORDER BY nombre
          `;
        }

        return res.status(200).json({
          data: result.rows,
          total: result.rows.length,
        });
      }

      // ── POST: Crear miembro ──
      case 'POST': {
        const { id, nombre, apellido, fecha_nacimiento, telefono, email, foto_url, clase, rol, activo, fecha_registro, usuario, password_hash } = req.body;

        if (!id || !nombre || !apellido) {
          return res.status(400).json({ error: 'id, nombre y apellido son requeridos' });
        }

        await sql`
          INSERT INTO miembros (id, nombre, apellido, fecha_nacimiento, telefono, email, foto_url, clase, rol, activo, fecha_registro, usuario, password_hash)
          VALUES (${id}, ${nombre}, ${apellido}, ${fecha_nacimiento || null}, ${telefono || null}, ${email || null}, ${foto_url || null}, ${clase || 'Guía Mayor Aspirante'}, ${rol || 'Miembro'}, ${activo !== undefined ? activo : 1}, ${fecha_registro || new Date().toISOString()}, ${usuario || null}, ${password_hash || null})
          ON CONFLICT (id) DO UPDATE SET
            nombre = EXCLUDED.nombre,
            apellido = EXCLUDED.apellido,
            fecha_nacimiento = EXCLUDED.fecha_nacimiento,
            telefono = EXCLUDED.telefono,
            email = EXCLUDED.email,
            foto_url = EXCLUDED.foto_url,
            clase = EXCLUDED.clase,
            rol = EXCLUDED.rol,
            activo = EXCLUDED.activo,
            usuario = EXCLUDED.usuario,
            password_hash = EXCLUDED.password_hash,
            updated_at = NOW()
        `;

        return res.status(201).json({ ok: true, id });
      }

      // ── PUT: Actualizar miembro ──
      case 'PUT': {
        const { id } = req.query;
        if (!id) return res.status(400).json({ error: 'id es requerido en query params' });

        const fields = req.body;
        const { nombre, apellido, fecha_nacimiento, telefono, email, foto_url, clase, rol, activo, usuario, password_hash } = fields;

        await sql`
          UPDATE miembros SET
            nombre = COALESCE(${nombre || null}, nombre),
            apellido = COALESCE(${apellido || null}, apellido),
            fecha_nacimiento = COALESCE(${fecha_nacimiento || null}, fecha_nacimiento),
            telefono = COALESCE(${telefono || null}, telefono),
            email = COALESCE(${email || null}, email),
            foto_url = COALESCE(${foto_url || null}, foto_url),
            clase = COALESCE(${clase || null}, clase),
            rol = COALESCE(${rol || null}, rol),
            activo = COALESCE(${activo !== undefined ? activo : null}, activo),
            usuario = COALESCE(${usuario || null}, usuario),
            password_hash = COALESCE(${password_hash || null}, password_hash),
            updated_at = NOW()
          WHERE id = ${id}
        `;

        return res.status(200).json({ ok: true, id });
      }

      // ── DELETE: Eliminar miembro ──
      case 'DELETE': {
        const { id } = req.query;
        if (!id) return res.status(400).json({ error: 'id es requerido' });

        await sql`DELETE FROM miembros WHERE id = ${id}`;
        return res.status(200).json({ ok: true, deleted: id });
      }

      default:
        return res.status(405).json({ error: 'Método no permitido' });
    }
  } catch (error) {
    console.error('Error en /api/miembros:', error);
    return res.status(500).json({ error: error.message });
  }
};
