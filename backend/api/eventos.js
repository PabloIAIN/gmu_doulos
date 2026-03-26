const { sql } = require('./_db');
const { verificarApiKey, handleOptions } = require('./_auth');

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;
  if (!verificarApiKey(req, res)) return;

  try {
    switch (req.method) {
      case 'GET': {
        const { id, tipo, club_id, ministerio } = req.query;
        if (id) {
          const rows = await sql`SELECT * FROM eventos WHERE id = ${id}`;
          if (rows.length === 0) return res.status(404).json({ error: 'Evento no encontrado' });
          return res.status(200).json({ data: rows[0] });
        }
        let rows;
        if (club_id) {
          rows = await sql`SELECT * FROM eventos WHERE club_id = ${club_id} ORDER BY fecha DESC`;
        } else if (tipo) {
          rows = await sql`SELECT * FROM eventos WHERE tipo = ${tipo} ORDER BY fecha DESC`;
        } else {
          rows = await sql`SELECT * FROM eventos ORDER BY fecha DESC`;
        }
        return res.status(200).json({ data: rows, total: rows.length });
      }

      case 'POST': {
        const { id, titulo, descripcion, fecha, hora, ubicacion, tipo, latitud, longitud, club_id, ministerio } = req.body;
        if (!id || !titulo || !fecha) return res.status(400).json({ error: 'id, titulo y fecha son requeridos' });
        await sql`
          INSERT INTO eventos (id,titulo,descripcion,fecha,hora,ubicacion,tipo,latitud,longitud,club_id,ministerio)
          VALUES (${id},${titulo},${descripcion||null},${fecha},${hora||null},${ubicacion||null},${tipo||'reunion'},${latitud||null},${longitud||null},${club_id||null},${ministerio||'todos'})
          ON CONFLICT (id) DO UPDATE SET titulo=EXCLUDED.titulo,descripcion=EXCLUDED.descripcion,fecha=EXCLUDED.fecha,hora=EXCLUDED.hora,ubicacion=EXCLUDED.ubicacion,tipo=EXCLUDED.tipo,latitud=EXCLUDED.latitud,longitud=EXCLUDED.longitud,club_id=EXCLUDED.club_id,ministerio=EXCLUDED.ministerio,updated_at=NOW()`;
        return res.status(201).json({ ok: true, id });
      }

      case 'PUT': {
        const { id } = req.query;
        if (!id) return res.status(400).json({ error: 'id es requerido' });
        const { titulo, descripcion, fecha, hora, ubicacion, tipo, latitud, longitud } = req.body;
        await sql`UPDATE eventos SET titulo=COALESCE(${titulo||null},titulo),descripcion=COALESCE(${descripcion||null},descripcion),fecha=COALESCE(${fecha||null},fecha),hora=COALESCE(${hora||null},hora),ubicacion=COALESCE(${ubicacion||null},ubicacion),tipo=COALESCE(${tipo||null},tipo),latitud=COALESCE(${latitud||null},latitud),longitud=COALESCE(${longitud||null},longitud),updated_at=NOW() WHERE id=${id}`;
        return res.status(200).json({ ok: true, id });
      }

      case 'DELETE': {
        const { id } = req.query;
        if (!id) return res.status(400).json({ error: 'id es requerido' });
        await sql`DELETE FROM eventos WHERE id = ${id}`;
        return res.status(200).json({ ok: true, deleted: id });
      }

      default:
        return res.status(405).json({ error: 'Método no permitido' });
    }
  } catch (error) {
    console.error('Error en /api/eventos:', error);
    return res.status(500).json({ error: error.message });
  }
};
