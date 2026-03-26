const { sql } = require('./_db');
const { handleOptions } = require('./_auth');
const bcrypt = require('bcryptjs');

// Mapea ministerio a rol de Director
function getRolDirector(ministerio) {
  switch (ministerio) {
    case 'gm': return 'Director GM';
    case 'conq': return 'Director Conq';
    case 'av': return 'Director Aventureros';
    case 'coordinador': return 'Coordinador General';
    default: return null;
  }
}

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido' });
  }

  try {
    const { codigo_acceso, ministerio, nombre, apellido, usuario, password } = req.body;

    if (!codigo_acceso || !ministerio || !nombre || !apellido || !usuario || !password) {
      return res.status(400).json({ error: 'Todos los campos son requeridos: codigo_acceso, ministerio, nombre, apellido, usuario, password' });
    }

    // 1. Verificar código de acceso
    const clubRows = await sql`SELECT * FROM clubes WHERE codigo_acceso = ${codigo_acceso} AND activo = 1`;
    if (clubRows.length === 0) {
      return res.status(404).json({ error: 'Código de acceso inválido o club inactivo' });
    }
    const club = clubRows[0];

    // 2. Verificar que el ministerio esté habilitado en el club
    if (ministerio !== 'coordinador') {
      const ministeriosClub = club.ministerios.split(',').map(m => m.trim());
      if (!ministeriosClub.includes(ministerio)) {
        return res.status(400).json({ error: `El ministerio "${ministerio}" no está habilitado en este club` });
      }
    }

    // 3. Determinar el rol
    const rol = getRolDirector(ministerio);
    if (!rol) {
      return res.status(400).json({ error: 'Ministerio inválido. Usa: gm, conq, av, o coordinador' });
    }

    // 4. Verificar que no exista ya un Director para ese ministerio (excepto Coordinador)
    if (ministerio !== 'coordinador') {
      const existente = await sql`SELECT id FROM miembros WHERE club_id = ${club.id} AND rol = ${rol} AND activo = 1`;
      if (existente.length > 0) {
        return res.status(409).json({ error: `Ya existe un ${rol} para este club` });
      }
    }

    // 5. Verificar que el usuario no exista
    const usuarioExiste = await sql`SELECT id FROM miembros WHERE usuario = ${usuario}`;
    if (usuarioExiste.length > 0) {
      return res.status(409).json({ error: 'El nombre de usuario ya está en uso' });
    }

    // 6. Crear el miembro Director
    const id = Date.now().toString() + Math.random().toString(36).substring(2, 8);
    const passwordHash = await bcrypt.hash(password, 10);
    const claseDefault = ministerio === 'gm' ? 'Guía Mayor Avanzado' : '';

    await sql`
      INSERT INTO miembros (id, nombre, apellido, clase, rol, activo, fecha_registro, usuario, password_hash, club_id, ministerio)
      VALUES (${id}, ${nombre}, ${apellido}, ${claseDefault}, ${rol}, 1, ${new Date().toISOString()}, ${usuario}, ${passwordHash}, ${club.id}, ${ministerio === 'coordinador' ? 'todos' : ministerio})`;

    // 7. Copiar plantilla DIA al club según ministerio
    const ministeriosClub = club.ministerios.split(',').map(m => m.trim());
    for (const min of ministeriosClub) {
      const templateId = min === 'gm' ? 'DIA_TEMPLATE_GM' : min === 'conq' ? 'DIA_TEMPLATE_CONQ' : min === 'av' ? 'DIA_TEMPLATE_AV' : null;
      if (!templateId) continue;

      // Verificar si ya se copiaron las secciones para este club+ministerio
      const existing = await sql`SELECT COUNT(*) as c FROM carpeta_secciones WHERE club_id = ${club.id}`;
      if (parseInt(existing[0].c) > 0) continue;

      // Copiar secciones
      const secciones = await sql`SELECT * FROM carpeta_secciones WHERE club_id = ${templateId}`;
      for (const s of secciones) {
        const newId = `${club.id}-${s.id}`;
        await sql`INSERT INTO carpeta_secciones (id, nombre, orden, club_id) VALUES (${newId}, ${s.nombre}, ${s.orden}, ${club.id}) ON CONFLICT (id) DO NOTHING`;

        // Copiar requisitos de esta sección
        const requisitos = await sql`SELECT * FROM carpeta_requisitos WHERE seccion_id = ${s.id} AND club_id = ${templateId}`;
        for (const r of requisitos) {
          const newRid = `${club.id}-${r.id}`;
          await sql`INSERT INTO carpeta_requisitos (id, seccion_id, nombre, orden, club_id) VALUES (${newRid}, ${newId}, ${r.nombre}, ${r.orden}, ${club.id}) ON CONFLICT (id) DO NOTHING`;
        }
      }
    }

    // 8. Retornar datos
    return res.status(201).json({
      ok: true,
      club: { id: club.id, nombre: club.nombre, iglesia: club.iglesia, ciudad: club.ciudad, ministerios: club.ministerios },
      miembro: { id, nombre, apellido, rol, ministerio },
      api_key: process.env.API_KEY,
    });
  } catch (error) {
    console.error('Error en /api/onboarding:', error);
    return res.status(500).json({ error: error.message });
  }
};
