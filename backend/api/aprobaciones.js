const { sql } = require('./_db');
const { verificarApiKey, handleOptions } = require('./_auth');

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;
  if (!verificarApiKey(req, res)) return;

  try {
    if (req.method === 'GET') {
      const { club_id, ministerio } = req.query;
      if (!club_id) return res.status(400).json({ error: 'club_id es requerido' });

      let rows;
      if (ministerio && ministerio !== 'todos') {
        rows = await sql`SELECT id, nombre, apellido, rol, ministerio, clase_ministerio, fecha_registro FROM miembros WHERE club_id = ${club_id} AND ministerio = ${ministerio} AND activo = 0 ORDER BY fecha_registro DESC`;
      } else {
        rows = await sql`SELECT id, nombre, apellido, rol, ministerio, clase_ministerio, fecha_registro FROM miembros WHERE club_id = ${club_id} AND activo = 0 ORDER BY fecha_registro DESC`;
      }

      return res.status(200).json({ data: rows, total: rows.length });
    }

    if (req.method === 'POST') {
      const { club_id, miembro_id, accion, rol } = req.body;
      if (!club_id || !miembro_id || !accion) {
        return res.status(400).json({ error: 'club_id, miembro_id y accion son requeridos' });
      }

      if (accion === 'rechazar') {
        await sql`DELETE FROM miembros WHERE id = ${miembro_id} AND club_id = ${club_id} AND activo = 0`;
        return res.status(200).json({ ok: true, accion: 'rechazado' });
      }

      if (accion === 'aprobar') {
        if (rol) {
          await sql`UPDATE miembros SET activo = 1, rol = ${rol} WHERE id = ${miembro_id} AND club_id = ${club_id}`;
        } else {
          await sql`UPDATE miembros SET activo = 1 WHERE id = ${miembro_id} AND club_id = ${club_id}`;
        }
        return res.status(200).json({ ok: true, accion: 'aprobado' });
      }

      return res.status(400).json({ error: 'accion debe ser "aprobar" o "rechazar"' });
    }

    return res.status(405).json({ error: 'Método no permitido' });
  } catch (error) {
    console.error('Error en /api/aprobaciones:', error);
    return res.status(500).json({ error: error.message });
  }
};
