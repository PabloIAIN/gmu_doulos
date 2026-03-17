const { sql } = require('@vercel/postgres');
const { verificarApiKey, handleOptions } = require('../lib/auth');

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;
  if (!verificarApiKey(req, res)) return;

  try {
    // ── POST: Sincronización masiva (subir datos locales al backend) ──
    if (req.method === 'POST') {
      const { miembros, eventos, unidades, unidad_miembros, asistencia } = req.body;
      const resultados = { miembros: 0, eventos: 0, unidades: 0, unidad_miembros: 0, asistencia: 0 };

      // Sincronizar miembros
      if (miembros && Array.isArray(miembros)) {
        for (const m of miembros) {
          await sql`
            INSERT INTO miembros (id, nombre, apellido, fecha_nacimiento, telefono, email, foto_url, clase, rol, activo, fecha_registro, usuario, password_hash)
            VALUES (${m.id}, ${m.nombre}, ${m.apellido}, ${m.fecha_nacimiento || null}, ${m.telefono || null}, ${m.email || null}, ${m.foto_url || null}, ${m.clase || 'Guía Mayor Aspirante'}, ${m.rol || 'Miembro'}, ${m.activo !== undefined ? m.activo : 1}, ${m.fecha_registro || new Date().toISOString()}, ${m.usuario || null}, ${m.password_hash || null})
            ON CONFLICT (id) DO UPDATE SET
              nombre = EXCLUDED.nombre, apellido = EXCLUDED.apellido,
              fecha_nacimiento = EXCLUDED.fecha_nacimiento, telefono = EXCLUDED.telefono,
              email = EXCLUDED.email, clase = EXCLUDED.clase, rol = EXCLUDED.rol,
              activo = EXCLUDED.activo, usuario = EXCLUDED.usuario,
              password_hash = EXCLUDED.password_hash, updated_at = NOW()
          `;
          resultados.miembros++;
        }
      }

      // Sincronizar eventos
      if (eventos && Array.isArray(eventos)) {
        for (const e of eventos) {
          await sql`
            INSERT INTO eventos (id, titulo, descripcion, fecha, hora, ubicacion, tipo, latitud, longitud)
            VALUES (${e.id}, ${e.titulo}, ${e.descripcion || null}, ${e.fecha}, ${e.hora || null}, ${e.ubicacion || null}, ${e.tipo || 'reunion'}, ${e.latitud || null}, ${e.longitud || null})
            ON CONFLICT (id) DO UPDATE SET
              titulo = EXCLUDED.titulo, descripcion = EXCLUDED.descripcion,
              fecha = EXCLUDED.fecha, hora = EXCLUDED.hora,
              ubicacion = EXCLUDED.ubicacion, tipo = EXCLUDED.tipo,
              updated_at = NOW()
          `;
          resultados.eventos++;
        }
      }

      // Sincronizar unidades
      if (unidades && Array.isArray(unidades)) {
        for (const u of unidades) {
          await sql`
            INSERT INTO unidades (id, nombre, descripcion, activo, fecha_creacion)
            VALUES (${u.id}, ${u.nombre}, ${u.descripcion || null}, ${u.activo !== undefined ? u.activo : 1}, ${u.fecha_creacion || new Date().toISOString()})
            ON CONFLICT (id) DO UPDATE SET
              nombre = EXCLUDED.nombre, descripcion = EXCLUDED.descripcion, activo = EXCLUDED.activo
          `;
          resultados.unidades++;
        }
      }

      // Sincronizar unidad_miembros
      if (unidad_miembros && Array.isArray(unidad_miembros)) {
        for (const um of unidad_miembros) {
          await sql`
            INSERT INTO unidad_miembros (id, unidad_id, miembro_id, rol_en_unidad, fecha_asignacion)
            VALUES (${um.id}, ${um.unidad_id}, ${um.miembro_id}, ${um.rol_en_unidad || 'miembro'}, ${um.fecha_asignacion || new Date().toISOString()})
            ON CONFLICT (id) DO UPDATE SET
              rol_en_unidad = EXCLUDED.rol_en_unidad
          `;
          resultados.unidad_miembros++;
        }
      }

      // Sincronizar asistencia
      if (asistencia && Array.isArray(asistencia)) {
        for (const a of asistencia) {
          await sql`
            INSERT INTO asistencia (id, unidad_id, miembro_id, fecha, dia_semana, puntualidad, panoleta, biblia, cuota, registrado_por, fecha_registro)
            VALUES (${a.id}, ${a.unidad_id}, ${a.miembro_id}, ${a.fecha}, ${a.dia_semana || null}, ${a.puntualidad || 0}, ${a.panoleta || 0}, ${a.biblia || 0}, ${a.cuota || 0}, ${a.registrado_por || null}, ${a.fecha_registro || new Date().toISOString()})
            ON CONFLICT (id) DO UPDATE SET
              puntualidad = EXCLUDED.puntualidad, panoleta = EXCLUDED.panoleta,
              biblia = EXCLUDED.biblia, cuota = EXCLUDED.cuota
          `;
          resultados.asistencia++;
        }
      }

      return res.status(200).json({ ok: true, sincronizados: resultados });
    }

    // ── GET: Descargar todos los datos del backend ──
    if (req.method === 'GET') {
      const miembros = await sql`SELECT * FROM miembros ORDER BY nombre`;
      const eventos = await sql`SELECT * FROM eventos ORDER BY fecha DESC`;
      const unidades = await sql`SELECT * FROM unidades ORDER BY nombre`;
      const unidad_miembros = await sql`SELECT * FROM unidad_miembros`;
      const asistencia = await sql`SELECT * FROM asistencia ORDER BY fecha DESC`;

      return res.status(200).json({
        data: {
          miembros: miembros.rows,
          eventos: eventos.rows,
          unidades: unidades.rows,
          unidad_miembros: unidad_miembros.rows,
          asistencia: asistencia.rows,
        },
        timestamp: new Date().toISOString(),
      });
    }

    return res.status(405).json({ error: 'Método no permitido' });
  } catch (error) {
    console.error('Error en /api/sync:', error);
    return res.status(500).json({ error: error.message });
  }
};
