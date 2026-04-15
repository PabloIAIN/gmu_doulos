const { sql } = require('./_db');
const { verificarApiKey, handleOptions, checkRateLimit } = require('./_auth');
const bcrypt = require('bcryptjs');

// ── Helpers ──
function getRolDirector(ministerio) {
  const m = { 'gm': 'Director GM', 'conq': 'Director Conq', 'av': 'Director Aventureros', 'coordinador': 'Coordinador General' };
  return m[ministerio] || null;
}

function getRolFinal(ministerio, tipoRol) {
  const m = { 'gm-consejero': 'Consejero GM', 'gm-miembro': 'Aspirante GM', 'conq-consejero': 'Consejero Conq', 'conq-miembro': 'Conquistador', 'av-consejero': 'Consejero Aventureros', 'av-miembro': 'Aventurero' };
  return m[`${ministerio}-${tipoRol}`] || null;
}

async function copiarPlantillaDIA(clubId, ministeriosStr) {
  const ministerios = ministeriosStr.split(',').map(m => m.trim());
  for (const min of ministerios) {
    const templateId = min === 'gm' ? 'DIA_TEMPLATE_GM' : min === 'conq' ? 'DIA_TEMPLATE_CONQ' : min === 'av' ? 'DIA_TEMPLATE_AV' : null;
    if (!templateId) continue;
    const existing = await sql`SELECT COUNT(*) as c FROM carpeta_secciones WHERE club_id = ${clubId}`;
    if (parseInt(existing[0].c) > 0) continue;
    const secciones = await sql`SELECT * FROM carpeta_secciones WHERE club_id = ${templateId}`;
    for (const s of secciones) {
      const newId = `${clubId}-${s.id}`;
      await sql`INSERT INTO carpeta_secciones (id, nombre, orden, club_id) VALUES (${newId}, ${s.nombre}, ${s.orden}, ${clubId}) ON CONFLICT (id) DO NOTHING`;
      const requisitos = await sql`SELECT * FROM carpeta_requisitos WHERE seccion_id = ${s.id} AND club_id = ${templateId}`;
      for (const r of requisitos) {
        const newRid = `${clubId}-${r.id}`;
        await sql`INSERT INTO carpeta_requisitos (id, seccion_id, nombre, orden, club_id) VALUES (${newRid}, ${newId}, ${r.nombre}, ${r.orden}, ${clubId}) ON CONFLICT (id) DO NOTHING`;
      }
    }
  }
}

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;

  try {
    // ═══════ GET ═══════
    if (req.method === 'GET') {
      const { codigo, id, pendientes, club_id, ministerio, tipo } = req.query;

      // Verificar código de acceso (sin auth)
      // El codigo se busca en tabla codigos (con ministerio + tipo)
      // Fallback a codigo_acceso/codigo_unirse para compatibilidad
      if (codigo) {
        // 1. Buscar en tabla codigos (nuevo esquema con ministerio)
        const tipoFiltro = tipo === 'miembro' ? 'miembro' : 'director';
        const cods = await sql`SELECT c.club_id, c.ministerio, c.tipo, cl.nombre, cl.iglesia, cl.ciudad, cl.pais, cl.ministerios, cl.plan, cl.max_miembros, cl.activo FROM codigos c JOIN clubes cl ON cl.id = c.club_id WHERE c.codigo = ${codigo} AND c.tipo = ${tipoFiltro} AND c.activo = 1 AND cl.activo = 1`;
        if (cods.length > 0) {
          const r = cods[0];
          return res.status(200).json({
            ok: true,
            data: { id: r.club_id, nombre: r.nombre, iglesia: r.iglesia, ciudad: r.ciudad, pais: r.pais, ministerios: r.ministerios, plan: r.plan, max_miembros: r.max_miembros, activo: r.activo, ministerio: r.ministerio }
          });
        }

        // 2. Fallback al esquema viejo
        let rows;
        if (tipo === 'miembro') {
          rows = await sql`SELECT id, nombre, iglesia, ciudad, pais, ministerios, plan, max_miembros, activo FROM clubes WHERE codigo_unirse = ${codigo} AND activo = 1`;
        } else {
          rows = await sql`SELECT id, nombre, iglesia, ciudad, pais, ministerios, plan, max_miembros, activo FROM clubes WHERE codigo_acceso = ${codigo} AND activo = 1`;
        }
        if (rows.length === 0) return res.status(404).json({ error: 'Código inválido' });
        return res.status(200).json({ ok: true, data: rows[0] });
      }

      // Obtener club por ID (con auth)
      if (id) {
        if (!verificarApiKey(req, res)) return;
        const rows = await sql`SELECT * FROM clubes WHERE id = ${id}`;
        if (rows.length === 0) return res.status(404).json({ error: 'Club no encontrado' });
        return res.status(200).json({ ok: true, data: rows[0] });
      }

      // Obtener solicitudes pendientes (aprobaciones)
      if (pendientes && club_id) {
        if (!verificarApiKey(req, res)) return;
        let rows;
        if (ministerio && ministerio !== 'todos') {
          rows = await sql`SELECT id, nombre, apellido, rol, ministerio, clase_ministerio, fecha_registro FROM miembros WHERE club_id = ${club_id} AND ministerio = ${ministerio} AND activo = 0 ORDER BY fecha_registro DESC`;
        } else {
          rows = await sql`SELECT id, nombre, apellido, rol, ministerio, clase_ministerio, fecha_registro FROM miembros WHERE club_id = ${club_id} AND activo = 0 ORDER BY fecha_registro DESC`;
        }
        return res.status(200).json({ data: rows, total: rows.length });
      }

      return res.status(400).json({ error: 'Se requiere codigo, id, o pendientes+club_id' });
    }

    // ═══════ POST ═══════
    if (req.method === 'POST') {
      const { action } = req.body;

      // ── Onboarding (Director con código) ──
      if (action === 'onboarding') {
        const { codigo_acceso, ministerio: minBody, nombre, apellido, usuario, password } = req.body;
        if (!codigo_acceso || !nombre || !apellido || !usuario || !password) {
          return res.status(400).json({ error: 'Campos requeridos: codigo_acceso, nombre, apellido, usuario, password' });
        }

        // Buscar primero en tabla codigos (nuevo esquema)
        let club, ministerio;
        const cods = await sql`SELECT c.club_id, c.ministerio, cl.* FROM codigos c JOIN clubes cl ON cl.id = c.club_id WHERE c.codigo = ${codigo_acceso} AND c.tipo = 'director' AND c.activo = 1 AND cl.activo = 1`;
        if (cods.length > 0) {
          club = cods[0];
          ministerio = cods[0].ministerio;
        } else {
          // Fallback al esquema viejo
          const clubRows = await sql`SELECT * FROM clubes WHERE codigo_acceso = ${codigo_acceso} AND activo = 1`;
          if (clubRows.length === 0) return res.status(404).json({ error: 'Código de Director inválido' });
          club = clubRows[0];
          ministerio = minBody;
          if (!ministerio) return res.status(400).json({ error: 'ministerio requerido' });
        }
        if (ministerio !== 'coordinador') {
          const mins = club.ministerios.split(',').map(m => m.trim());
          if (!mins.includes(ministerio)) return res.status(400).json({ error: `Ministerio "${ministerio}" no habilitado` });
        }
        const rol = getRolDirector(ministerio);
        if (!rol) return res.status(400).json({ error: 'Ministerio inválido' });
        if (ministerio !== 'coordinador') {
          const ex = await sql`SELECT id FROM miembros WHERE club_id = ${club.id} AND rol = ${rol} AND activo = 1`;
          if (ex.length > 0) return res.status(409).json({ error: `Ya existe un ${rol}` });
        }
        const uex = await sql`SELECT id FROM miembros WHERE usuario = ${usuario}`;
        if (uex.length > 0) return res.status(409).json({ error: 'Usuario ya en uso' });
        const id = Date.now().toString() + Math.random().toString(36).substring(2, 8);
        const hash = await bcrypt.hash(password, 10);
        const clase = ministerio === 'gm' ? 'Guía Mayor Avanzado' : '';
        await sql`INSERT INTO miembros (id,nombre,apellido,clase,rol,activo,fecha_registro,usuario,password_hash,club_id,ministerio) VALUES (${id},${nombre},${apellido},${clase},${rol},1,${new Date().toISOString()},${usuario},${hash},${club.id},${ministerio==='coordinador'?'todos':ministerio})`;
        await copiarPlantillaDIA(club.id, club.ministerios);
        return res.status(201).json({ ok: true, club: { id: club.id, nombre: club.nombre, iglesia: club.iglesia, ciudad: club.ciudad, ministerios: club.ministerios }, miembro: { id, nombre, apellido, rol, ministerio }, api_key: process.env.API_KEY });
      }

      // ── Unirse a un club ──
      if (action === 'unirse') {
        const { club_id, ministerio, nombre, apellido, fecha_nacimiento, telefono, email, usuario, password, rol_solicitado, clase_ministerio } = req.body;
        if (!club_id || !ministerio || !nombre || !apellido || !usuario || !password || !rol_solicitado) {
          return res.status(400).json({ error: 'Campos requeridos faltantes' });
        }
        const clubRows = await sql`SELECT * FROM clubes WHERE id = ${club_id} AND activo = 1`;
        if (clubRows.length === 0) return res.status(404).json({ error: 'Club no encontrado' });
        const club = clubRows[0];
        const mins = club.ministerios.split(',').map(m => m.trim());
        if (!mins.includes(ministerio)) return res.status(400).json({ error: `Ministerio "${ministerio}" no habilitado` });
        const cnt = await sql`SELECT COUNT(*) as t FROM miembros WHERE club_id = ${club_id} AND activo = 1`;
        if (parseInt(cnt[0].t) >= club.max_miembros) return res.status(403).json({ error: `Límite de ${club.max_miembros} miembros alcanzado` });
        const uex = await sql`SELECT id FROM miembros WHERE usuario = ${usuario}`;
        if (uex.length > 0) return res.status(409).json({ error: 'Usuario ya en uso' });
        const rol = getRolFinal(ministerio, rol_solicitado);
        if (!rol) return res.status(400).json({ error: 'Combinación inválida de ministerio y rol' });
        const id = Date.now().toString() + Math.random().toString(36).substring(2, 8);
        const hash = await bcrypt.hash(password, 10);
        await sql`INSERT INTO miembros (id,nombre,apellido,fecha_nacimiento,telefono,email,clase,rol,activo,fecha_registro,usuario,password_hash,club_id,ministerio,clase_ministerio) VALUES (${id},${nombre},${apellido},${fecha_nacimiento||null},${telefono||null},${email||null},${clase_ministerio||''},${rol},0,${new Date().toISOString()},${usuario},${hash},${club_id},${ministerio},${clase_ministerio||null})`;
        return res.status(201).json({ ok: true, mensaje: 'Solicitud enviada. El Director debe aprobarte.', miembro_id: id });
      }

      // ── Aprobar/rechazar miembro ──
      if (action === 'aprobar' || action === 'rechazar') {
        if (!verificarApiKey(req, res)) return;
        const { club_id, miembro_id, rol } = req.body;
        if (!club_id || !miembro_id) return res.status(400).json({ error: 'club_id y miembro_id requeridos' });
        if (action === 'rechazar') {
          await sql`DELETE FROM miembros WHERE id = ${miembro_id} AND club_id = ${club_id} AND activo = 0`;
          return res.status(200).json({ ok: true, accion: 'rechazado' });
        }
        if (rol) { await sql`UPDATE miembros SET activo = 1, rol = ${rol} WHERE id = ${miembro_id} AND club_id = ${club_id}`; }
        else { await sql`UPDATE miembros SET activo = 1 WHERE id = ${miembro_id} AND club_id = ${club_id}`; }
        return res.status(200).json({ ok: true, accion: 'aprobado' });
      }

      // ── Reset password ──
      if (action === 'reset_password') {
        if (!verificarApiKey(req, res)) return;
        if (!checkRateLimit(req, res, 10)) return;
        const { club_id, miembro_id, nueva_password, solicitante_id } = req.body;
        if (!club_id || !miembro_id || !nueva_password || !solicitante_id) return res.status(400).json({ error: 'Campos requeridos faltantes' });
        const sol = await sql`SELECT rol FROM miembros WHERE id = ${solicitante_id} AND club_id = ${club_id} AND activo = 1`;
        if (sol.length === 0 || !sol[0].rol.startsWith('Director')) return res.status(403).json({ error: 'Solo un Director puede resetear contraseñas' });
        const hash = await bcrypt.hash(nueva_password, 10);
        await sql`UPDATE miembros SET password_hash = ${hash}, updated_at = NOW() WHERE id = ${miembro_id} AND club_id = ${club_id}`;
        return res.status(200).json({ ok: true, mensaje: 'Contraseña actualizada' });
      }

      // ── Crear codigo (SuperAdmin) ──
      if (action === 'crear_codigo') {
        const superKey = req.headers['x-superadmin-key'];
        if (!superKey || superKey !== process.env.SUPER_ADMIN_KEY) {
          return res.status(403).json({ error: 'Se requiere clave de super administrador' });
        }
        const { codigo, club_id, ministerio, tipo } = req.body;
        if (!codigo || !club_id || !ministerio || !tipo) {
          return res.status(400).json({ error: 'codigo, club_id, ministerio y tipo requeridos' });
        }
        await sql`INSERT INTO codigos (codigo, club_id, ministerio, tipo) VALUES (${codigo}, ${club_id}, ${ministerio}, ${tipo}) ON CONFLICT (codigo) DO UPDATE SET club_id = EXCLUDED.club_id, ministerio = EXCLUDED.ministerio, tipo = EXCLUDED.tipo, activo = 1`;
        return res.status(201).json({ ok: true, codigo });
      }

      // ── Crear club (SuperAdmin) ──
      const superKey = req.headers['x-superadmin-key'];
      if (!superKey || superKey !== process.env.SUPER_ADMIN_KEY) {
        return res.status(403).json({ error: 'Se requiere action válida o clave de super administrador' });
      }
      const { id, nombre, iglesia, ciudad, pais, asociacion, union_campo, codigo_acceso, codigo_unirse, ministerios, plan, max_miembros } = req.body;
      if (!id || !nombre || !iglesia || !ciudad || !codigo_acceso) return res.status(400).json({ error: 'id, nombre, iglesia, ciudad y codigo_acceso requeridos' });
      await sql`INSERT INTO clubes (id,nombre,iglesia,ciudad,pais,asociacion,union_campo,codigo_acceso,codigo_unirse,ministerios,plan,max_miembros) VALUES (${id},${nombre},${iglesia},${ciudad},${pais||'México'},${asociacion||null},${union_campo||null},${codigo_acceso},${codigo_unirse||null},${ministerios||'gm'},${plan||'gratis'},${max_miembros||20}) ON CONFLICT (id) DO UPDATE SET nombre=EXCLUDED.nombre,iglesia=EXCLUDED.iglesia,codigo_unirse=EXCLUDED.codigo_unirse,ministerios=EXCLUDED.ministerios,updated_at=NOW()`;
      return res.status(201).json({ ok: true, id });
    }

    // ═══════ PUT ═══════
    if (req.method === 'PUT') {
      if (!verificarApiKey(req, res)) return;
      const { id } = req.query;
      if (!id) return res.status(400).json({ error: 'id es requerido' });
      const { nombre, iglesia, ciudad, ministerios, plan, max_miembros } = req.body;
      await sql`UPDATE clubes SET nombre=COALESCE(${nombre||null},nombre),iglesia=COALESCE(${iglesia||null},iglesia),ciudad=COALESCE(${ciudad||null},ciudad),ministerios=COALESCE(${ministerios||null},ministerios),plan=COALESCE(${plan||null},plan),max_miembros=COALESCE(${max_miembros||null},max_miembros),updated_at=NOW() WHERE id=${id}`;
      return res.status(200).json({ ok: true, id });
    }

    return res.status(405).json({ error: 'Método no permitido' });
  } catch (error) {
    console.error('Error en /api/clubes:', error);
    return res.status(500).json({ error: error.message });
  }
};
