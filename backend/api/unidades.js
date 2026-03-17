const { sql } = require('@vercel/postgres');
const { verificarApiKey, handleOptions } = require('../lib/auth');

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;
  if (!verificarApiKey(req, res)) return;

  try {
    switch (req.method) {
      case 'GET': {
        const { id } = req.query;

        if (id) {
          // Unidad con sus miembros
          const unidad = await sql`SELECT * FROM unidades WHERE id = ${id}`;
          if (unidad.rows.length === 0) {
            return res.status(404).json({ error: 'Unidad no encontrada' });
          }
          const miembros = await sql`
            SELECT um.*, m.nombre, m.apellido, m.rol, m.clase
            FROM unidad_miembros um
            JOIN miembros m ON m.id = um.miembro_id
            WHERE um.unidad_id = ${id}
            ORDER BY m.nombre
          `;
          return res.status(200).json({
            data: { ...unidad.rows[0], miembros: miembros.rows },
          });
        }

        const result = await sql`SELECT * FROM unidades ORDER BY nombre`;
        return res.status(200).json({ data: result.rows, total: result.rows.length });
      }

      case 'POST': {
        const { id, nombre, descripcion, activo, fecha_creacion } = req.body;
        if (!id || !nombre) {
          return res.status(400).json({ error: 'id y nombre son requeridos' });
        }

        await sql`
          INSERT INTO unidades (id, nombre, descripcion, activo, fecha_creacion)
          VALUES (${id}, ${nombre}, ${descripcion || null}, ${activo !== undefined ? activo : 1}, ${fecha_creacion || new Date().toISOString()})
          ON CONFLICT (id) DO UPDATE SET
            nombre = EXCLUDED.nombre, descripcion = EXCLUDED.descripcion,
            activo = EXCLUDED.activo
        `;

        return res.status(201).json({ ok: true, id });
      }

      case 'PUT': {
        const { id } = req.query;
        if (!id) return res.status(400).json({ error: 'id es requerido' });

        const { nombre, descripcion, activo } = req.body;
        await sql`
          UPDATE unidades SET
            nombre = COALESCE(${nombre || null}, nombre),
            descripcion = COALESCE(${descripcion || null}, descripcion),
            activo = COALESCE(${activo !== undefined ? activo : null}, activo)
          WHERE id = ${id}
        `;

        return res.status(200).json({ ok: true, id });
      }

      case 'DELETE': {
        const { id } = req.query;
        if (!id) return res.status(400).json({ error: 'id es requerido' });

        await sql`DELETE FROM unidad_miembros WHERE unidad_id = ${id}`;
        await sql`DELETE FROM unidades WHERE id = ${id}`;
        return res.status(200).json({ ok: true, deleted: id });
      }

      default:
        return res.status(405).json({ error: 'Método no permitido' });
    }
  } catch (error) {
    console.error('Error en /api/unidades:', error);
    return res.status(500).json({ error: error.message });
  }
};
