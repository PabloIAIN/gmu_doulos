const { sql } = require('./_db');
const { verificarApiKey, handleOptions } = require('./_auth');

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;
  if (!verificarApiKey(req, res)) return;

  try {
    if (req.method === 'POST') {
      const { miembros, eventos, unidades, unidad_miembros, asistencia, club_id } = req.body;
      const resultados = { miembros: 0, eventos: 0, unidades: 0, unidad_miembros: 0, asistencia: 0 };

      if (miembros && Array.isArray(miembros)) {
        for (const m of miembros) {
          await sql`
            INSERT INTO miembros (id,nombre,apellido,fecha_nacimiento,telefono,email,foto_url,clase,rol,activo,fecha_registro,usuario,password_hash,club_id,ministerio,clase_ministerio)
            VALUES (${m.id},${m.nombre},${m.apellido},${m.fecha_nacimiento||null},${m.telefono||null},${m.email||null},${m.foto_url||null},${m.clase||'Guía Mayor Aspirante'},${m.rol||'Miembro'},${m.activo!==undefined?m.activo:1},${m.fecha_registro||new Date().toISOString()},${m.usuario||null},${m.password_hash||null},${m.club_id||club_id||null},${m.ministerio||'gm'},${m.clase_ministerio||null})
            ON CONFLICT (id) DO UPDATE SET nombre=EXCLUDED.nombre,apellido=EXCLUDED.apellido,fecha_nacimiento=EXCLUDED.fecha_nacimiento,telefono=EXCLUDED.telefono,email=EXCLUDED.email,clase=EXCLUDED.clase,rol=EXCLUDED.rol,activo=EXCLUDED.activo,usuario=EXCLUDED.usuario,password_hash=EXCLUDED.password_hash,club_id=EXCLUDED.club_id,ministerio=EXCLUDED.ministerio,clase_ministerio=EXCLUDED.clase_ministerio,updated_at=NOW()`;
          resultados.miembros++;
        }
      }

      if (eventos && Array.isArray(eventos)) {
        for (const e of eventos) {
          await sql`
            INSERT INTO eventos (id,titulo,descripcion,fecha,hora,ubicacion,tipo,latitud,longitud,club_id,ministerio)
            VALUES (${e.id},${e.titulo},${e.descripcion||null},${e.fecha},${e.hora||null},${e.ubicacion||null},${e.tipo||'reunion'},${e.latitud||null},${e.longitud||null},${e.club_id||club_id||null},${e.ministerio||'todos'})
            ON CONFLICT (id) DO UPDATE SET titulo=EXCLUDED.titulo,descripcion=EXCLUDED.descripcion,fecha=EXCLUDED.fecha,hora=EXCLUDED.hora,ubicacion=EXCLUDED.ubicacion,tipo=EXCLUDED.tipo,club_id=EXCLUDED.club_id,ministerio=EXCLUDED.ministerio,updated_at=NOW()`;
          resultados.eventos++;
        }
      }

      if (unidades && Array.isArray(unidades)) {
        for (const u of unidades) {
          await sql`
            INSERT INTO unidades (id,nombre,descripcion,activo,fecha_creacion,club_id,ministerio) VALUES (${u.id},${u.nombre},${u.descripcion||null},${u.activo!==undefined?u.activo:1},${u.fecha_creacion||new Date().toISOString()},${u.club_id||club_id||null},${u.ministerio||'gm'})
            ON CONFLICT (id) DO UPDATE SET nombre=EXCLUDED.nombre,descripcion=EXCLUDED.descripcion,activo=EXCLUDED.activo,club_id=EXCLUDED.club_id,ministerio=EXCLUDED.ministerio`;
          resultados.unidades++;
        }
      }

      if (unidad_miembros && Array.isArray(unidad_miembros)) {
        for (const um of unidad_miembros) {
          await sql`
            INSERT INTO unidad_miembros (id,unidad_id,miembro_id,rol_en_unidad,fecha_asignacion) VALUES (${um.id},${um.unidad_id},${um.miembro_id},${um.rol_en_unidad||'miembro'},${um.fecha_asignacion||new Date().toISOString()})
            ON CONFLICT (id) DO UPDATE SET rol_en_unidad=EXCLUDED.rol_en_unidad`;
          resultados.unidad_miembros++;
        }
      }

      if (asistencia && Array.isArray(asistencia)) {
        for (const a of asistencia) {
          await sql`
            INSERT INTO asistencia (id,unidad_id,miembro_id,fecha,dia_semana,puntualidad,panoleta,biblia,cuota,registrado_por,fecha_registro,club_id)
            VALUES (${a.id},${a.unidad_id},${a.miembro_id},${a.fecha},${a.dia_semana||null},${a.puntualidad||0},${a.panoleta||0},${a.biblia||0},${a.cuota||0},${a.registrado_por||null},${a.fecha_registro||new Date().toISOString()},${a.club_id||club_id||null})
            ON CONFLICT (id) DO UPDATE SET puntualidad=EXCLUDED.puntualidad,panoleta=EXCLUDED.panoleta,biblia=EXCLUDED.biblia,cuota=EXCLUDED.cuota,club_id=EXCLUDED.club_id`;
          resultados.asistencia++;
        }
      }

      return res.status(200).json({ ok: true, sincronizados: resultados });
    }

    if (req.method === 'GET') {
      const { club_id, ministerio } = req.query;
      let miembros, eventos, unidades, unidad_miembros, asistencia;

      if (club_id) {
        miembros = await sql`SELECT * FROM miembros WHERE club_id = ${club_id} ORDER BY nombre`;
        eventos = await sql`SELECT * FROM eventos WHERE club_id = ${club_id} ORDER BY fecha DESC`;
        unidades = await sql`SELECT * FROM unidades WHERE club_id = ${club_id} ORDER BY nombre`;
        const unidadIds = unidades.map(u => u.id);
        if (unidadIds.length > 0) {
          unidad_miembros = await sql`SELECT * FROM unidad_miembros WHERE unidad_id = ANY(${unidadIds})`;
        } else {
          unidad_miembros = [];
        }
        asistencia = await sql`SELECT * FROM asistencia WHERE club_id = ${club_id} ORDER BY fecha DESC`;
      } else {
        miembros = await sql`SELECT * FROM miembros ORDER BY nombre`;
        eventos = await sql`SELECT * FROM eventos ORDER BY fecha DESC`;
        unidades = await sql`SELECT * FROM unidades ORDER BY nombre`;
        unidad_miembros = await sql`SELECT * FROM unidad_miembros`;
        asistencia = await sql`SELECT * FROM asistencia ORDER BY fecha DESC`;
      }

      return res.status(200).json({
        data: { miembros, eventos, unidades, unidad_miembros, asistencia },
        timestamp: new Date().toISOString(),
      });
    }

    return res.status(405).json({ error: 'Método no permitido' });
  } catch (error) {
    console.error('Error en /api/sync:', error);
    return res.status(500).json({ error: error.message });
  }
};
