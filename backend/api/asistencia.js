const { sql } = require('./_db');
const { verificarApiKey, handleOptions } = require('./_auth');

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;
  if (!verificarApiKey(req, res)) return;

  try {
    switch (req.method) {
      case 'GET': {
        const { unidad_id, miembro_id, fecha } = req.query;
        let rows;
        if (unidad_id && fecha) {
          rows = await sql`SELECT a.*, m.nombre, m.apellido FROM asistencia a JOIN miembros m ON m.id=a.miembro_id WHERE a.unidad_id=${unidad_id} AND a.fecha=${fecha} ORDER BY m.nombre`;
        } else if (miembro_id) {
          rows = await sql`SELECT a.*, u.nombre as unidad_nombre FROM asistencia a JOIN unidades u ON u.id=a.unidad_id WHERE a.miembro_id=${miembro_id} ORDER BY a.fecha DESC`;
        } else if (unidad_id) {
          rows = await sql`SELECT a.*, m.nombre, m.apellido FROM asistencia a JOIN miembros m ON m.id=a.miembro_id WHERE a.unidad_id=${unidad_id} ORDER BY a.fecha DESC, m.nombre`;
        } else {
          rows = await sql`SELECT a.*, m.nombre, m.apellido FROM asistencia a JOIN miembros m ON m.id=a.miembro_id ORDER BY a.fecha DESC LIMIT 100`;
        }
        return res.status(200).json({ data: rows, total: rows.length });
      }

      case 'POST': {
        const { id, unidad_id, miembro_id, fecha, dia_semana, puntualidad, panoleta, biblia, cuota, registrado_por, fecha_registro } = req.body;
        if (!id || !unidad_id || !miembro_id || !fecha) return res.status(400).json({ error: 'id, unidad_id, miembro_id y fecha son requeridos' });
        await sql`
          INSERT INTO asistencia (id,unidad_id,miembro_id,fecha,dia_semana,puntualidad,panoleta,biblia,cuota,registrado_por,fecha_registro)
          VALUES (${id},${unidad_id},${miembro_id},${fecha},${dia_semana||null},${puntualidad||0},${panoleta||0},${biblia||0},${cuota||0},${registrado_por||null},${fecha_registro||new Date().toISOString()})
          ON CONFLICT (id) DO UPDATE SET puntualidad=EXCLUDED.puntualidad,panoleta=EXCLUDED.panoleta,biblia=EXCLUDED.biblia,cuota=EXCLUDED.cuota,registrado_por=EXCLUDED.registrado_por`;
        return res.status(201).json({ ok: true, id });
      }

      case 'PUT': {
        const { registros } = req.body;
        if (!registros || !Array.isArray(registros)) return res.status(400).json({ error: 'registros (array) es requerido' });
        let insertados = 0;
        for (const r of registros) {
          await sql`
            INSERT INTO asistencia (id,unidad_id,miembro_id,fecha,dia_semana,puntualidad,panoleta,biblia,cuota,registrado_por,fecha_registro)
            VALUES (${r.id},${r.unidad_id},${r.miembro_id},${r.fecha},${r.dia_semana||null},${r.puntualidad||0},${r.panoleta||0},${r.biblia||0},${r.cuota||0},${r.registrado_por||null},${r.fecha_registro||new Date().toISOString()})
            ON CONFLICT (id) DO UPDATE SET puntualidad=EXCLUDED.puntualidad,panoleta=EXCLUDED.panoleta,biblia=EXCLUDED.biblia,cuota=EXCLUDED.cuota`;
          insertados++;
        }
        return res.status(200).json({ ok: true, insertados });
      }

      case 'DELETE': {
        const { id } = req.query;
        if (!id) return res.status(400).json({ error: 'id es requerido' });
        await sql`DELETE FROM asistencia WHERE id = ${id}`;
        return res.status(200).json({ ok: true, deleted: id });
      }

      default:
        return res.status(405).json({ error: 'Método no permitido' });
    }
  } catch (error) {
    console.error('Error en /api/asistencia:', error);
    return res.status(500).json({ error: error.message });
  }
};
